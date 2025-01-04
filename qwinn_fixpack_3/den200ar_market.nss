// Denerim market area script

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"
#include "den_constants_h"
#include "lit_functions_h"
#include "den_functions_h"

#include "plt_gen00pt_skills"

#include "plt_den200pt_ser_landry"
#include "plt_den200pt_pearls_swine"
#include "plt_den200pt_gen_assassin"
#include "plt_den200pt_thief"
#include "plt_den200pt_crimson"
#include "plt_den200pt_thief_pick1"
#include "plt_den200pt_thief_pick3"
#include "plt_den200pt_thief_pick4"

#include "plt_genpt_alistair_events"
#include "plt_genpt_app_alistair"
#include "plt_genpt_alistair_main"
#include "plt_genpt_alistair_talked"
#include "plt_gen00pt_party"
#include "plt_denpt_rescue_the_queen"

#include "plt_denpt_main"
#include "plt_denpt_map"

#include "plt_genpt_leliana_main"

#include "plt_nrdpt_drake_scales"

#include "plt_lite_tow_jenny"
#include "plt_lite_fite_leadership"
#include "plt_lite_mage_collective"
#include "plt_lite_mage_justice"
#include "plt_lite_mage_defying"
#include "plt_lite_mage_termination"
#include "plt_lite_rogue_solving"
#include "plt_lite_rogue_pieces"
#include "plt_lite_rogue_new_ground"
// Qwinn removed, this is part of cut content
// #include "plt_lite_landry_slander"

// Qwinn added
#include "plt_den200pt_chanter"
#include "plt_qwinn"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    int bEventHandled = FALSE;
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    object oTarg;


    object oAlistair = UT_GetNearestCreatureByTag(oPC, GEN_FL_ALISTAIR);

    object oCityMap         = GetObjectByTag(WM_DEN_TAG);
    object oCM_Market       = GetObjectByTag(WML_DEN_MARKET);


    object oMarjolaineMapPin            = UT_GetNearestObjectByTag(oPC, DEN_WP_MARKET_FROM_MARJOLAINE);
    object oMarjorlaineDoor             = UT_GetNearestObjectByTag(oPC, DEN_IP_MARJORLAINE);

    // Qwinn:  There were a lot more GetObjects here, moved them down to where they're actually used so they
    // don't run every single area load for no good reason.

    switch(nEventType)
    {
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: it is for playing things like cutscenes and movies when
        // you enter an area, things that do not involve AI or actual game play
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_SPECIAL:
        {
            /* Disabled at Yaron's request
            if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_OPENING_DONE))
            {
                if (WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_LEFT_MARKET))
                {
                    SetLocalInt(OBJECT_SELF, AREA_WORLD_MAP_ENABLED, TRUE);
                }
                else
                {
                    SetLocalInt(OBJECT_SELF, AREA_WORLD_MAP_ENABLED, FALSE);
                }
            }  */

            // Qwinn: World map enabled here can skip messenger boy after talking to Ignacio
            SetLocalInt(OBJECT_SELF, AREA_WORLD_MAP_ENABLED, FALSE);
            // Qwinn: No visible reason for not having party picker except Goldanna door which has been resolved
            SetLocalInt(OBJECT_SELF, PARTY_PICKER_ENABLED, TRUE);
            break;
        }
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            object oArea = OBJECT_SELF;
            int nAreaCounter = GetLocalInt(oArea, AREA_COUNTER_6);
            nAreaCounter++;
            SetLocalInt(oArea, AREA_COUNTER_6, nAreaCounter);

            // Retroactive fix to crashing in area for old saves where Alistair's Goldanna trigger has already been used
            object oGoldannaHouseTrigger = UT_GetNearestObjectByTag(oPC,"den200tr_outside_goldanna");
            if(IsObjectValid(oGoldannaHouseTrigger) && (WR_GetPlotFlag(PLT_GENPT_ALISTAIR_TALKED,ALISTAIR_TALKED_ABOUT_SISTER_HOUSE)))
               Safe_Destroy_Object(oGoldannaHouseTrigger);

            // Qwinn changed the following trying to reduce resources in area due
            // to lag and crashing issues.  Plus, kitten genocide!
            if (nAreaCounter == 42)
            {
                UT_TeamAppears(DEN_TEAM_MARKET_AMBIENT, FALSE);
                UT_TeamAppears(DEN_TEAM_MARKET_KITTENS, TRUE);
            }
            else if (nAreaCounter == 43)
            {
                UT_TeamAppears(DEN_TEAM_MARKET_AMBIENT, TRUE);
                object[] oKittenParty = UT_GetTeam(DEN_TEAM_MARKET_KITTENS);
                object oKitten;
                int nIndex, nSize = GetArraySize(oKittenParty);
                for ( nIndex = 0; nIndex < nSize; ++nIndex )
                {   oKitten = oKittenParty[ nIndex ];
                    Safe_Destroy_Object(oKitten);
                }
            }

//            // Qwinn added:
            if (WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN , DEN_RESCUE_VAUGHAN_CHANTRY))
            {
                object oVaughan = UT_GetNearestCreatureByTag(oPC, DEN_CR_VAUGHAN);
                WR_SetObjectActive(oVaughan,TRUE);
                object oClothes = GetItemInEquipSlot(INVENTORY_SLOT_CHEST, oVaughan);
                if (GetTag(oClothes) == "gen_im_cth_com_a01")
                {
                   object oRobes = UT_AddItemToInventory(R"gen_im_cth_cha_a01.uti",1,oVaughan,"gen_im_cth_cha_a01");
                   EquipItem(oVaughan, oRobes, INVENTORY_SLOT_CHEST);
                }
                Ambient_Start(oVaughan,AMBIENT_SYSTEM_ENABLED,AMBIENT_MOVE_INVALID,AMBIENT_MOVE_PREFIX_NONE,9);
            }

            WR_SetPlotFlag(PLT_DENPT_MAP, DEN_MAP__ACTIVATE_CITY_MAP, TRUE, TRUE);
            WR_SetWorldMapPlayerLocation(oCityMap, oCM_Market);

            if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_QUEST_DONE))
            {
                if (!WR_GetPlotFlag(PLT_QWINN,DEN_HABREN_TEAM_DESTROYED))
                {
                   // Qwinn:  Destroying rather than deactivating to free resources
                   oTarg = UT_GetNearestCreatureByTag(oPC, "den200cr_habren");
                   Safe_Destroy_Object(oTarg);
                   oTarg = UT_GetNearestCreatureByTag(oPC, "den200cr_habren_guard");
                   Safe_Destroy_Object(oTarg);
                   oTarg = UT_GetNearestCreatureByTag(oPC, "den200cr_habren_servant");
                   Safe_Destroy_Object(oTarg);
                   oTarg = UT_GetNearestObjectByTag(oPC, "den200tr_habren");
                   Safe_Destroy_Object(oTarg);
                   WR_SetPlotFlag(PLT_QWINN,DEN_HABREN_TEAM_DESTROYED,TRUE);
                }
            }
            else
            {
                if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_OPENING_DONE))
                {
                    if (WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_QUEST_GIVEN))
                    {
                        object oAlienagePortcullis = UT_GetNearestObjectByTag(oPC, DEN_IP_MARKET_ALIENAGE_PORTCULLIS);
                        SetPlaceableState(oAlienagePortcullis, PLC_STATE_DOOR_OPEN);
                    }

                    object oEamonPortcullis             = UT_GetNearestObjectByTag(oPC, DEN_IP_MARKET_EAMON_PORTCULLIS);
                    object oEamonPortcullisOpen         = UT_GetNearestObjectByTag(oPC, DEN_IP_MARKET_EAMON_PORTCULLIS_OPEN);
                    if (!(GetPlaceableState(oEamonPortcullis) == PLC_STATE_DOOR_OPEN))
                    {
                       object oEamonMapPin                 = UT_GetNearestObjectByTag(oPC, DEN_WP_MARKET_FROM_EAMON);
                       object oEamonEntranceLandsmeet      = UT_GetNearestObjectByTag(oPC, DEN_IP_MARKET_TO_EAMON_LANDSMEET);

                       SetMapPinState(oEamonMapPin, TRUE);
                       SetObjectInteractive(oEamonEntranceLandsmeet, TRUE);
                       SetObjectActive(oEamonPortcullis, FALSE);
                       if (IsObjectValid(oEamonPortcullisOpen))
                       {
                          SetObjectActive(oEamonPortcullisOpen, TRUE);
                       }
                       UT_TeamAppears(DEN_TEAM_MARKET_HABREN, TRUE);
                    }
                }
                else
                {
                    UT_TeamAppears(DEN_TEAM_MARKET_HABREN, FALSE);
                }
                if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_EAMON_GOES_WITH_OR_WITHOUT_ALISTAIR))
                {
                    object oCM_Landsmeet = GetObjectByTag(WML_DEN_PALACE);
                    WR_SetWorldMapLocationStatus(oCM_Landsmeet, WM_LOCATION_ACTIVE);
                }
            }

            // For Leliana's plot. If the party has been attacked by Marjorlaine's assassin, unlock the door.
            if ((WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_SEARCHING_FOR_MARJOLAINE)) &&
                !(WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_MARJOLAINE_CONFRONTED)))
            {
                SetObjectInteractive(oMarjorlaineDoor, TRUE);
                SetPlaceableState(oMarjorlaineDoor, PLC_STATE_DOOR_UNLOCKED);

                SetMapPinState(oMarjolaineMapPin, TRUE);

            }

            else
            {
                SetObjectInteractive(oMarjorlaineDoor, FALSE);
                SetPlaceableState(oMarjorlaineDoor, PLC_STATE_DOOR_LOCKED);

                SetMapPinState(oMarjolaineMapPin, FALSE);
            }

            // This is for the "Pearls Before Swine" quest, where Sergeant Kylon can be killed (or leave)
            /*if ( WR_GetPlotFlag(PLT_DEN200PT_PEARLS_SWINE, KYLON_ATTACKED) )
            {
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_KYLON);
                WR_SetObjectActive(oTarg, FALSE);
            }*/

            int bKylonAttacked      = WR_GetPlotFlag(PLT_DEN200PT_PEARLS_SWINE, KYLON_ATTACKED);
            int bFalconsKilled      = WR_GetPlotFlag(PLT_DEN200PT_PEARLS_SWINE, FALCONS_KILLED);
            int bFalconsSpared      = WR_GetPlotFlag(PLT_DEN200PT_PEARLS_SWINE, FALCONS_LEAVE);
            int bFalconsQuelled     = WR_GetPlotFlag(PLT_DEN200PT_PEARLS_SWINE, FALCONS_QUELLED);
            int bKylonEncountered   = WR_GetPlotFlag(PLT_DEN200PT_PEARLS_SWINE, KYLON_ENCOUNTERED_IN_ALLEY);

            if( ((bFalconsKilled || bFalconsSpared || bFalconsQuelled) && !bKylonEncountered) || bKylonAttacked )
            {
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_KYLON);
                WR_SetObjectActive(oTarg, FALSE);
            }
            else
            {
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_KYLON);
                WR_SetObjectActive(oTarg, TRUE);
            }

            // If Master Ignacio should be in the Gnawed Noble Tavern, deactivate him here.
            if( WR_GetPlotFlag(PLT_DEN200PT_GEN_ASSASSIN, CROW_ASSASIN_LETTER_RECEIVED) &&
                !WR_GetPlotFlag(PLT_QWINN, DEN_IGNACIO_CREATURE_DESTROYED))
            {
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_IGNACIO);
                if( GetObjectActive(oTarg) )
                {
                    // WR_SetObjectActive(oTarg, FALSE);
                    Safe_Destroy_Object(oTarg);
                    WR_SetPlotFlag(PLT_QWINN, DEN_IGNACIO_CREATURE_DESTROYED,TRUE);
                }

            }

            // If Master Ignacio is killed, his buddy Cesar goes away
            if( WR_GetPlotFlag(PLT_DEN200PT_GEN_ASSASSIN, IGNACIO_ATTACKED) )
            {
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_CESAR);
                WR_SetObjectActive(oTarg, FALSE);
            }

            // If Alistair has talked about his sister activate the door
            // Qwinn:  Added check so doesn't get reactivated once it's done
            if ( WR_GetPlotFlag(PLT_GENPT_ALISTAIR_TALKED, ALISTAIR_TALKED_ABOUT_SISTER) &&
                !WR_GetPlotFlag(PLT_GENPT_ALISTAIR_MAIN, ALISTAIR_MAIN_LEAVE_GOLDANAS_HOUSE))
            {
                object oDoorToGoldana = UT_GetNearestObjectByTag(oPC,DEN_IP_OUTSIDE_GOLDANA);
                SetObjectInteractive(oDoorToGoldana, TRUE);
            }

            /* Qwinn:  Disabled this, as we are handling it by a script on the door to prevent
               access if Alistair isn't in the party, since I've enabled party picker in this
               area.
            // if Alistair is not in the party then disable the door
            if(WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY) == FALSE)
            {
                SetObjectInteractive(oDoorToGoldana, FALSE);
            }
            */

            // First Time in Marketplace - flag these
            if ( !GetLocalInt(OBJECT_SELF, ENTERED_FOR_THE_FIRST_TIME) )
            {
                LogTrace(LOG_CHANNEL_PLOT, "First Time in Market.");

                // Set up sideplot quest giver status
                oTarg = UT_GetNearestObjectByTag(oPC,DEN_IP_CHANTERS_BOARD);
                SetPlotGiver(oTarg, TRUE);

            }
            //set up plot giver if chanter quest turn in is possible
            // Qwinn:  added turn marker on if due big reward

            object oDenChanter = UT_GetNearestCreatureByTag(oPC, "den200cr_chanter_denerim");
            SetPlotGiver(oDenChanter, ((ChanterTurnInPossible() == TRUE) ||
                (WR_GetPlotFlag(PLT_DEN200PT_CHANTER, CHANTER_BOARD_QUESTS_ALL_DONE) &&
                 WR_GetPlotFlag(PLT_DEN200PT_CHANTER, CHANTER_BIG_REWARD_PC) == FALSE)));

            // Kylon has another plot avaible
            if ( WR_GetPlotFlag(PLT_DEN200PT_PEARLS_SWINE, PEARL_QUEST_DONE) &&
                !WR_GetPlotFlag(PLT_DEN200PT_CRIMSON, CRIMSON_QUEST_ACCEPTED) )
            {
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_KYLON);
                SetPlotGiver(oTarg, TRUE);
            }

            // Wade's first set of drake scale armor.
            if( WR_GetPlotFlag(PLT_NRDPT_DRAKE_SCALES, CRAFT_FIRST_DRAKE_ARMOR) &&
                !WR_GetPlotFlag(PLT_NRDPT_DRAKE_SCALES, PC_CHOSE_SLOW_CRAFTING) &&
                !WR_GetPlotFlag(PLT_NRDPT_DRAKE_SCALES, CRAFT_FIRST_DRAKE_ARMOR_DONE))
            {

                WR_SetPlotFlag(PLT_NRDPT_DRAKE_SCALES, JOURNAL_FIRST_DRAKE_ARMOR_DONE, TRUE, TRUE);
                WR_SetPlotFlag(PLT_NRDPT_DRAKE_SCALES, TIME_PASSED_QUICK, TRUE, TRUE);

            }

            // Wade's second set of drake scale armor.
            if( WR_GetPlotFlag(PLT_NRDPT_DRAKE_SCALES, CRAFT_SECOND_DRAKE_ARMOR) &&
                !WR_GetPlotFlag(PLT_NRDPT_DRAKE_SCALES, PC_CHOSE_SLOW_CRAFTING_AGAIN) &&
                !WR_GetPlotFlag(PLT_NRDPT_DRAKE_SCALES, CRAFT_SECOND_DRAKE_ARMOR_DONE))
            {

                WR_SetPlotFlag(PLT_NRDPT_DRAKE_SCALES, JOURNAL_SECOND_DRAKE_ARMOR_DONE, TRUE, TRUE);
                WR_SetPlotFlag(PLT_NRDPT_DRAKE_SCALES, TIME_PASSED_QUICK, TRUE, TRUE);

            }

            //******************************************//
            // POST-LANDSMEET CLEANUP FOR LIGHT CONTENT //
            //******************************************//

            // If Ser Landry was talked to, then he is taken care of
            if ( !WR_GetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_POST_LANDSMEET_HANDLING) &&
                WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_QUEST_DONE) )
                WR_SetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_POST_LANDSMEET_HANDLING, TRUE, TRUE);


            //****************************
            // SLIM COULDRY STEALING QUEST
            //****************************
            // Slim Couldry only appears if the PC has Stealth or Pickpocket skills
            if ( ( WR_GetPlotFlag(PLT_GEN00PT_SKILLS, GEN_STEALING_LOW) ||
                WR_GetPlotFlag(PLT_GEN00PT_SKILLS, GEN_STEALTH_LOW) ) &&
                !WR_GetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_APPEARS) &&
                !WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_QUEST_DONE) )
            {
                WR_SetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_APPEARS, TRUE, TRUE);
            }

            // If the Landsmeet has been completed do some clean up (if necessary) for Couldry's quests
            if ( WR_GetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_APPEARS) &&
                WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_QUEST_DONE) &&
                !WR_GetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_LANDSMEET_CLEANUP) )
            {
                WR_SetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_LANDSMEET_CLEANUP, TRUE, TRUE);
            }

            // If "Slim" Couldry has been queued up to be a plot giver, assign it to him on area enter
            if ( WR_GetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_QUEUE_UP_PLOT_GIVER) )
            {
                oTarg = UT_GetNearestCreatureByTag(oPC,DEN_CR_COULDRY);
                SetPlotGiver(oTarg, TRUE);
                WR_SetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_QUEUE_UP_PLOT_GIVER, FALSE, FALSE);
            }

            // If the PC stole from the Lady's Maid, then she's gone after the PC leaves the area
            if ( WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK1, THIEF_PICK1_SUCCESSFUL) &&
                 !WR_GetPlotFlag(PLT_QWINN,DEN_PICK1_CREATURE_DESTROYED))
            {
                oTarg = UT_GetNearestCreatureByTag(oPC,DEN_CR_PICK1_MAID);
                Safe_Destroy_Object(oTarg);
                WR_SetPlotFlag(PLT_QWINN,DEN_PICK1_CREATURE_DESTROYED,TRUE);
            }

            // If the PC stole from the Silversmith, then he's gone after the PC leaves the area
            /* Qwinn:  Moved to the pick3 plot script when mission successful
            if ( WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, THIEF_PICK3_KEY_STOLEN) &&
                 !WR_GetPlotFlag(PLT_QWINN, DEN_PICK3_CREATURES_DESTROYED))
            {
                // UT_TeamAppears(DEN_TEAM_PICK3_SILVERSMITH, FALSE);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den200cr_pick3_silversmith");
                Safe_Destroy_Object(oTarg);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den200cr_pick3_silver_guard");
                Safe_Destroy_Object(oTarg);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den200cr_pick3_silver_grd_2");
                Safe_Destroy_Object(oTarg);
                WR_SetPlotFlag(PLT_QWINN, DEN_PICK3_CREATURES_DESTROYED,TRUE);
            }
            */

            // "Slim" Couldry's Final Pick Pocket Mission Available
            if ( WR_GetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_READY_FOR_FINAL_PICK) &&
                !WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, THIEF_PICK4_ASSIGNED) )
            {
                oTarg = UT_GetNearestCreatureByTag(oPC,DEN_CR_COULDRY);
                SetPlotGiver(oTarg, TRUE);
            }

            // If you were working for Slim Couldry and he went away, he comes back after the Landsmeet is over
            if ( WR_GetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_LEAVES_FOR_NOW) &&
                !WR_GetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_RETURNS_FOR_LAST_SNEAK) &&
                WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_QUEST_DONE) )
            {
                WR_SetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_RETURNS_FOR_LAST_SNEAK, TRUE, TRUE);
            }
            //***********************************
            // END OF SLIM COULDRY STEALING QUEST
            //***********************************

            //Light Content - Red Jenny's door becomes active if the player has the quest
            if (WR_GetPlotFlag(PLT_LITE_TOW_JENNY, TOW_JENNY_QUEST_START) == TRUE && WR_GetPlotFlag(PLT_LITE_TOW_JENNY, TOW_JENNY_BOX_DELIVERED) == FALSE)
            {
                object oDoor = UT_GetNearestObjectByTag(oPC, DEN_IP_LITE_RED_JENNY_DOOR);
                SetObjectInteractive(oDoor, TRUE);
            }

            //Check for Blackstone Irregular's Leadership quest
            if (WR_GetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_QUEST_GIVEN) == TRUE
                && WR_GetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_TAORAN_QUEST_GIVEN) == FALSE
                && WR_GetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_RAELNOR_DEAD) == FALSE)
            {
                //Activate Raelnor and his team
                UT_TeamAppears(LIT_TEAM_FITE_LEADERSHIP_RAELNOR);

            }
            //Light Content - should the mages' collective bag be active
            if (WR_GetPlotFlag(PLT_LITE_MAGE_COLLECTIVE, MAGE_COLLECTIVE_LEARNED_ABOUT) == TRUE)
            {
                //mage bag is now available
                object oMageBag = UT_GetNearestObjectByTag(oPC, LITE_IP_MAGE_BAG_1);
                SetObjectInteractive(oMageBag, TRUE);
                //should mage collective dude by marked?
                object oMage = UT_GetNearestCreatureByTag(oPC, "lite_mage_collective");
                SetPlotGiver(oMage, MageCollectiveTurnInPossible(oPC));
            }

            // Light Content: Problem Solving (Box of Certain Interests)
            WR_SetPlotFlag(PLT_LITE_ROGUE_SOLVING,SOLVING_PLOT_SETUP,TRUE,TRUE);

            // Light Content: Dead Drops (Box of Certain Interests)
            WR_SetPlotFlag(PLT_LITE_ROGUE_PIECES,PIECES_PLOT_SETUP,TRUE,TRUE);

            // Light Content: New Ground (Box of Certain Interests)
            WR_SetPlotFlag(PLT_LITE_ROGUE_NEW_GROUND,NEW_GROUND_PLOT_SETUP,TRUE,TRUE);

            // Light Content - should the mage be interactive?
            // Qwinn:  These two blocks used to be below Alistair talk, moved it up so doesn't get interrupted
            // Also made more efficient by not running GetObject if he's already done
            if(WR_GetPlotFlag(PLT_LITE_MAGE_TERMINATION, TEMINATION_QUEST_GIVEN) &&
               !WR_GetPlotFlag(PLT_LITE_MAGE_TERMINATION, TERMINATION_LEAVE_THREE))
            {
                object oMage = UT_GetNearestCreatureByTag(oPC, "lite_mage_termination3");
                SetObjectInteractive(oMage, TRUE);
            }

            //Should the widows plot assist be on
            if (WR_GetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_QUEST_GIVEN) == TRUE &&
                WR_GetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_LETTER_DELIVERED_3) == FALSE)
            {
                object oWidow = UT_GetNearestCreatureByTag(oPC, LITE_CR_CONDOLENCES_WIDOW3);
                SetPlotGiver(oWidow, TRUE);
            }

            if(WR_GetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_LEAVING_GOLDANAS_HOUSE))
            {
                object oDoorToGoldana = UT_GetNearestObjectByTag(oPC,DEN_IP_OUTSIDE_GOLDANA);
                SetObjectInteractive(oDoorToGoldana,FALSE);
                UT_Talk(oAlistair, oPC);
            }

            if((WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_WARM, TRUE)) &&
                (WR_GetPlotFlag(PLT_GENPT_ALISTAIR_MAIN, ALISTAIR_MAIN_TOLD_TRUTH)) &&
                (!WR_GetPlotFlag(PLT_GENPT_ALISTAIR_TALKED, ALISTAIR_TALKED_ABOUT_SISTER)) &&
                (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY)))
            {
                UT_Talk(oAlistair, oPC);
            }

            // Qwinn:  This content was cut.  Commenting out to help lag/crashes.
            /*
            // Light Content: Slander on Demand
            if((WR_GetPlotFlag(PLT_LITE_LANDRY_SLANDER, LANDRY_SLANDER_LOGHAIN)) ||
               (WR_GetPlotFlag(PLT_LITE_LANDRY_SLANDER, LANDRY_SLANDER_PERSUADE)) ||
               (WR_GetPlotFlag(PLT_LITE_LANDRY_SLANDER, LANDRY_SLANDER_THREAT_OR_KILL)))
            {

                UT_TeamAppears(DEN_TEAM_LANDRY_MARKET_PATRONS);

            }
            */

            //no longer used check for Commander Tavish - interactive always now
            //int     bDefying    = WR_GetPlotFlag(PLT_LITE_MAGE_DEFYING, DEFYING_READY_FOR_TURNIN);
            //int     bJustice    = WR_GetPlotFlag(PLT_LITE_MAGE_JUSTICE, JUSTICE_QUEST_READY_TO_TURNIN);



            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: all game objects in the area have loaded
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {


            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: Scripting
        // When: The last creature of a team dies
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_TEAM_DESTROYED:
        {
            int nTeamID = GetEventInteger(ev, 0); // Team ID


            switch (nTeamID)
            {
                case LIT_TEAM_FITE_LEADERSHIP_RAELNOR:
                {
                    //set that raelnor is dead
                    WR_SetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_RAELNOR_DEAD, TRUE);
                }
            }
        }
    }
    if (!bEventHandled)
    {
        HandleEvent(ev, DEN_SCRIPT_AREA_CORE);
    }
}