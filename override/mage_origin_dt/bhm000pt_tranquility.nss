//::///////////////////////////////////////////////
//:: bhm600pt_tranquility
//:: Copyright (c) 2006 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This is the plot script for the Ritual of Tranquility plot in the Mage Origin.
*/
//:://////////////////////////////////////////////
//:: Created By: Ferret Baudoin
//:: Created On: Oct. 19, 2006
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "bhm_constants_h"

#include "cutscenes_h"
#include "sys_ambient_h"

#include "plt_bhm000pt_main"
#include "plt_bhm000pt_tranquility"
#include "plt_bhm000pt_undercover"
#include "plt_bhm000pt_spiders"
#include "plt_bhm_area_jumps"

#include "achievement_core_h"

int StartingConditional()
{
    event eParms = GetCurrentEvent();                   // Contains all input parameters
    int nType = GetEventType(eParms);                   // GET or SET call
    string strPlot = GetEventString(eParms, 0);         // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);             // The bit flag # being affected
    object oParty = GetEventCreator(eParms);            // The owner of the plot table for this script
    int nResult = FALSE;                                // used to return value for DEFINED GET events

    object oThis = GetObjectByTag( BHM_CR_GREAGOIR );
    object oPC = GetHero();
    object oTarg;
    resource rItem;
    int nCount;

    plot_GlobalPlotHandler(eParms);                     // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT)                    // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case BASEMENT_BOSS_FIGHT:
            {
                object [] arBossDudes = UT_GetTeam(BHM_TEAM_BASEMENT_BOSS);
                int iDudes = GetArraySize(arBossDudes);
                int i;
                for(i = 0; i < iDudes; i++)
                {
                    //Make them do the work
                    SignalEvent(arBossDudes[i], Event(EVENT_TYPE_CUSTOM_EVENT_01));
                }
                break;
            }

            case JOWAN_HAS_INFO:                        // BHM100_JOWAN
                                                        // Jowan and the PC go to Lily
            {
                //Setup lily
                object oLily = UT_GetNearestCreatureByTag(oPC, BHM_CR_LILY);
                Ambient_Stop(oLily); //Stop ambient
                Rubber_SetHome(oLily, GetObjectByTag(BHM_WP_LILY)); //Set lily to the waypoint
                Rubber_JumpHome(oLily); //Jump her home
                // Goto Lily
                //WR_SetPlotFlag(PLT_BHM_AREA_JUMPS, JOWAN_TO_CHAPEL, TRUE);
                oTarg = UT_GetNearestCreatureByTag(oPC, BHM_CR_JOWAN);
                SetPlotGiver(oTarg,FALSE);
                UT_LocalJump(oTarg,BHM_WP_JOWAN_CHAPEL,TRUE);



                UT_Talk(oTarg,oPC);
                break;
            }

            case PC_HEARD_PLAN_1:

            {
                oTarg = UT_GetNearestCreatureByTag(oPC,BHM_CR_IRVING);
                SetPlotGiver(oTarg,TRUE);
                break;
            }

            case JOWAN_SPEAKS:                          // BHM100_LILY
                                                        // Jowan speaks after you first hear of the plan
            {
                WR_SetPlotFlag( PLT_BHM000PT_TRANQUILITY, JOWAN_SPEAKS, FALSE);// reset var
                oTarg = UT_GetNearestCreatureByTag(oPC, BHM_CR_JOWAN);
                UT_Talk(oTarg, oPC);
                break;
            }

            case PC_HEARD_PLAN_2:                       // BHM100_JOWAN
                                                        // Irving and Lily go to their spots
            {
                oTarg = UT_GetNearestCreatureByTag(oPC, BHM_CR_DUNCAN);
                UT_LocalJump(oTarg,BHM_WP_DUNCAN_LIBRARY,TRUE);
                break;
            }

            case PC_UNDERCOVER:                          // BHM100_LILY
                                                        // Jowan speaks after you first hear of the plan
            {
                WR_SetPlotFlag( PLT_BHM000PT_UNDERCOVER,UNDERCOVER_JOURNAL_ENTRY,TRUE,TRUE);// child journal entry
                oTarg = UT_GetNearestCreatureByTag(oPC,BHM_CR_IRVING);
                SetPlotGiver(oTarg,FALSE);
                break;
            }

            case OWAIN_PC_HAS_FORM:                     // BHM200_OWAIN
                                                        // The PC receives a form
            {
                RewardItem(BHM_IM_UNSIGNED_FORM);
                break;
            }

            case OWAIN_PC_HAS_SIGNED_FORM:              // Various
                                                        // The PC receives a signed form
            {
                WR_DestroyObject(GetItemPossessedBy(oPC,ResourceToTag(BHM_IM_UNSIGNED_FORM)));
                RewardItem(BHM_IM_SIGNED_FORM);
                WR_SetPlotFlag(strPlot,OWAIN_PC_HAS_FORM,FALSE);
                break;
            }

            case OWAIN_PC_HAS_ROD:                      // BHM200_OWAIN
                                                        // The PC receives the Rod of Fire
            {
                //Remove signed form.
                object oForm = GetItemPossessedBy(oPC, ResourceToTag(BHM_IM_SIGNED_FORM));
                SetPlot(oForm, FALSE);
                WR_DestroyObject(oForm);
                RewardItem(BHM_IM_ROD_OF_FIRE);
                WR_SetPlotFlag(strPlot,OWAIN_PC_HAS_SIGNED_FORM,FALSE);
                break;
            }

            case LILY_TOLD_NO:                    // BHM200_LILY

            {
;
                break;
            }

            case JOWAN_AND_LILY_JOIN_PARTY:             // BHM200_LILY
                                                        // The PC is joined by Jowan and Lily
            {
                oTarg = UT_GetNearestCreatureByTag( oPC,BHM_CR_LILY );
                UT_HireFollower(oTarg);

                oTarg = UT_GetNearestCreatureByTag( oPC,BHM_CR_JOWAN );
                UT_HireFollower(oTarg);

                oTarg = UT_GetNearestCreatureByTag(oPC,BHM_CR_IRVING);
                SetPlotGiver(oTarg,FALSE);
                WR_SetObjectActive(oTarg,FALSE);
                break;
            }

            case LILY_LEAVES:                           // BHM400_IRVING
                                                        // Lily leaves
            {
                object oLily = Party_GetFollowerByTag(BHM_CR_LILY );
                if(IsObjectValid(oLily)) //Lily is a party member
                {
                    UT_FireFollower(oTarg,TRUE);
                }
                else
                { //Do whatever this code is meant to do (thanks for the comments)
                    object oNextTo = GetObjectByTag( BHM_WP_SECOND_FLOOR );
                    oTarg = UT_GetNearestCreatureByTag( oNextTo, BHM_CR_LILY );
                    WR_SetObjectActive( oTarg, FALSE );
                }
                break;
            }

            case FIRST_DOOR_CAN_BE_OPENED:                    // BHM700_FIRSTDOOR

            {
                object oDoor = GetObjectByTag(BHM_IP_DOOR_BASE_FIRSTDOOR);
                SetPlaceableState(oDoor,PLC_STATE_DOOR_OPEN);
                break;
            }

            case SKULLS_ATTACK:                         // BHM700_CHEST
                                                        // Jowan opens a chest and skulls attack
            {
                oTarg = UT_GetNearestCreatureByTag(oPC,BHM_CR_JOWAN);
                UT_Talk(oTarg,oPC);
                break;
            }

            case MOVED_BOOKCASE:                        // BHM700_BOOKCASE
                                                        // The party moves the bookcase
            {

                object  oBookcase1  =   UT_GetNearestObjectByTag(oPC, BHM_IP_BOOKCASE_1);
                object  oBookcase2  =   UT_GetNearestObjectByTag(oPC, BHM_IP_BOOKCASE_2);

                WR_SetObjectActive(oBookcase1, FALSE);
                WR_SetObjectActive(oBookcase2, TRUE);

                break;

            }

            case CANNON_FIRED:                          // BHM700_CANNON
                                                        // The cannon is fired
            {

                oTarg = UT_GetNearestObjectByTag(oPC,BHM_IP_BRICK_WALL);

                WR_DestroyObject(oTarg);
                WR_SetPlotFlag(PLT_BHM000PT_TRANQUILITY,WALL_DESTROYED,TRUE);
                SetPlaceableState(GetObjectByTag(BHM_IP_DOOR_BASE_SECONDDOOR),PLC_STATE_DOOR_UNLOCKED);

                //Set the cannon to non-interactive
                object oCannon = GetObjectByTag(BHM_IP_CANNON);
                SetObjectInteractive(oCannon, FALSE);
                break;
            }

            case JOWAN_BETRAYED:                        // BHM700_PHYLACTERYJ
                                                        // The PC confesses to betraying Jowan
            {

                object oJowan = UT_GetNearestCreatureByTag(oPC, BHM_CR_JOWAN);
                object oLily = UT_GetNearestCreatureByTag(oPC, BHM_CR_LILY);
                object oJump = GetObjectByTag(BHM_WP_FROM_BASEMENT);

                //Remove followers from party
                SetFollowerState(oJowan, FOLLOWER_STATE_UNAVAILABLE);
                SetFollowerState(oLily, FOLLOWER_STATE_UNAVAILABLE);

                WR_SetObjectActive(oJowan, FALSE);
                WR_SetObjectActive(oLily, FALSE);

                // This is set so the trigger on the first floor is hit
                WR_SetPlotFlag( PLT_BHM000PT_TRANQUILITY, ESCAPE_CHAMBER, TRUE, FALSE);
                break;
            }

            case ESCAPE_CHAMBER:                        // BHM700_PHYLACTERYJ
                                                        // Every goes to the first floor
            {
                WR_SetPlotFlag( PLT_BHM_AREA_JUMPS, END_CONFLICT_FIRST_FLOOR, TRUE, TRUE);
                break;
            }

            case CUTSCENE_BLOOD_MAGIC:                  // BHM100_JOWAN
                                                        // Starts a cutscene with Jowan
            {
                oTarg = UT_GetNearestCreatureByTag(oPC, BHM_CR_JOWAN);
                UT_Talk(oTarg, oPC, BHM_DG_BLOOD_MAGIC_CUTSCENE);
                break;
            }

            case CUTSCENE_BLOOD_MAGIC_END:              // BHM100_JOWAN
                                                        // End of the cutscene
            {
                //Set Jowen to inactive (need to remove him from the party)
                oTarg = UT_GetNearestCreatureByTag(oPC, BHM_CR_JOWAN);
                UT_FireFollower(oTarg, TRUE);
                WR_SetObjectActive(oTarg, FALSE);

                //Fire conversation with Irving
                oTarg = UT_GetNearestCreatureByTag(oPC, BHM_CR_IRVING);
                UT_Talk(oTarg, oPC);



                break;
            }

            case PHYLACTERY_DESTROYED:
            { //The phylactery was destroyed
                object oPhylactery = GetObjectByTag(BHM_PHYLACTERY);
                SetObjectInteractive(oPhylactery, FALSE); //Can't use it anymore
                break;
            }

            case QUEST_COMPLETE:                        // BHM400_IRVING
                                                        // Load the Prelude
            {
                //Clean up any quests that are still to be done

                //If the spider quest was accepted but not completed
                if(WR_GetPlotFlag(PLT_BHM000PT_SPIDERS, SPIDERS_QUEST_ACCEPTED) == TRUE && WR_GetPlotFlag(PLT_BHM000PT_SPIDERS, LEORAH_SIGNED_FORM) == FALSE)
                {
                    if(WR_GetPlotFlag(PLT_BHM000PT_SPIDERS, SPIDERS_ALL_KILLED) == FALSE)
                    { //The spiders were never finished off
                        WR_SetPlotFlag(PLT_BHM000PT_SPIDERS, SPIDER_QUEST_UNRESOLVED_KILL, TRUE);
                    }
                    else
                    { //Either favour owed or not talked to after killing them
                        WR_SetPlotFlag(PLT_BHM000PT_SPIDERS, SPIDER_QUEST_UNRESOLVED_TALK, TRUE);
                    }
                }
                // Grant achievement: mage completed
                WR_UnlockAchievement(ACH_ADVANCE_HARROWED);
                // If the Player hasn't died, grant achievement: Bloodied
                ACH_CheckForSurvivalAchievement(ACH_FEAT_BLOODIED);


                //Fire lily
                oTarg = Party_GetFollowerByTag(BHM_CR_LILY );
                UT_FireFollower(oTarg,TRUE);

                //Fire jowan (not as easy as there is a second creature with the same tag
                object [] arParty = GetPartyPoolList();
                int i;
                int nSize = GetArraySize(arParty);
                object oCurrent = OBJECT_INVALID;

                for(i = 0; i < nSize; i++)
                {
                    oCurrent = arParty[i];
                    if(GetTag(oCurrent) == BHM_CR_JOWAN)
                    {
                        //Is jowan so fire him
                        UT_FireFollower(oCurrent, TRUE);
                        break; //No need to carry on iterating
                    }
                }

                //Get rid of rod of fire
                UT_RemoveItemFromInventory(BHM_IM_ROD_OF_FIRE, -1);

                //Load the Prelude
                UT_DoAreaTransition(PRE_AR_KINGS_CAMP, PRE_WP_START);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BHM_4);

                break;
            }

            case REMOVE_STOLEN_STAFF:
            {
                //Remove the staff that the PC stole.
                UT_RemoveItemFromInventory(BHM_IM_STOLEN_STAFF);
                break;
            }

            case CUTSCENE_THIRD_DOOR_END:
            {
                 //Set plot flag
                WR_SetPlotFlag(PLT_BHM000PT_TRANQUILITY, JOWAN_SPEAKS_SENTINEL_ATTACK, TRUE);
                //Have Jowan speak a line
                object oSpeaker = GetObjectByTag(BHM_CR_JOWAN);
                UT_Talk(oSpeaker, oPC);

                UT_TeamGoesHostile(BHM_TEAM_BASEMENT_PERSON);
                object oSentinel = UT_GetNearestCreatureByTag(oPC, BHM_CR_SENTINELS);
                //Set the sentinel to active
                SetObjectInteractive(oSentinel,TRUE);
                //Remove effect to stay still
                SetCreatureIsStatue(oSentinel, FALSE);

                //Destroy door
                object oDoor = GetObjectByTag(BHM_IP_SIDE_DOOR);
                SetPlaceableState(oDoor, PLC_STATE_DOOR_DEAD);

                break;
            }

     }

     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case PC_HAS_FORM_TRIED_SWEENEY:       //Caldazar: in fact, has not tried Sweeney
            {
                 if(WR_GetPlotFlag(PLT_BHM000PT_TRANQUILITY, OWAIN_PC_HAS_FORM) == TRUE &&
                    WR_GetPlotFlag(PLT_BHM000PT_TRANQUILITY, SWEENEY_ASKED_ABOUT_ROD) == FALSE)
                 {
                    nResult = TRUE;
                 }
                 else
                 {
                    nResult = FALSE;
                 }
                 break;
            }
            case OWAIN_PC_READY_FOR_ROD:                // The PC is ready to receive the Rod of Fire
            {
                int bCondition1 = WR_GetPlotFlag( PLT_BHM000PT_TRANQUILITY, OWAIN_PC_HAS_SIGNED_FORM);
                int bCondition2 = WR_GetPlotFlag( PLT_BHM000PT_TRANQUILITY, OWAIN_PC_HAS_ROD);
                nResult = bCondition1 && !bCondition2;
                break;
            }

            case IRVING_READY_FOR_UNDERCOVER:           // Irving is ready to ask the PC to go undercover
            {
                int bCondition1 = WR_GetPlotFlag( PLT_BHM000PT_TRANQUILITY, LILY_TOLD_NO);
                int bCondition2 = TRUE;
                // int bCondition2 = WR_GetPlotFlag( PLT_NRD_PHERE_TOWER, QUEST_DONE);
                nResult = bCondition1 && bCondition2;
                break;
            }

            case PC_HEARD_PLAN_1_BUT_NOT_2:
            {   //PC only heard short version of plan and did not talk to Lily

                int bHeardPlan1 = WR_GetPlotFlag(PLT_BHM000PT_TRANQUILITY, PC_HEARD_PLAN_1);
                int bHeardPlan2 = WR_GetPlotFlag(PLT_BHM000PT_TRANQUILITY, PC_HEARD_PLAN_2);

                nResult = (bHeardPlan1 == TRUE) && (bHeardPlan2 == FALSE);

                break;
            }

            case PC_HAS_STOLEN_STAFF:
            { //If the PC stole the staff from the artifact room.
              int iCount = UT_CountItemInInventory(BHM_IM_STOLEN_STAFF);
              if(iCount >= 1)
              {
                nResult = TRUE;
              }
              break;
            }

        }

    }

    return nResult;
}