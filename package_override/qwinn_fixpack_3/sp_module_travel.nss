/////////////////////////////////////
// Single Player module events
/////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"

// World Map Event Includes
#include "map_events_h"
#include "plt_gen00pt_party"
#include "camp_functions_h"
#include "plt_denpt_map"
#include "plt_mnp000pt_main_events"
#include "plt_denpt_main"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    int bEventHandled = FALSE;
    string sDebug;
    object oPC = GetHero();

    Log_Events("", ev);

    switch(nEventType)
    {

        case EVENT_TYPE_BEGIN_TRAVEL:
        {
            string sSource = GetEventString(ev, 0); // area tag source location
            string sTarget = GetEventString(ev, 1); // area tag target location
            string sWPOverride = GetEventString(ev, 2); // waypoint tag override
            int nSourceTerrain = GetEventInteger(ev, 0);
            int nTargetTerrain = GetEventInteger(ev, 1);
            int nWorldMap = GetEventInteger(ev, 2);
            object oSourceLocation = GetEventObject(ev, 0); // source location object
            if(!IsObjectValid(oSourceLocation))
                Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_BEGIN_TRAVEL", "INVALID SOURCE!");
            else
                Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_BEGIN_TRAVEL", "VALID SOURCE! " + ObjectToString(oSourceLocation));

            if(nWorldMap == 0)
                nWorldMap = WM_WOW;
            Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_BEGIN_TRAVEL", "World Map: " + IntToString(nWorldMap) + ", Source: " + sSource + ", Target: " + sTarget + ", WP: "+ sWPOverride +
                ", Target Terrain: " + IntToString(nTargetTerrain) + ", source loc: " + GetTag(oSourceLocation));

            // If a waypoint override is set for a specific map node, then use
            // that instead of the default 2DA value for the area tag.
            string sWP;
            if ( sWPOverride == "" )
                sWP = WM_GetWorldMapTargetWaypoint(nWorldMap, sSource, sTarget);
            else
                sWP = sWPOverride;

            int bEncounterTransition = FALSE; // TRUE if an event caused an area transition

            object oPlayerArea = GetArea(GetPartyLeader());
            string sPlayerAreaTag = GetTag(oPlayerArea);
            string sStoredArea = GetLocalString(GetModule(), WORLD_MAP_STORED_PRE_CAMP_AREA);
            int nCamp = GetLocalInt(oPlayerArea, AREA_PARTY_CAMP);
            Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_BEGIN_TRAVEL", "Player Area: " + sPlayerAreaTag + ", Stored area: " + sStoredArea);
            // if the area the player tries to travel to is
            if(nCamp && sTarget == sStoredArea)
            {
                // if target area is actually a different area and it's the same as the stored pre-camp area then just transition there
                // (player returns to camp)
                // otherwise, assume the player stays at camp and re-place the party
                if(sTarget == sStoredArea)
                {
                    Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_BEGIN_TRAVEL", "Player returns from camp to previous location - instant transition");
                    UT_DoAreaTransition(sTarget, sWP);
                    // leave last pre-camp location the same
                    return;
                }
            }
            if( (sSource == sTarget && nWorldMap != WM_FADE) || (nCamp && sTarget == WML_AREA_TAG_CAMP))
            {
                if (nCamp)
                {
                    Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_BEGIN_TRAVEL", "travelling from camp to camp - removing party");
                    // remove active party and place them again in area
                    Camp_PlaceFollowersInCamp();
                }

                // restore Denerim map if player stays in Denerim
                if (StringLeft(sSource, 3) == DEN_AR_PREFIX)
                {
                    WR_SetPlotFlag(PLT_DENPT_MAP, DEN_MAP__ACTIVATE_CITY_MAP, TRUE, TRUE);
                    Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_WORLD_MAP_USED", "staying in Denerim, restoring Denerim map");
                }
                else
                {
                    Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_WORLD_MAP_USED", "source and target locations are the same - doing nothing");
                }
                ClosePrimaryWorldMap();
                return;
            }

            if(nWorldMap == WM_WOW)
            {
                Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_WORLD_MAP_USED", "Setting primary map to be wide-open-world, secondary invalid");
                object oWorldMap = GetObjectByTag(WM_WOW_TAG);
                WR_SetWorldMapPrimary(oWorldMap);
                object oInvalid = OBJECT_INVALID;
                WR_SetWorldMapSecondary(oInvalid);
            }

            // Store current world map and source location in case the transition will end in a camp
            // A transition can end in a camp on a normal travel or special encounter
            // First, read the previously stored location before it is overwriten
            object oPreviousLocation = GetLocalObject(GetModule(), WORLD_MAP_CURRENT_LOCATION);
            Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_BEGIN_TRAVEL", "Previous stored location: " + GetTag(oPreviousLocation));
            // should be set only in wide-open-world and not coming from camp
            if(nWorldMap == WM_WOW && !nCamp)
            {
                object oMap = GetObjectByTag(WM_WOW_TAG);
                SetLocalObject(GetModule(), WORLD_MAP_CURRENT_MAP, oMap);
                SetLocalObject(GetModule(), WORLD_MAP_CURRENT_LOCATION, oSourceLocation);
            }

            if(nWorldMap == WM_WOW && !nCamp)
            {
                Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_BEGIN_TRAVEL", "Storing wide-open-world area: " + sTarget);
                SetLocalString(GetModule(), WORLD_MAP_STORED_PRE_CAMP_AREA, sSource);
            }

             // making sure captured armor is removed when traveling to wide-open-world location after plot.
            if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_CAPTURED) &&
                !WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PLOT_COMPLETE))
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PLOT_COMPLETE, TRUE, TRUE);

            // If party camp -> override any other world map logic and jump directly to the camp
            if(sTarget == WOW_AR_CAMP)
            {
                UT_DoAreaTransition(sTarget, WP_CAMP_START);
                return;
            }

            // Store transition info, needs to be re-used when travel-end event is received
            SetLocalString(GetModule(), WM_STORED_AREA, sTarget);
            SetLocalString(GetModule(), WM_STORED_WP, sWP);



            int bDisableEncounter = GetLocalInt(GetModule(), DISABLE_WORLD_MAP_ENCOUNTER);
            if(bDisableEncounter)
                Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_WORLD_MAP_USED", "Skipping any encounter check (plot or random)");

            ////////////////////////////////////////////////////////////////////////////////////
            // Handle World Map Events for each map as it applies
            // If an event caused an area transition, bEncounterTransition will be TRUE
            ////////////////////////////////////////////////////////////////////////////////////


            // set a proper value for PreviousLocation
            // if from camp: keep it
            // if not from camp: set object invalid
            if(!nCamp)
            {
                oPreviousLocation = OBJECT_INVALID;
                Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_WORLD_MAP_USED", "Clearing previous location for this travel");

            }

            if(!bDisableEncounter)
            {
                switch(nWorldMap)
                {
                    case WM_WOW:            bEncounterTransition = WM_HandleEventsWOW(sSource, sTarget, oPreviousLocation); break;
                    case WM_DENERIM:        bEncounterTransition = WM_HandleEventsDEN(sSource, sTarget); break;
                    case WM_UNDERGROUND:    bEncounterTransition = WM_HandleEventsUND(sSource, sTarget); break;
                    case WM_CLIMAX:         bEncounterTransition = WM_HandleEventsCLI(sTarget); break;
                    case WM_FADE:           bEncounterTransition = WM_HandleEventsFADE(); break;
                }

                ////////////////////////////////////////////////////////////////////////////////////
                // RANDOM ENCOUNTERS CHECK
                ////////////////////////////////////////////////////////////////////////////////////

                // 1(true): area transition was done
                // 0(false): area transition was NOT done - clear to check random encounter
                // -1: area transition was NOT done and NOT clear to check random encounter (proceed to normal travel)

                if(bEncounterTransition == 1)
                {
                    SetLocalInt(GetModule(), DISABLE_WORLD_MAP_ENCOUNTER, FALSE); // re-enable encounters
                    Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_BEGIN_TRAVEL", "Plot transition - avoiding normal travel");
                    break; // area transition was done
                }
                else if(bEncounterTransition == 0 && WM_CheckRandomEncounter(nWorldMap, nTargetTerrain, oPreviousLocation) == TRUE)
                {
                    SetLocalInt(GetModule(), DISABLE_WORLD_MAP_ENCOUNTER, FALSE); // re-enable encounters
                    Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_BEGIN_TRAVEL", "Random Encounter - avoiding normal travel");
                    break; // area transition was not done but random encounter triggered
                }
            }
            // re-enable encounters
            SetLocalInt(GetModule(), DISABLE_WORLD_MAP_ENCOUNTER, FALSE);

            ////////////////////////////////////////////////////////////////////////////////////
            // TRANSITION TO DESTINATION
            ////////////////////////////////////////////////////////////////////////////////////

            object oSourceArea = GetArea(GetHero());

            //if(GetLocalInt(oSourceArea, AREA_PARTY_CAMP) == 1)
            //   ShowPartyPickerGUI(); // show the party picker if travelling from a party camp area
            Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_BEGIN_TRAVEL", "TRIGGERING TRAVEL TRANSITION");
            //UT_PCJumpOrAreaTransition(sTarget, sWP);

            // if I'm in camp, start travelling from last place before camp
            // otherwise, start travelling from this location

            if(IsObjectValid(oPreviousLocation))
                Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_WORLD_MAP_USED", "Using previous location as travel source: " + GetTag(oPreviousLocation));

            WorldMapStartTravelling("", "", oPreviousLocation); // leaving empty for no random encounter. actuall destination travel takes place in the TRAVEL_END event
            break;
        }
        case EVENT_TYPE_WORLDMAP_PRETRANSITION:
        {
            string sArea = GetLocalString(GetModule(), WM_STORED_AREA);
            string sWP = GetLocalString(GetModule(), WM_STORED_WP);

            Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_WORLDMAP_PRETRANSITION", "area: " + sArea + ", wp: " + sWP);
            UT_DoAreaTransition(sArea, sWP);
            break;
        }
        case EVENT_TYPE_WORLDMAP_POSTTRANSITION:
        {
            Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_WORLDMAP_POSTTRANSITION", "START");
            WM_HandleCutscenesWOW();

            break;
        }

        ////////////////////////////////////////////////////////////////////////
        // Sent by: Scripts (area transition system)
        // When: The player uses an area transition system that has been flagged
        // as a special "world map transition". This event is sent here so no
        // campaign-specific logic in handled in a generic system
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_TRANSITION_TO_WORLD_MAP:
        {
            Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_TRANSITION_TO_WORLD_MAP", "opening world map");
            string sWorldMap = GetEventString(ev, 0);
            string sTransType = GetEventString(ev, 1);
            string sWorldMapLoc1 = GetEventString(ev, 2);
            string sWorldMapLoc2 = GetEventString(ev, 3);
            string sWorldMapLoc3 = GetEventString(ev, 4);
            string sWorldMapLoc4 = GetEventString(ev, 5);
            string sWorldMapLoc5 = GetEventString(ev, 6);
            object oWorldMapLoc1 = GetObjectByTag(sWorldMapLoc1);
            object oWorldMapLoc2 = GetObjectByTag(sWorldMapLoc2);
            object oWorldMapLoc3 = GetObjectByTag(sWorldMapLoc3);
            object oWorldMapLoc4 = GetObjectByTag(sWorldMapLoc4);
            object oWorldMapLoc5 = GetObjectByTag(sWorldMapLoc5);


            Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_TRANSITION_TO_WORLD_MAP", "Setting the following locations active:");
            if(sWorldMapLoc1 != "")
                Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_TRANSITION_TO_WORLD_MAP", "[" + sWorldMapLoc1 + "]");

            if(sWorldMapLoc2 != "")
                Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_TRANSITION_TO_WORLD_MAP", "[" + sWorldMapLoc2 + "]");

            if(sWorldMapLoc3 != "")
                Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_TRANSITION_TO_WORLD_MAP", "[" + sWorldMapLoc3 + "]");

            if(sWorldMapLoc4 != "")
                Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_TRANSITION_TO_WORLD_MAP", "[" + sWorldMapLoc4 + "]");

            if(sWorldMapLoc5 != "")
                Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_TRANSITION_TO_WORLD_MAP", "[" + sWorldMapLoc5 + "]");

            //resource rWorldMap = R"wmp001dg_abstract_map.dlg";

            int bCancelFlash = FALSE;
            string sTag = GetTag(oWorldMapLoc1);

            if(sTag == WML_WOW_RUINS || sTag == "wml_wow_urn_ruins" || sTag == WML_WOW_RED_CASTLE || sTag == WML_WOW_FOREST)
                bCancelFlash = TRUE;

            if(IsObjectValid(oWorldMapLoc1))
                WR_SetWorldMapLocationStatus(oWorldMapLoc1, WM_LOCATION_ACTIVE, bCancelFlash);
            else
                Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_TRANSITION_TO_WORLD_MAP", "INVALID LOCATION TO SET ACTIVE (1)!", OBJECT_SELF, LOG_SEVERITY_CRITICAL);

    `       if(IsObjectValid(oWorldMapLoc2))
                WR_SetWorldMapLocationStatus(oWorldMapLoc2, WM_LOCATION_ACTIVE, bCancelFlash);
            else
                Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_TRANSITION_TO_WORLD_MAP", "INVALID LOCATION TO SET ACTIVE (2)!", OBJECT_SELF, LOG_SEVERITY_CRITICAL);

            if(IsObjectValid(oWorldMapLoc3))
                WR_SetWorldMapLocationStatus(oWorldMapLoc3, WM_LOCATION_ACTIVE, bCancelFlash);
            else
                Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_TRANSITION_TO_WORLD_MAP", "INVALID LOCATION TO SET ACTIVE (3)!", OBJECT_SELF, LOG_SEVERITY_CRITICAL);

            if(IsObjectValid(oWorldMapLoc4))
                WR_SetWorldMapLocationStatus(oWorldMapLoc4, WM_LOCATION_ACTIVE, bCancelFlash);
            else
                Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_TRANSITION_TO_WORLD_MAP", "INVALID LOCATION TO SET ACTIVE (4)!", OBJECT_SELF, LOG_SEVERITY_CRITICAL);

            if(IsObjectValid(oWorldMapLoc5))
                WR_SetWorldMapLocationStatus(oWorldMapLoc5, WM_LOCATION_ACTIVE, bCancelFlash);
            else
                Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_TRANSITION_TO_WORLD_MAP", "INVALID LOCATION TO SET ACTIVE (5)!", OBJECT_SELF, LOG_SEVERITY_CRITICAL);



            if(sTransType == RANDOM_ENCOUNTER_TRANSITION_ID)
            {
                // exiting random - encounter - finish travel animation
                Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_TRANSITION_TO_WORLD_MAP", "Exiting random encounter");

                WorldMapCompleteRandomEncounter();
                break;
            }
            else if(sTransType == CAMP_EXIT_TRANSITION_ID)
            {
                Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_TRANSITION_TO_WORLD_MAP", "Exiting camp - opening party selection GUI");

                // follower locking logic moved to EVENT_TYPE_PARTYPICKER_INIT, below.

                SetPartyPickerGUIStatus(PP_GUI_STATUS_USE);
                ShowPartyPickerGUI();
                break;
            }

            SetWorldMapGuiStatus(WM_GUI_STATUS_USE);
            OpenPrimaryWorldMap();
            break;
        }
        // just before it opens
        case EVENT_TYPE_PARTYPICKER_INIT:
        {
            // if in the camp then pre-load some followers
            if(!WR_GetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, PLAYER_ENTERED_LOTHERING))
            {
                // Morrigan and Alistair locked into party until player enters Lothering
                object oAlistair = Party_GetFollowerByTag(GEN_FL_ALISTAIR);
                object oMorrigan = Party_GetFollowerByTag(GEN_FL_MORRIGAN);

                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY, TRUE, TRUE);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_IN_PARTY, TRUE, TRUE);
                WR_SetFollowerState(oAlistair, FOLLOWER_STATE_LOCKEDACTIVE);
                WR_SetFollowerState(oMorrigan, FOLLOWER_STATE_LOCKEDACTIVE);
            }
            else if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_EAMON_GOES_WITH_OR_WITHOUT_ALISTAIR)
                && !WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_QUEST_DONE))
            {
                //Alistair locked in party if the Landsmeet is ready and the player hasn't gone yet
                object oAlistair = Party_GetFollowerByTag(GEN_FL_ALISTAIR);

                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY, TRUE, TRUE);
                WR_SetFollowerState(oAlistair, FOLLOWER_STATE_LOCKEDACTIVE, FALSE);
            }

            break;
        }
        case EVENT_TYPE_WORLD_MAP_CLOSED:
        {
            object oPC = GetHero();
            object oArea = GetArea(oPC);
            string sAreaTag = GetTag(oArea);
            int nCloseType = GetEventInteger(ev, 0); // 0 for cancel, 1 for travel
            Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_WORLD_MAP_CLOSED", "Close type: " + IntToString(nCloseType));

            if(nCloseType == 0)
            {
                if (GetLocalInt(oArea, AREA_PARTY_CAMP) == 1)
                {
                    Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_WORLD_MAP_CLOSED", "Camp GUI cancelled in camp - removing party");
                    // remove active party and place them again in area
                    Camp_PlaceFollowersInCamp();
                }
                else if (StringLeft(sAreaTag, 3) == DEN_AR_PREFIX && sAreaTag != "den965ar_qunari_assassin")
                {
                    WR_SetPlotFlag(PLT_DENPT_MAP, DEN_MAP__ACTIVATE_CITY_MAP, TRUE, TRUE);
                }
                else if (StringLeft(sAreaTag, 3) == "orz" && sAreaTag != "orz100ar_mountain_pass")
                {
                    object oUndergroundMap   = GetObjectByTag( WM_UND_TAG );
                    object oWideOpenWorldMap = GetObjectByTag( WM_WOW_TAG );
                    WR_SetWorldMapPrimary( oUndergroundMap );
                    WR_SetWorldMapSecondary( oWideOpenWorldMap );
                }
            }

            break;
        }

    }
    if (!bEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_MODULE_CORE);
    }
}