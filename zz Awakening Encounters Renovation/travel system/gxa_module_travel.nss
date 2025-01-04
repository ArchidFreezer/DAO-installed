/////////////////////////////////////
// Single Player module events
/////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"

const string RANDOM_ENCOUNTER_START_WAYPOINT = "wp_start";
const string RANDOM_ENCOUNTER_TRANSITION_ID = "rand"; // used in the wp field in area transition placeables to flag as a random ecounter (re-use stored transition)
const string CAMP_EXIT_TRANSITION_ID = "camp_exit"; // used to exit the camp

const string WM_WOW_TAG = "gxa_world_map";

string sStartPoint;
string sEndPoint;

// Returns the target waypoint for travel based on 2da tables
string WM_GetWorldMapTargetWaypoint(int nWorldMap, string sSource, string sTarget)
{
    //PrintToLog("START, worldmap: " + IntToString(nWorldMap) + ", source: " + sSource + ", Target: " + sTarget);
    int nWorldMap2da = GetM2DAInt(TABLE_WORLD_MAPS, "TargetWpTableID", nWorldMap);

    int nRows = GetM2DARows(nWorldMap2da);
    string sWP = "";
    //PrintToLog("Targets table rows number: " + IntToString(nRows));
    int i;
    string sCurrentSource;
    int nCurrentRow;
    for(i = 0; i < nRows; i++)
    {
        nCurrentRow = GetM2DARowIdFromRowIndex(nWorldMap2da, i);
        sCurrentSource = GetM2DAString(nWorldMap2da, "SourceLocation", nCurrentRow);
        //PrintToLog("GetWorldMapTargetWaypoint, current row: " + IntToString(nCurrentRow) + ", current source: " + sCurrentSource);
        if(sCurrentSource == sSource || sCurrentSource == "default")
        {
            sWP = GetM2DAString(nWorldMap2da, sTarget, nCurrentRow);
            break;
        }
    }
    if(sWP != "")
    {
        //PrintToLog("Found target WP: " + sWP);
    }
    else
        PrintToLog("GetWorldMapTargetWaypoint: ERROR: could not find target WP");

    return sWP;
}

// Checks if to run a random encounter.
// If yes: run the encounter and return TRUE
// If no: return FALSE
int WM_CheckRandomEncounter(int nWorldMap, int nTerrainType, object oPreviousLocation = OBJECT_INVALID)
{
    //PrintToLog("WM_CheckRandomEncounter: START, terrain type: " + IntToString(nTerrainType));

    // Find the table to use:
    string sEncounterTable = GetM2DAString(30000, "RandTable", nTerrainType);
    int nEncounterChance = GetM2DAInt(30000, "RandChance", nTerrainType);
    string sEncounterBitField = GetM2DAString(30000, "RepeatVar", nTerrainType);
    string sTripsCounterTable = ("gxa_enc_trips");
    int i;

    //PrintToLog("Encounter table: " + sEncounterTable + ", trigger chance: " + IntToString(nEncounterChance) + ", encounters bitfield var name: " + sEncounterBitField);

    int nEncounterBitField = GetLocalInt(GetModule(), sEncounterBitField);

    // Checking global chance for reading encounter table
    int nRand = Random(100) + 1;
    if(nRand > nEncounterChance)
    {
        //PrintToLog("Did not pass random encounter check, result: " + IntToString(nRand));
        return FALSE;
    }


    // Checking chance for triggering random encounter based on the trips counter
    int nTripsCounter = GetLocalInt(GetModule(), WORLD_MAP_TRIPS_COUNT);
    nTripsCounter++;
    SetLocalInt(GetModule(), WORLD_MAP_TRIPS_COUNT, nTripsCounter);
    //PrintToLog("WM_CheckRandomEncounter: Trips count: " + IntToString(nTripsCounter));
    int nTripsCounterTableRows = GetM2DARows(-1, sTripsCounterTable);
    if(nTripsCounter > nTripsCounterTableRows)
    {
        //PrintToLog("Not enough trips entries in table for current trip count - initializing trip count to 1");
        SetLocalInt(GetModule(), WORLD_MAP_TRIPS_COUNT, 1);
    }
    // Get the encounter chance for this specific trip:
    int nEncounterChanceByTrip = GetM2DAInt(-1, "EncounterChance", nTripsCounter, sTripsCounterTable);
    //PrintToLog("Encounter chance based on trip count: " + IntToString(nEncounterChanceByTrip) + "%");
    nRand = Random(100) + 1;
    if(nRand > nEncounterChanceByTrip)
    {
        //PrintToLog("Did not pass random encounter check by trip, result: " + IntToString(nRand));
        return FALSE;
    }

    // Start checking all lines in the table, one by one, until a valid encounter is found
    int nRows = GetM2DARows(-1, sEncounterTable);
    string sLabel;
    int nTriggerChance;
    int nRepeat;
    string sTriggerCondPlot;
    int nTriggerCondFlag;
    int nTriggerFlagSet;
    string sArea;
    int nBitPosition;
    int nCanRunForPRC;

    for(i = 0; i < nRows; i ++)
    {
        sLabel = GetM2DAString(-1, "Label", i, sEncounterTable);
        nTriggerChance = GetM2DAInt(-1, "TriggerChance", i, sEncounterTable);
        nRepeat = GetM2DAInt(-1, "Repeat", i, sEncounterTable);
        sTriggerCondPlot = GetM2DAString(-1, "TriggerCondPlot", i, sEncounterTable);
        nTriggerCondFlag = GetM2DAInt(-1, "TriggerPlotFlag", i, sEncounterTable);
        nTriggerFlagSet = GetM2DAInt(-1, "TriggerFlagSet", i, sEncounterTable);
        sArea = GetM2DAString(-1, "Area", i, sEncounterTable);
        nCanRunForPRC = GetM2DAInt(-1, "CanRunForPRC", i, sEncounterTable);
        nBitPosition = Power(2, i - 1);  // needed for non-repeatable encounters

        if(nTriggerChance == 0)
        {
            //PrintToLog("WM_CheckRandomEncounter: INVALID entry - trigger chance is ZERO");
            continue; // invalid entry
        }
        if(nCanRunForPRC == 0)
        {
            //PrintToLog("WM_CheckRandomEncounter: encounter disabled by PRC override");
            continue; // invalid entry
        }
        /*
        PrintToLog("Encounter data: Label: " + sLabel + ", Chance: " + IntToString(nTriggerChance) +
                                            ", Rep: " + IntToString(nRepeat) +
                                            ", Plot: " + sTriggerCondPlot +
                                            ", Flag: " + IntToString(nTriggerCondFlag) +
                                            ", set/unset: " + IntToString(nTriggerFlagSet) +
                                            ", Area: " + sArea); */
        // Random check
        nRand = Random(100) + 1;
        if(nRand > nTriggerChance)
        {
            //PrintToLog("Encounter did not pass random check, result: " + IntToString(nRand));
            continue;
        }

        // if not allowing repeat - check if the encounter was triggered before
        if(!nRepeat)
        {
            // Find bit field position for this encounter
            // The bit field position is equal to the encounter ID (i) - which should be converted into a binary

            if(nEncounterBitField & nBitPosition)
            {
                //PrintToLog("Non-repeatable encounter triggered before - aborting");
                //PrintToLog("Encounter bit position: " + IntToString(nBitPosition));
                //PrintToLog("EncounterBitField = " + IntToString(nEncounterBitField));
                continue;
            }
        }

        // Check plot condition
        if(sTriggerCondPlot != "")
        {
            if(nTriggerFlagSet == TRUE) // encounter will be aborted if the flag is NOT SET
            {
                if(!WR_GetPlotFlag(sTriggerCondPlot, nTriggerCondFlag))
                {
                    //PrintToLog("Plot flag NOT SET - aborting");
                    continue;
                }
            }
            else // encounter will be aborted if the flag is SET
            {
                if(WR_GetPlotFlag(sTriggerCondPlot, nTriggerCondFlag))
                {
                    //PrintToLog("Plot flag SET - aborting");
                    continue;
                }
            }
        }

        // Encounter is being triggered - set bitfield flag:
        nEncounterBitField = nEncounterBitField | nBitPosition;
        SetLocalInt(GetModule(), sEncounterBitField, nEncounterBitField);

        // And finally - trigger the encounter
        WorldMapStartTravelling(sArea, RANDOM_ENCOUNTER_START_WAYPOINT, oPreviousLocation);
        return TRUE;
    }
    //PrintToLog("Could not trigger any random encounter");
    return FALSE; // no encounter
}

void WM_SetWorldMapGuiStatus()
{
    int nAreaWorldMapEnabled = GetLocalInt(GetArea(GetHero()), AREA_WORLD_MAP_ENABLED);
    //PrintToLog( "Area world map enabled: " + IntToString(nAreaWorldMapEnabled));

    int nModuleWorldMapEnabled = GetLocalInt(GetModule(), MODULE_WORLD_MAP_ENABLED);
    //PrintToLog("Module world map enabled: " + IntToString(nModuleWorldMapEnabled));

    if(nAreaWorldMapEnabled && nModuleWorldMapEnabled)
        SetWorldMapGuiStatus(WM_GUI_STATUS_USE);
    else if(nModuleWorldMapEnabled && !nAreaWorldMapEnabled)
        SetWorldMapGuiStatus(WM_GUI_STATUS_READ_ONLY);
    else // module map not opened
        SetWorldMapGuiStatus(WM_GUI_STATUS_NO_USE);
}

void WM_SetPartyPickerGuiStatus()
{
    object oPC = GetHero();
    object oArea = GetArea(oPC);
    int nPartyPickerEnabled = GetLocalInt(oArea, PARTY_PICKER_ENABLED);

    if(GetLocalInt(oArea, AREA_DEBUG) == 1)
        nPartyPickerEnabled = TRUE;

    if(nPartyPickerEnabled)
        SetPartyPickerGUIStatus(PP_GUI_STATUS_USE);
    else if(GetLocalInt(oArea, AREA_PARTY_CAMP) == 1)
        SetPartyPickerGUIStatus(PP_GUI_STATUS_NO_USE);
    else
        SetPartyPickerGUIStatus(PP_GUI_STATUS_NO_USE);
}

int WM_HandleCutscenesWOW()
{
    int nRet = FALSE;
    //--------------------------------------------------------------------------
    // Check if we need to play cutscenes.
    // NOTE: a cutscene can be followed by a plot or random encounter
    //--------------------------------------------------------------------------
    if(WR_GetPlotFlag("78D19D7452684516B3FFAAEF2D670CFE", 7) && !WR_GetPlotFlag("78D19D7452684516B3FFAAEF2D670CFE", 1)) // stb000pt_main finished | played cutscene
    {
        CS_LoadCutscene(R"ltm_mother_receives_news.cut");
        nRet = TRUE;
        WR_SetPlotFlag("78D19D7452684516B3FFAAEF2D670CFE", 1, TRUE);
    }

    if(WR_GetPlotFlag("F257AEF5B9384AB1AEC559D617C0C86C", 4) && !WR_GetPlotFlag("F257AEF5B9384AB1AEC559D617C0C86C", 5)) // ltl000pt_main finished | played cutscene
    {
        CS_LoadCutscene(R"ltm_mothers_revenge.cut");
        nRet = TRUE;
        WR_SetPlotFlag("F257AEF5B9384AB1AEC559D617C0C86C", 5, TRUE);
    }
    return nRet;
}

void PlotItemsGXA() // various plot item removals, custom function
{
    if (WR_GetPlotFlag("5033A5169AFD4D268124B068CA07323C", 3))
    {
        UT_RemoveItemFromInventory(R"trp100im_ines_herb.uti"); // prickleweed seeds, remove when Ines done
    }
    if (WR_GetPlotFlag("241BDD39381C4F509333A6B1150BEF06", 18) || WR_GetPlotFlag("EA0188BF295F43B08202E9E8DDEAC2F9", 12))
    {
        UT_RemoveItemFromInventory(R"coa100ip_smugglers_key.uti"); // smuggler's cove key, remove when either smugglers or guards done
    }
    if (WR_GetPlotFlag("66462295CD344574AFA868AB21974514", 3) && WR_GetPlotFlag("8FBBD30562D5410EA616652AAD01D1E2", 2))
    {
        UT_RemoveItemFromInventory(R"vgk310ip_key_crypt_ent.uti"); // crypt key, remove when Nathaniel has bow
    }
    if (WR_GetPlotFlag("F88B7C700CAF4FE58DA179588FC444DA", 22))
    {
        UT_RemoveItemFromInventory(R"trp100im_scholar_note.uti"); // battered journal, remove when puzzle finished
    }
    if (WR_GetPlotFlag("08A15707C7964BE2A2E0A91442EEEB82", 2))
    {
        UT_RemoveItemFromInventory(R"trp200im_jail_key.uti"); // silverite mine jail key, remove when mine finished
    }
    if (WR_GetPlotFlag("68546E9B249244D0A4A19EEFFA6360D4", 2))
    {
        UT_RemoveItemFromInventory(R"stb100im_key_to_docks.uti"); // blackmarsh dock key, remove when have sword
    }
    if (WR_GetPlotFlag("E0A6711DE2754883ABC6740F58BC29E9", 2))
    {
        UT_RemoveItemFromInventory(R"coa100im_guardhouse_key.uti"); // guardhouse key, remove when Jacen freed
        UT_RemoveItemFromInventory(R"coa100im_guardhouse_key2.uti");
        UT_RemoveItemFromInventory(R"coa100im_sniper_cage_key.uti");// Jacen's cage key
    }
}

//for fixing up Vigil's Keep
int nVGK1 = WR_GetPlotFlag("2C681ED0363B40769313A929A9B32C65", 1); // voldrik given money
int nVGK2a = WR_GetPlotFlag("542D51BDE496410FAE275169B06ABF3E", 4); // voldrik given granite
int nVGK2b = WR_GetPlotFlag("542D51BDE496410FAE275169B06ABF3E", 6); // voldrik given granite but no men

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    int bEventHandled = FALSE;
    string sDebug;
    object oPC = GetHero();

    switch(nEventType)
    {

        case EVENT_TYPE_BEGIN_TRAVEL:
        {
            string sSource = GetEventString(ev, 0); // area tag source location
            string sTarget = GetEventString(ev, 1); // area tag target location
            string sWPOverride = GetEventString(ev, 2); // waypoint tag override
            int nSourceTerrain = GetEventInteger(ev, 0);
            int nTargetTerrain = GetEventInteger(ev, 1);
            int nWorldMap = 10;
            object oSourceLocation = GetEventObject(ev, 0); // source location object
            if(!IsObjectValid(oSourceLocation))
                PrintToLog("EVENT_TYPE_BEGIN_TRAVEL: INVALID SOURCE!");
            else
                PrintToLog("EVENT_TYPE_BEGIN_TRAVEL: VALID SOURCE! " + ObjectToString(oSourceLocation));

            if ((sTarget == "vgk100ar_exterior") && (nVGK1 || nVGK2a || nVGK2b))
            {
                sTarget = "vgk101ar_exterior";
            }
            if ((sTarget == "vgk100ar_exterior" || sTarget == "vgk101ar_exterior") && (nVGK1 && (nVGK2a || nVGK2b)))
            {
                sTarget = "vgk102ar_exterior";
            }

            if(nWorldMap == 0)
                nWorldMap = 10;
            /*PrintToLog("World Map: " + IntToString(nWorldMap) + ", Source: " + sSource + ", Target: " + sTarget + ", WP: "+ sWPOverride +
                ", Target Terrain: " + IntToString(nTargetTerrain) + ", source loc: " + GetTag(oSourceLocation)); */

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
            //string sStoredArea = GetLocalString(GetModule(), WORLD_MAP_STORED_PRE_CAMP_AREA);

            int nCamp = GetLocalInt(oPlayerArea, AREA_PARTY_CAMP);

            if(sSource == sTarget)
            {
                //PrintToLog("EVENT_TYPE_WORLD_MAP_USED: source and target locations are the same - doing nothing");
                ClosePrimaryWorldMap();
                return;
            }

            // Store current world map and source location in case the transition will end in a camp
            // A transition can end in a camp on a normal travel or special encounter
            // First, read the previously stored location before it is overwriten
            object oPreviousLocation = GetLocalObject(GetModule(), WORLD_MAP_CURRENT_LOCATION);
            //PrintToLog( "EVENT_TYPE_BEGIN_TRAVEL: Previous stored location: " + GetTag(oPreviousLocation));
            // should be set only in wide-open-world and not coming from camp
            if(nWorldMap == WM_WOW && !nCamp)
            {
                object oMap = GetObjectByTag(WM_WOW_TAG);
                SetLocalObject(GetModule(), WORLD_MAP_CURRENT_MAP, oMap);
                SetLocalObject(GetModule(), WORLD_MAP_CURRENT_LOCATION, oSourceLocation);
            }

            if(nWorldMap == WM_WOW && !nCamp)
            {
                //PrintToLog("EVENT_TYPE_BEGIN_TRAVEL: Storing wide-open-world area: " + sTarget);
                SetLocalString(GetModule(), WORLD_MAP_STORED_PRE_CAMP_AREA, sSource);
            }


            // Store transition info, needs to be re-used when travel-end event is received
            SetLocalString(GetModule(), WM_STORED_AREA, sTarget);
            SetLocalString(GetModule(), WM_STORED_WP, sWP);

            int bDisableEncounter;

            //diable random encounters once final quests begun and after cutscenes:
            if(WR_GetPlotFlag("78D19D7452684516B3FFAAEF2D670CFE", 7) && !WR_GetPlotFlag("78D19D7452684516B3FFAAEF2D670CFE", 1)) // stb000pt_main finished | played cutscene
            {
                bDisableEncounter = TRUE;
                //PrintToLog("random encounters disabled");
            }
            else if(WR_GetPlotFlag("F257AEF5B9384AB1AEC559D617C0C86C", 4) && !WR_GetPlotFlag("F257AEF5B9384AB1AEC559D617C0C86C", 5)) // ltl000pt_main finished | played cutscene
            {
                bDisableEncounter = TRUE;
                //PrintToLog("random encounters disabled");
            }
            else if (WR_GetPlotFlag("1C7395DEAAC14F889A5D41F86854F48B", 7) || WR_GetPlotFlag("1C7395DEAAC14F889A5D41F86854F48B", 25))  //amaranthine saved or abandoned
            {
                bDisableEncounter = TRUE;
                //PrintToLog("random encounters disabled");
            }
            else
            {
                bDisableEncounter = GetLocalInt(GetModule(), DISABLE_WORLD_MAP_ENCOUNTER);
            }

            if(bDisableEncounter)
                PrintToLog("Skipping any encounter check (plot or random)");

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
                //PrintToLog("Clearing previous location for this travel");

            }

            if(!bDisableEncounter)
            {
                if(bEncounterTransition == 0 && WM_CheckRandomEncounter(nWorldMap, nTargetTerrain, oPreviousLocation) == TRUE)
                {
                    SetLocalInt(GetModule(), DISABLE_WORLD_MAP_ENCOUNTER, FALSE); // re-enable encounters
                    //PrintToLog("Random Encounter - avoiding normal travel");
                    break; // area transition was not done but random encounter triggered
                }
            }
            // re-enable encounters
            SetLocalInt(GetModule(), DISABLE_WORLD_MAP_ENCOUNTER, FALSE);

            ////////////////////////////////////////////////////////////////////////////////////
            // TRANSITION TO DESTINATION
            ////////////////////////////////////////////////////////////////////////////////////

            object oSourceArea = GetArea(GetHero());

            //PrintToLog("TRIGGERING TRAVEL TRANSITION");

            //if(IsObjectValid(oPreviousLocation))
                //PrintToLog("Using previous location as travel source: " + GetTag(oPreviousLocation));
            PlotItemsGXA();
            WorldMapStartTravelling("", "", oPreviousLocation); // leaving empty for no random encounter. actual destination travel takes place in the TRAVEL_END event

            break;
        }
        case EVENT_TYPE_WORLDMAP_PRETRANSITION:
        {
            string sArea = GetLocalString(GetModule(), WM_STORED_AREA);
            string sWP = GetLocalString(GetModule(), WM_STORED_WP);

            //PrintToLog("EVENT_TYPE_WORLDMAP_PRETRANSITION, area: " + sArea + ", wp: " + sWP);
            UT_DoAreaTransition(sArea, sWP);
            break;
        }
        case EVENT_TYPE_WORLDMAP_POSTTRANSITION:
        {
            //PrintToLog("EVENT_TYPE_WORLDMAP_POSTTRANSITION, START");
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
            //PrintToLog("opening world map");
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


            /*PrintToLog("Setting the following locations active:");
            if(sWorldMapLoc1 != "")
                PrintToLog("[" + sWorldMapLoc1 + "]");

            if(sWorldMapLoc2 != "")
                PrintToLog("[" + sWorldMapLoc2 + "]");

            if(sWorldMapLoc3 != "")
                PrintToLog("[" + sWorldMapLoc3 + "]");

            if(sWorldMapLoc4 != "")
                PrintToLog("[" + sWorldMapLoc4 + "]");

            if(sWorldMapLoc5 != "")
                PrintToLog("[" + sWorldMapLoc5 + "]"); */

            int bCancelFlash = FALSE;
            string sTag = GetTag(oWorldMapLoc1);

            if(IsObjectValid(oWorldMapLoc1))
                WR_SetWorldMapLocationStatus(oWorldMapLoc1, WM_LOCATION_ACTIVE, bCancelFlash);
            else
                PrintToLog("INVALID LOCATION TO SET ACTIVE (1)!");

    `       if(IsObjectValid(oWorldMapLoc2))
                WR_SetWorldMapLocationStatus(oWorldMapLoc2, WM_LOCATION_ACTIVE, bCancelFlash);
            else
                PrintToLog("INVALID LOCATION TO SET ACTIVE (2)!");

            if(IsObjectValid(oWorldMapLoc3))
                WR_SetWorldMapLocationStatus(oWorldMapLoc3, WM_LOCATION_ACTIVE, bCancelFlash);
            else
                PrintToLog("INVALID LOCATION TO SET ACTIVE (3)!");

            if(IsObjectValid(oWorldMapLoc4))
                WR_SetWorldMapLocationStatus(oWorldMapLoc4, WM_LOCATION_ACTIVE, bCancelFlash);
            else
                PrintToLog("INVALID LOCATION TO SET ACTIVE (4)!");

            if(IsObjectValid(oWorldMapLoc5))
                WR_SetWorldMapLocationStatus(oWorldMapLoc5, WM_LOCATION_ACTIVE, bCancelFlash);
            else
                PrintToLog("INVALID LOCATION TO SET ACTIVE (5)!");



            if(sTransType == RANDOM_ENCOUNTER_TRANSITION_ID)
            {
                // exiting random - encounter - finish travel animation
                //PrintToLog("Exiting random encounter");

                WorldMapCompleteRandomEncounter();
                break;
            }
            else if(sTransType == CAMP_EXIT_TRANSITION_ID)
            {
                //PrintToLog("Exiting camp - opening party selection GUI");
                SetPartyPickerGUIStatus(PP_GUI_STATUS_USE);
                ShowPartyPickerGUI();
                break;
            }

            SetWorldMapGuiStatus(WM_GUI_STATUS_USE);
            OpenPrimaryWorldMap();
            break;
        }
    }
    if (!bEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_MODULE_CORE);
    }
}