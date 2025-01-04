//==============================================================================
//  lot100ar_lothering.nss
//  Lothering area script
//
// - Flagging the player as entered the Lothering area (needed for camp/world map events)
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "wrd_constants_h"
#include "lot_constants_h"
#include "camp_constants_h"
#include "sys_ambient_h"
#include "party_h"

#include "plt_mnp000pt_main_rumour"
#include "plt_mnp000pt_main_lothering"
#include "plt_mnp000pt_main_events"
#include "plt_mnp000pt_camp_events"
#include "plt_lot000pt_leliana"

#include "plt_lot120pt_soldiers"
#include "plt_lot100pt_bandits"
#include "plt_lot100pt_bandits2"
#include "plt_lot100pt_bandits2_sub"
#include "plt_lot100pt_bears"
#include "plt_lot100pt_traps101"
#include "plt_lot100pt_herbalism101"
#include "plt_lot110pt_ser_donall"
#include "plt_lot100pt_orphan"
#include "plt_lot100pt_doomsayer"

#include "plt_gen00pt_stealing"

#include "plt_cod_hst_lothering"

#include "plt_lite_mabari_dom"
#include "plt_gen00pt_party"



//------------------------------------------------------------------------------

void main()
{
    event   ev          =   GetCurrentEvent();

    int     nEventType  =   GetEventType(ev);

    string  sDebug;

    object  oPC         =   GetHero();
    object  oParty      =   GetParty(oPC);

    object  oWagon      =   UT_GetNearestObjectByTag(oPC, LOT_IP_CHANTRY_WAGON);
    object  oBoard      =   UT_GetNearestObjectByTag(oPC, LOT_IP_CHANTER_BOARD);
    object  oLeader     =   UT_GetNearestObjectByTag(oPC, LOT_CR_BANDIT_LEADER);
    object  oBodahn     =   UT_GetNearestCreatureByTag(oPC, CAMP_BODAHN);
    object  oSandal     =   UT_GetNearestCreatureByTag(oPC, CAMP_SANDAL);
    object  oAlistair   =   Party_GetFollowerByTag(GEN_FL_ALISTAIR);
    object  oMorrigan   =   Party_GetFollowerByTag(GEN_FL_MORRIGAN);
    object  oLeliana    =   UT_GetNearestObjectByTag(oPC, GEN_FL_LELIANA);

    int     bFallTemp   =   WR_GetPlotFlag(PLT_LOT110PT_SER_DONALL, SER_DONALL_KNOWS_HENRIC_IS_DEAD);


    switch(nEventType)
    {

        //----------------------------------------------------------------------
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        //----------------------------------------------------------------------
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {

            int    bDoOnce  =   GetLocalInt(OBJECT_SELF, AREA_DO_ONCE_A);

            // This is to delay the ambient animations of one of the two
            // rummaging bandits.
            event   evBanditDelay   =   Event(EVENT_TYPE_CUSTOM_EVENT_08);

            DelayEvent(0.5f, OBJECT_SELF, evBanditDelay);

            SetObjectInteractive(oWagon, FALSE);

            if(!bDoOnce)
            {

                // Initiate the bandit encounter right away.
                UT_Talk(oLeader, oPC);

            }


            break;
        }

        //----------------------------------------------------------------------
        // Sent by: The engine
        // When: all game objects in the area have loaded
        //----------------------------------------------------------------------
        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {
            int    bDoOnce  =   GetLocalInt(OBJECT_SELF, AREA_DO_ONCE_A);

            string sTag     =   GetTag(OBJECT_SELF);

            if(!bDoOnce)
            {
                SetLocalInt(OBJECT_SELF, AREA_DO_ONCE_A, TRUE);

                if (sTag== LOT_AR_LOTHERING)
                {

                    // Flag player as entered Lothering (used in world map events)
                    WR_SetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, PLAYER_ENTERED_LOTHERING, TRUE);

                    // Main plot setup (Lothering subplot)
                    WR_SetPlotFlag(PLT_MNP000PT_MAIN_LOTHERING, MAIN_LOTHERING_GET_ACROSS_LOTHERING, TRUE);

                    // Set plot giver flag on Sten
                    SetPlotGiver(GetObjectByTag(GEN_FL_STEN),TRUE);

                    // Set plot giver flag on Miriam
                    SetPlotGiver(UT_GetNearestCreatureByTag(oPC, WRD_CR_MIRIAM), TRUE);

                    // Set plot giver flag on Allison
                    SetPlotGiver(UT_GetNearestCreatureByTag(oPC, WRD_CR_ALLISON), TRUE);

                    // Set plot giver flag on the Chanter's board
                    SetPlotGiver(oBoard, TRUE);

                    // Give codex entry for Lothering
                    WR_SetPlotFlag(PLT_COD_HST_LOTHERING, COD_HST_LOTHERING, TRUE, TRUE);

                    // Turn of the party picker for now. Turn it back on after the initial
                    // bandits have been dealt with.
                    SetPartyPickerGUIStatus(PP_GUI_STATUS_READ_ONLY);

                }
            }

            int bCampBeforeLoth = WR_GetPlotFlag(PLT_MNP000PT_CAMP_EVENTS, CAMP_EVENT_BEFORE_LOTHERING);

            if(bCampBeforeLoth)
            {

                // Moved to a trigger at the base of the ramp down.
                //UT_Talk(oPC, oPC, GEN_DL_CAMP_EVENTS);

                // unlock followers
                WR_SetFollowerState(oAlistair, FOLLOWER_STATE_ACTIVE);
                WR_SetFollowerState(oMorrigan, FOLLOWER_STATE_ACTIVE);

                //SetFollowerLocked(oAlistair, FALSE);
                //SetFollowerLocked(oMorrigan, FALSE);

            }

            int    bLelianaWaiting = WR_GetPlotFlag(PLT_LOT000PT_LELIANA, LELIANA_WAITING_IN_LOTHERING);
            int    bTempToBandits  = WR_GetPlotFlag(PLT_LOT100PT_BANDITS, BANDITS_BRYNAT_SENT_TEMPLARS);

            // Leliana should wait near the exit if met at the inn
            if(bLelianaWaiting)
            {

                WR_SetObjectActive(oLeliana, TRUE);

            }

            //CNM: scripting for rumour man
            int    nBodahnRescued = WR_GetPlotFlag(PLT_MNP000PT_MAIN_RUMOUR,MAIN_RUMOUR_BODAHN_RESCUED);

            if(nBodahnRescued == FALSE)
            {
                if(GetObjectActive(oSandal) == FALSE)
                {

                    WR_SetObjectActive(oSandal,TRUE);

                }

                if(GetObjectActive(oBodahn) == FALSE)
                {

                    WR_SetObjectActive(oBodahn,TRUE);

                }
            }

            if(nBodahnRescued == TRUE)
            {
                if(GetObjectActive(oSandal) == TRUE)
                {

                    WR_SetObjectActive(oSandal,FALSE);

                }

                if(GetObjectActive(oBodahn) == TRUE)
                {

                    WR_SetObjectActive(oBodahn,FALSE);

                }
                // Qwinn added
                object oBodahnWagon = UT_GetNearestObjectByTag(oPC,"genip_wagon");
                WR_SetObjectActive(oBodahnWagon,FALSE);
            }

            if (WR_GetPlotFlag(PLT_LOT120PT_SOLDIERS,TAVERN_SOLDIERS_ATTACK))
            {

                UT_TeamAppears(LOT_TEAM_REFUGEE_AMBUSH,TRUE);

            }


            // This will turn interactive placeables into non-interactive placeables.
            object [] oTeamWagon =  UT_GetTeam(LOT_TEAM_CHANTRY_WAGONS, OBJECT_TYPE_PLACEABLE);

            int       nTeamSize  =  GetArraySize(oTeamWagon);
            int       nLoop;

            for(nLoop = 0; nLoop < nTeamSize; nLoop++)
            {

                SetPlot(oTeamWagon[nLoop], TRUE);

            }

            UT_SetTeamInteractive(LOT_TEAM_CHANTRY_WAGONS, FALSE, OBJECT_TYPE_PLACEABLE);

            //Check for Mabari Dominance
            if (WR_GetPlotFlag(PLT_LITE_MABARI_DOM, MABARI_DOM_LOTHERING) == TRUE)
            {
                //if dog is in the party -
                int nDog = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY);
                if (nDog == TRUE)
                {
                    object oDog = Party_GetFollowerByTag("gen00fl_dog");
                    //if this flag has been set - activate the bonus and show the message
                    UI_DisplayMessage(oDog, 4010);

                    //Activate Bonus here
                    effect eDog = EffectMabariDominance();
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eDog, oDog, 0.0f, oDog, 200261);
                }
            }

            break;

        }

        //----------------------------------------------------------------------
        // EVENT_TYPE_STEALING_FAILURE:
        // Sent by: Skill Script (skill_stealing)
        // When: player fails stealing skill
        //----------------------------------------------------------------------

        case EVENT_TYPE_STEALING_FAILURE:
        {
            LogTrace(LOG_CHANNEL_SYSTEMS, "lot100ar_lothering::EVENT_TYPE_STEALING_FAILURE", OBJECT_SELF);

            string sArea          = GetTag(OBJECT_SELF);

            object oMiriam        = UT_GetNearestObjectByTag(oPC, WRD_CR_MIRIAM);
            object oAllison       = UT_GetNearestObjectByTag(oPC, WRD_CR_ALLISON);

            int    bInfamy        = WR_GetPlotFlag(PLT_GEN00PT_STEALING, STEALING_LOT_INFAMY);
            int    bTrapsAccepted = WR_GetPlotFlag(PLT_LOT100PT_TRAPS101, TRAPS101_QUEST_ACCEPTED);
            int    bTrapsDone     = WR_GetPlotFlag(PLT_LOT100PT_TRAPS101, TRAPS101_QUEST_RESOLVED);
            int    bHerbsAccepted = WR_GetPlotFlag(PLT_LOT100PT_HERBALISM101, HERBALISM101_QUEST_ACCEPTED);
            int    bHerbsDone     = WR_GetPlotFlag(PLT_LOT100PT_HERBALISM101, HERBALISM101_QUEST_RESOLVED);

            if(!bInfamy)
            {
                 // Set the players infamy status
                WR_SetPlotFlag(PLT_GEN00PT_STEALING, STEALING_LOT_INFAMY, TRUE, TRUE);

                // If traps quest accepted but not completed.
                if ((bTrapsAccepted) && !(bTrapsDone))
                {

                    WR_SetPlotFlag(PLT_LOT100PT_TRAPS101, TRAPS101_INFAMY_ENDING, TRUE, TRUE);

                }

                // If Herbalism quest accepted but not completed.
                if ((bHerbsAccepted) && !(bHerbsDone))
                {

                    WR_SetPlotFlag(PLT_LOT100PT_HERBALISM101, HERBALISM101_INFAMY_ENDING, TRUE, TRUE);

                }

                // If the herbalism/traps quest have not been accepted yet, turn off the
                // plot giver status for Miriam and Allison.
                SetPlotGiver(oMiriam, FALSE);
                SetPlotGiver(oAllison, FALSE);

            }

            break;
         }

        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature exits the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_EXIT:
        {
            //if dog is in the party -
            int nDog = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY);
            if (nDog == TRUE)
            {
                object oDog = Party_GetFollowerByTag("gen00fl_dog");
                //DeActivate Bonus here
                RemoveEffectsByParameters(oDog, EFFECT_TYPE_INVALID, 200261);
            }

            break;
        }

        //----------------------------------------------------------------------
        // Sent by: Scripting
        // When: The last creature of a team dies
        //----------------------------------------------------------------------
        case EVENT_TYPE_TEAM_DESTROYED:
        {
            int nTeamID = GetEventInteger(ev, 0); // Team ID

            switch (nTeamID)
            {
                //--------------------------------------------------------------
                // Lothering part 1
                //--------------------------------------------------------------


                case LOT_TEAM_BANDITS:
                {

                    WR_SetPlotFlag(PLT_LOT100PT_BANDITS, BANDITS_KILLED, TRUE, TRUE);

                    break;

                }


                // Group of bandits for Chanter's board quest
                case LOT_TEAM_BANDIT_GROUP1:
                {

                    WR_SetPlotFlag(PLT_LOT100PT_BANDITS2, BANDITS2_GROUP_ONE_KILLED, TRUE, TRUE);

                    break;
                }

                // Group of bandits for Chanter's board quest
                case LOT_TEAM_BANDIT_GROUP2:
                {
                    WR_SetPlotFlag(PLT_LOT100PT_BANDITS2, BANDITS2_GROUP_TWO_KILLED, TRUE, TRUE);

                    break;
                }

                // Group of bandits for Chanter's board quest
                case LOT_TEAM_BANDIT_GROUP3:
                {
                    WR_SetPlotFlag(PLT_LOT100PT_BANDITS2, BANDITS2_GROUP_THREE_KILLED, TRUE, TRUE);

                    break;
                }

                // Group of bears for Chanter's board quest.
                case LOT_TEAM_BEARS:
                {
                    int bPCHasQuest = WR_GetPlotFlag(PLT_LOT100PT_BEARS, BEARS_QUEST_ACCEPTED);

                    if(bPCHasQuest)
                    {

                        WR_SetPlotFlag(PLT_LOT100PT_BEARS, JOURNAL_BEARS_KILLED, TRUE, TRUE);
                        WR_SetPlotFlag(PLT_LOT100PT_BEARS, BEARS_KILLED, TRUE, TRUE);

                    }

                    else
                    {

                        WR_SetPlotFlag(PLT_LOT100PT_BEARS, BEARS_KILLED, TRUE, TRUE);

                    }

                    break;
                }

                // The darkspawn attacking the rumor man.
                case LOT_TEAM_BODAHN_HURLOCK:
                {
                    Log_Trace(LOG_CHANNEL_SYSTEMS,"lot100cr_hurlock_bodahn.nss","Hurlock team destroyed");

                    WR_SetPlotFlag(PLT_MNP000PT_MAIN_RUMOUR, MAIN_RUMOUR_BODAHN_RESCUED, TRUE, TRUE);

                    // After the hurlocks killed
                    //WR_ClearAllCommands(oBodahn, TRUE);

                    //WR_ClearAllCommands(oSandal, TRUE);

                    break;
                }

            }
            break;
        }

        case EVENT_TYPE_CUSTOM_EVENT_07:
        {

            event   evScared    =   GetCurrentEvent();

            int     bRescued    =   WR_GetPlotFlag(PLT_MNP000PT_MAIN_RUMOUR, MAIN_RUMOUR_BODAHN_RESCUED);

            int     nAnim1      =   3007;
            int     nAnim2      =   650;

            command cScared1    =   CommandPlayAnimation(nAnim1, 1, 1);
            command cScared2    =   CommandPlayAnimation(nAnim2, 1, 1);

            if(bRescued == FALSE)
            {

                WR_AddCommand(oBodahn, cScared1);
                WR_AddCommand(oSandal, cScared2);

                DelayEvent(1.0f, OBJECT_SELF, evScared);

            }

            break;
        }

        case EVENT_TYPE_CUSTOM_EVENT_08:
        {
            object  oBandit3    =   UT_GetNearestObjectByTag(oPC, LOT_CR_BANDIT_3);

            Ambient_Start(oBandit3);

            break;
        }


    }
    HandleEvent(ev, RESOURCE_SCRIPT_AREA_CORE);


}