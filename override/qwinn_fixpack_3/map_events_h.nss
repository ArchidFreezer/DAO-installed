//==============================================================================
/*

     World Map
     -> Wide Open World Event Handler Function

*/
//------------------------------------------------------------------------------
// Created On: November 21, 2007
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "cir_functions_h"
//#include "orz_constants_h"
#include "world_maps_h"
#include "campaign_h"
#include "cutscenes_h"
#include "cli_constants_h"
#include "camp_constants_h"
#include "plt_denpt_map"
#include "arl_constants_h"

#include "den_functions_h"
#include "plt_cli400pt_city_gates"

#include "plt_gen00pt_stealing"
#include "plt_den200pt_pearls_swine"
#include "plt_den200pt_ser_landry"
#include "plt_den200pt_thief_sneak4"
#include "plt_lite_rogue_new_ground"
#include "plt_lite_rogue_decisions"
#include "plt_denpt_main"
#include "plt_pre100pt_mabari"
#include "plt_orz510pt_legion"
#include "plt_mnp000pt_main_events"
#include "plt_arl100pt_siege_prep"
#include "plt_arl200pt_remove_demon"
#include "plt_arl100pt_enter_castle"
#include "plt_gen00pt_party"
#include "plt_pre100pt_generic"
#include "plt_genpt_wynne_events"
#include "plt_genpt_leliana_main"
#include "plt_genpt_app_leliana"
#include "plt_cod_cha_anora"
#include "plt_cod_cha_howe"
#include "plt_cod_cha_loghain"
#include "plt_cod_cha_teagan"
#include "plt_cod_cha_zevran"
#include "plt_mnp000pt_generic"

// Qwinn added
#include "plt_genpt_zevran_main"

int WM_HandleCutscenesWOW()
{
    int nRet = FALSE;
    //--------------------------------------------------------------------------
    // Check if we need to play cutscenes.
    // NOTE: a cutscene can be followed by a plot or random encounter
    //--------------------------------------------------------------------------

    if(WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_PC_LEFT_REDCLIFFE_AFTER_TALKING_TO_TEAGAN) == TRUE
        && WR_GetPlotFlag(PLT_MNP000PT_MAIN_EVENTS, REDCLIFFE_DESTROYED) == FALSE)
    {
        WR_SetPlotFlag(PLT_MNP000PT_MAIN_EVENTS, REDCLIFFE_DESTROYED, TRUE);
        CS_LoadCutscene(R"arl100cs_sunset_alt.cut");
        nRet = TRUE;
        WR_SetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_VILLAGE_ABANDONED, TRUE, TRUE);
    }

    if(!WR_GetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, LOGHAIN_EVENT_ONE))
    {
        // Should trigger when entering/travelling to Lothering
        WR_SetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, LOGHAIN_EVENT_ONE, TRUE);

        Log_Trace(LOG_CHANNEL_PLOT, "map_events_h", "WORLD MAP: triggering Loghain event I (cutscene) ");
        WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_MAIN, TRUE);
        WR_SetPlotFlag(PLT_COD_CHA_LOGHAIN, COD_CHA_LOGHAIN_SECOND_QUOTE, TRUE);
        WR_SetPlotFlag(PLT_COD_CHA_LOGHAIN, COD_CHA_LOGHAIN_QUOTE, FALSE);
        WR_SetPlotFlag(PLT_COD_CHA_LOGHAIN, COD_CHA_LOGHAIN_CIVIL_UNREST, TRUE);
        WR_SetPlotFlag(PLT_COD_CHA_TEAGAN, COD_CHA_TEAGAN_MAIN, TRUE);

        nRet = TRUE;
        CS_LoadCutscene(CUTSCENE_LOGHAIN_EVENT_ONE);
    }

    else if(!WR_GetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, LOGHAIN_EVENT_TWO) &&
             WR_GetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, PLAYER_FINISHED_FIRST_MAJOR_PLOT))
    {
        WR_SetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, LOGHAIN_EVENT_TWO, TRUE);

        Log_Trace(LOG_CHANNEL_PLOT, "map_events_h", "WORLD MAP: triggering Loghain event II (cutscene)");
        if(!WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_HUMAN_NOBLE))
        {
            WR_SetPlotFlag(PLT_COD_CHA_HOWE, COD_CHA_HOWE_QUOTE_EVERYONE_ELSE, TRUE);
            WR_SetPlotFlag(PLT_COD_CHA_HOWE, COD_CHA_HOWE_MAIN, TRUE);
        }

        WR_SetPlotFlag(PLT_COD_CHA_LOGHAIN, COD_CHA_LOGHAIN_CIVIL_WAR, TRUE);
        WR_SetPlotFlag(PLT_COD_CHA_ZEVRAN, COD_CHA_ZEVRAN_QUOTE_1, TRUE);
        WR_SetPlotFlag(PLT_COD_CHA_ZEVRAN, COD_CHA_ZEVRAN_MAIN, TRUE);

        nRet = TRUE;
        CS_LoadCutscene(CUTSCENE_LOGHAIN_EVENT_TWO);

    }

    else if(!WR_GetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, LOGHAIN_EVENT_THREE) &&
             WR_GetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, PLAYER_FINISHED_SECOND_MAJOR_PLOT))
    {
        WR_SetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, LOGHAIN_EVENT_THREE, TRUE);

        Log_Trace(LOG_CHANNEL_PLOT, "map_events_h", "WORLD MAP: triggering Loghain event III (cutscene) ");

        nRet = TRUE;
        CS_LoadCutscene(CUTSCENE_LOGHAIN_EVENT_THREE);
    }

    // MOVED TO AREA LOAD

    /*else if(!WR_GetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, ARCHDEMON_EVENT_TWO) &&
             WR_GetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, PLAYER_FINISHED_THIRD_MAJOR_PLOT))
    {
        WR_SetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, ARCHDEMON_EVENT_TWO, TRUE);

        Log_Trace(LOG_CHANNEL_PLOT, "map_events_h", "WORLD MAP: triggering Archdemon event II (cutscene) ");

        nRet = TRUE;
        CS_LoadCutscene(CUTSCENE_ARCHDEMON_EVENT_TWO);
    }*/

    return nRet;
}

// Returns:
// 1(true): area transition was done
// 0(false): area transition was NOT done - clear to check random encounter
// -1: area transition was NOT done and NOT clear to check random encounter (proceed to normal travel)
int WM_HandleEventsWOW(string sSourceArea, string sTargetArea, object oPreviousLocation);
int WM_HandleEventsWOW(string sSourceArea, string sTargetArea, object oPreviousLocation)
{

    int bDoAreaTransition = FALSE; // Set if UT_DoAreaTransition is called

    //signal that the prelude areas are no longer needed (largely for Morrigan)
    if (!WR_GetPlotFlag(PLT_PRE100PT_GENERIC, PRE_GENERIC_PARTY_LEFT_PRELUDE_AREAS))
    {
        WR_SetPlotFlag(PLT_PRE100PT_GENERIC, PRE_GENERIC_PARTY_LEFT_PRELUDE_AREAS, TRUE);
    }

    if((sSourceArea == ARL_AR_REDCLIFFE_VILLAGE && sTargetArea == ARL_AR_CASTLE_COURTYARD) ||
        sSourceArea == ARL_AR_CASTLE_COURTYARD && sTargetArea == ARL_AR_REDCLIFFE_VILLAGE)
    {
        Log_Trace(LOG_CHANNEL_PLOT, "map_events_h", "WORLD MAP: Player travels between redcliffe castle and village - NOT checking for special events (cutscenes can still run)");
        return -1;
    }
    else if((sSourceArea == CIR_AR_LAKE_CALENHAD && sTargetArea == CIR_AR_TOWER_FIRST_FLOOR) ||
        sSourceArea == CIR_AR_TOWER_FIRST_FLOOR && sTargetArea == CIR_AR_LAKE_CALENHAD)
    {
        Log_Trace(LOG_CHANNEL_PLOT, "map_events_h", "WORLD MAP: Player travels between docks and circle tower - NOT checking for special events (cutscenes can still run)");
        return -1;
    }

    //If the player leaves Redcliffe village before the battle, the village is destroyed.
    int bPCSpokeToTeagan = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_PC_BROUGHT_TO_TEAGAN, TRUE);
    int bBattleStarted = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_SIEGE_BEGINS, TRUE);
    int bPCLeft = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_PC_LEFT_REDCLIFFE_AFTER_TALKING_TO_TEAGAN, TRUE);
    if ((bPCSpokeToTeagan == TRUE) && (bBattleStarted == FALSE) && (bPCLeft == FALSE))
    {
        if ((sTargetArea != WML_WOW_RED_CASTLE) && (sTargetArea != WML_WOW_REDCLIFFE) && (sTargetArea != WML_AREA_TAG_CAMP))
        {
            WR_SetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_PC_LEFT_REDCLIFFE_AFTER_TALKING_TO_TEAGAN, TRUE, TRUE);

            //Remove now useless plot items.
            UT_RemoveItemFromInventory(ARL_R_IT_STASH);
            UT_RemoveItemFromInventory(ARL_R_IT_BARREL_OF_LAMP_OIL);
            UT_RemoveItemFromInventory(ARL_R_IT_OWEN_STASH_KEY);
        }

    }

    //If the player leaves the Redcliffe area after the hall confrontation, set a flag.
    int bLeftRedcliffe = WR_GetPlotFlag(PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_PC_LEFT_REDCLIFFE);
    int bConfrontedConnor = WR_GetPlotFlag(PLT_ARL100PT_ENTER_CASTLE, ARL_ENTER_CASTLE_PC_LEARNS_THAT_CONNOR_IS_RESPONSIBLE);
    if ((bLeftRedcliffe == FALSE) && (bConfrontedConnor == TRUE))
    {
        if ((sTargetArea != WML_WOW_RED_CASTLE) && (sTargetArea != WML_WOW_REDCLIFFE) && (sTargetArea != WML_AREA_TAG_CAMP))
        {
            WR_SetPlotFlag(PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_PC_LEFT_REDCLIFFE, TRUE, TRUE);
        }
    }

    //--------------------------------------------------------------------------
    // Check for plot encounters
    // NOTE: if a plot encounter triggers then a random encounter can NOT
    //       trigger.
    //--------------------------------------------------------------------------


    if(WR_GetPlotFlag( PLT_PRE100PT_MABARI, PRE_MABARI_DOG_HEALED) &&
       !WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_DOG_RECRUITED) &&
       !WR_GetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, DOG_JOINS_PARTY))
    {
        WR_SetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, DOG_JOINS_PARTY, TRUE);

        Log_Trace(LOG_CHANNEL_PLOT, "map_events_h", "WORLD MAP: triggering dog encounter!");
        // Jump player to special dog encounter area:
        bDoAreaTransition = TRUE;
        //UT_DoAreaTransition(RAN_AR_DOG, RANDOM_ENCOUNTER_START_WAYPOINT);
        WorldMapStartTravelling(RAN_AR_DOG, RANDOM_ENCOUNTER_START_WAYPOINT, oPreviousLocation);
    }

    //else if(!WR_GetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, LOTHERING_LC_OPEN) &&
    //         WR_GetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, ARCHDEMON_EVENT_ONE))
    //{
    //    WR_SetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, LOTHERING_LC_OPEN, TRUE);

    //    Log_Trace(LOG_CHANNEL_PLOT, "map_events_h", "WORLD MAP: triggering lothering-lc encounter");
    //    bDoAreaTransition = TRUE;
    //    SetLocalInt(GetModule(), DISABLE_WORLD_MAP_ENCOUNTER, TRUE); // we don't want an encounter right after this one
    //    UT_DoAreaTransition(RAN_AR_OPEN_LOTHERING_LC, RANDOM_ENCOUNTER_START_WAYPOINT);
    //}

    else if(!WR_GetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, ZEVRAN_ATTACK_ONE) &&
             WR_GetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, LOGHAIN_EVENT_TWO))
    {
        WR_SetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, ZEVRAN_ATTACK_ONE, TRUE);

        Log_Trace(LOG_CHANNEL_PLOT, "map_events_h", "WORLD MAP: triggering Zevran encounter I");
        bDoAreaTransition = TRUE;
        SetLocalInt(GetModule(), DISABLE_WORLD_MAP_ENCOUNTER, TRUE); // we don't want an encounter right after this one
        //UT_DoAreaTransition(RAN_AR_ZEVRAN_1, RANDOM_ENCOUNTER_START_WAYPOINT);
        WorldMapStartTravelling(RAN_AR_ZEVRAN_1, RANDOM_ENCOUNTER_START_WAYPOINT, oPreviousLocation);
    }

    else if(!WR_GetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, ARCHDEMON_EVENT_THREE) &&
             WR_GetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, PLAYER_FINISHED_FOURTH_MAJOR_PLOT) &&
            sSourceArea != CAM_AR_ARCH3 && sSourceArea != CAM_AR_CAMP_PLAINS)
    {
        WR_SetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, ARCHDEMON_EVENT_THREE, TRUE);

        Log_Trace(LOG_CHANNEL_PLOT, "map_events_h", "WORLD MAP: triggering Archdemon event III (encounter in camp) ");

        bDoAreaTransition = TRUE;
        SetLocalInt(GetModule(), DISABLE_WORLD_MAP_ENCOUNTER, TRUE); // we don't want an encounter right after this one
        UT_DoAreaTransition(CAM_AR_ARCH3, RANDOM_ENCOUNTER_START_WAYPOINT);
        //WorldMapStartTravelling(CAM_AR_ARCH3, RANDOM_ENCOUNTER_START_WAYPOINT);
    }
    else if(WR_GetPlotFlag(PLT_GENPT_WYNNE_EVENTS, WYNNE_ENC_ELIGIBLE_COLLAPSE) &&
            !WR_GetPlotFlag(PLT_GENPT_WYNNE_EVENTS, WYNNE_ENC_COLLAPSE_TRIGGERED) &&
            WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_PARTY))
    {
        WR_SetPlotFlag(PLT_GENPT_WYNNE_EVENTS, WYNNE_ENC_COLLAPSE_TRIGGERED, TRUE);
        bDoAreaTransition = TRUE;
        SetLocalInt(GetModule(), DISABLE_WORLD_MAP_ENCOUNTER, TRUE); // we don't want an encounter right after this one
        //UT_DoAreaTransition(RAN_AR_WYNNE_1, RANDOM_ENCOUNTER_START_WAYPOINT);
        WorldMapStartTravelling(RAN_AR_WYNNE_1, RANDOM_ENCOUNTER_START_WAYPOINT, oPreviousLocation);
    }
    else if(WR_GetPlotFlag(PLT_GENPT_WYNNE_EVENTS, WYNNE_ENC_ELIGIBLE_FIRST_SUMMON) &&
            !WR_GetPlotFlag(PLT_GENPT_WYNNE_EVENTS, WYNNE_ENC_FIRST_SUMMON_TRIGGERED) &&
            WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_PARTY))
    {
        WR_SetPlotFlag(PLT_GENPT_WYNNE_EVENTS, WYNNE_ENC_FIRST_SUMMON_TRIGGERED, TRUE);
        bDoAreaTransition = TRUE;
        SetLocalInt(GetModule(), DISABLE_WORLD_MAP_ENCOUNTER, TRUE); // we don't want an encounter right after this one
        //UT_DoAreaTransition(RAN_AR_WYNNE_2, RANDOM_ENCOUNTER_START_WAYPOINT);
        WorldMapStartTravelling(RAN_AR_WYNNE_2, RANDOM_ENCOUNTER_START_WAYPOINT, oPreviousLocation);
    }
    else if(WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_ASSASSIN_ENC_START))
    {
        bDoAreaTransition = TRUE;
        Log_Trace_Scripting_Error(GetCurrentScriptName(), "Assasin Encounter triggered");
        SetLocalInt(GetModule(), DISABLE_WORLD_MAP_ENCOUNTER, TRUE); // we don't want an encounter right after this one
        //UT_DoAreaTransition(RAN_AR_LELIANA, RANDOM_ENCOUNTER_START_WAYPOINT);
        WorldMapStartTravelling(RAN_AR_LELIANA, RANDOM_ENCOUNTER_START_WAYPOINT, oPreviousLocation);
    }
        Log_Trace_Scripting_Error(GetCurrentScriptName(), "Bypassed Assasin Encounter");



//  else if(!WR_GetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, ARCHDEMON_EVENT_FOUR) &&
//           WR_GetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, PLAYER_FINISHED_FIFTH_MAJOR_PLOT))
//  {
//      WR_SetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, ARCHDEMON_EVENT_FOUR, TRUE);

//      Log_Plot("WORLD MAP: triggering Archdemon event IV (encounter) ", LOG_LEVEL_WARNING);

//      bDoAreaTransition = TRUE;
 //       UT_DoAreaTransition(CAM_AR_ARCH4, RANDOM_ENCOUNTER_START_WAYPOINT);
 // }


    //--------------------------------------------------------------------------

    return bDoAreaTransition;

}


int WM_HandleEventsUND(string sSourceArea, string sTargetArea);
int WM_HandleEventsUND(string sSourceArea, string sTargetArea)
{

    int bDoAreaTransition = FALSE; // Set if UT_DoAreaTransition is called

    //--------------------------------------------------------------------------
    // Check if we need to play cutscenes.
    // NOTE: a cutscene can be followed by a plot or random encounter
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    // Check for plot encounters
    // NOTE: if a plot encounter triggers then a random encounter can NOT
    //       trigger.
    //--------------------------------------------------------------------------

    // Legion of the Dead Plot Complete Encounter
    //  ----> Legion of the dead plot has been cut.

    return bDoAreaTransition;

}


int WM_HandleEventsCLI(string sTarget);
int WM_HandleEventsCLI(string sTarget)
{

    int bDoAreaTransition = FALSE; // Set if UT_DoAreaTransition is called

    //--------------------------------------------------------------------------
    // Check if we need to play cutscenes.
    // NOTE: a cutscene can be followed by a plot or random encounter
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    // Check for plot encounters
    // NOTE: if a plot encounter triggers then a random encounter can NOT
    //       trigger.
    //--------------------------------------------------------------------------

    // do not trigger the encounter if the player did not leave anyone beyond to defend
    object oLeader = GetLocalObject(GetModule(), PARTY_LEADER_STORE);

    if(sTarget == CLI_PALACE_DISTRICT && !WR_GetPlotFlag(PLT_CLI400PT_CITY_GATES, CLI_CITY_GATES_ATTACK_START, TRUE)
    && !WR_GetPlotFlag(PLT_CLIPT_MAIN, CLI_MAIN_NO_GATE_DEFENSE) && IsObjectValid(oLeader) && oLeader != GetHero())
    {
        bDoAreaTransition = TRUE;
        SetLoadHint(3, 206);
        SetLocalInt(GetModule(), AREA_LOAD_HINT, 0);
        //UT_DoAreaTransition(CLI_CITY_GATES_DEFENSE, CLI_WP_CITY_GATES_DEFENCE_START);
        WorldMapStartTravelling(CLI_CITY_GATES_DEFENSE, CLI_WP_CITY_GATES_DEFENCE_START);
    }

    return bDoAreaTransition;

}


int WM_HandleEventsDEN(string sSourceArea, string sTargetArea);
int WM_HandleEventsDEN(string sSourceArea, string sTargetArea)
{

    int bDoAreaTransition = FALSE; // Set if UT_DoAreaTransition is called

    //--------------------------------------------------------------------------
    // Check if we need to play cutscenes.
    // NOTE: a cutscene can be followed by a plot or random encounter
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    // Check for plot encounters
    // NOTE: if a plot encounter triggers then a random encounter can NOT
    //       trigger.
    //--------------------------------------------------------------------------

    // These are for the "Pearls Before Swine" subquest
    int bFalconsKilled      = WR_GetPlotFlag(PLT_DEN200PT_PEARLS_SWINE, FALCONS_KILLED);
    int bFalconsSpared      = WR_GetPlotFlag(PLT_DEN200PT_PEARLS_SWINE, FALCONS_LEAVE);
    int bFalconsQuelled     = WR_GetPlotFlag(PLT_DEN200PT_PEARLS_SWINE, FALCONS_QUELLED);
    int bKylonEncountered   = WR_GetPlotFlag(PLT_DEN200PT_PEARLS_SWINE, KYLON_ENCOUNTERED_IN_ALLEY);

    if (sSourceArea == DEN_AR_MARKET && sTargetArea == DEN_AR_EAMON_ESTATE_1)
    {
       bDoAreaTransition = TRUE;
       WorldMapStartTravelling();
    }
    else if (sSourceArea == DEN_AR_MARKET
            && WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_OPENING_DONE)
            && !WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_PLAYER_AMBUSHED_BY_CROWS)
            // Qwinn
            // && WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_RECRUITED))
            && (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_RECRUITED) ||
                WR_GetPlotFlag(PLT_GENPT_ZEVRAN_MAIN, ZEVRAN_MAIN_KILLED_BY_PLAYER) ||
                WR_GetPlotFlag(PLT_GENPT_ZEVRAN_MAIN, ZEVRAN_MAIN_LEAVES_FOR_GOOD)))
    {
        WR_SetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_PLAYER_AMBUSHED_BY_CROWS, TRUE, TRUE);
        bDoAreaTransition = TRUE;
        WorldMapStartTravelling(DEN_AR_CROW_ENCOUNTER, DEN_WP_CROW_ENCOUNTER_START);
    }

    /*  Disabled at Yaron's request
    if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_OPENING_DONE)
        && !WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_LEFT_MARKET))
    {
        WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_LEFT_MARKET, TRUE, FALSE);
    } */

    // This is the forced encounter in the "Pearls Before Swine" quest after fighting in the Pearl brothel.
    // If there's ever any DENERIM MARKET specific area overrides, this should be on top of those or the
    // quest breaks.
    else if ( (bFalconsKilled || bFalconsSpared || bFalconsQuelled) && !bKylonEncountered )
    {
        WR_SetPlotFlag(PLT_DEN200PT_PEARLS_SWINE, KYLON_ENCOUNTERED_IN_ALLEY, TRUE, TRUE);

        bDoAreaTransition = TRUE;
        //UT_DoAreaTransition(DEN_AR_FALCON_ATTACK, DEN_WP_FALCON_ATTACK);
        WorldMapStartTravelling(DEN_AR_FALCON_ATTACK, DEN_WP_FALCON_ATTACK);
    }
    else if (sTargetArea == DEN_AR_MARKET
            && !WR_GetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_AMBUSHED_PC)
            && WR_GetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_DUEL_REFUSED) )
    {
        // If the PC refused Landry's duel, then he will ambush the PC the next time he goes to the Market

        {
            WR_SetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_AMBUSHED_PC, TRUE, TRUE);

            bDoAreaTransition = TRUE;
            //UT_DoAreaTransition(DEN_AR_LANDRY_ATTACK, DEN_WP_LANDRY_ATTACK);
            WorldMapStartTravelling(DEN_AR_LANDRY_ATTACK, DEN_WP_LANDRY_ATTACK);
        }
    }
    /*else if (sTargetArea == DEN_AR_FRANDEREL_ESTATE
        && WR_GetPlotFlag(PLT_DEN200PT_THIEF_SNEAK4, THIEF_SNEAK4_ASSIGNED))
    {
        bDoAreaTransition = TRUE;
        //UT_DoAreaTransition(DEN_AR_FRANDEREL_ESTATE_2, DEN_WP_FRANDEREL_ESTATE_2);
        WorldMapStartTravelling(DEN_AR_FRANDEREL_ESTATE_2, DEN_WP_FRANDEREL_ESTATE_2);
    }*/
    // Rogue Light Content: New Ground
    else if (WR_GetPlotFlag(PLT_LITE_ROGUE_NEW_GROUND,NEW_GROUND_RANDOM_ENCOUNTER_ACTIVE))
    {
        WR_SetPlotFlag(PLT_LITE_ROGUE_NEW_GROUND,NEW_GROUND_RANDOM_ENCOUNTER,TRUE);
        WorldMapStartTravelling(DEN_AR_LITE_ROGUE_AMBUSH, RANDOM_ENCOUNTER_START_WAYPOINT);
        bDoAreaTransition = TRUE;
    }
    // Rogue Light Content: Decisions
    else if (WR_GetPlotFlag(PLT_LITE_ROGUE_DECISIONS,DECISIONS_RANDOM_ENCOUNTER_ACTIVE))
    {
        WR_SetPlotFlag(PLT_LITE_ROGUE_DECISIONS,DECISIONS_RANDOM_ENCOUNTER,TRUE);
        WorldMapStartTravelling(DEN_AR_LITE_ROGUE_AMBUSH, RANDOM_ENCOUNTER_START_WAYPOINT);
        bDoAreaTransition = TRUE;
    }

    return bDoAreaTransition;

}

/*

    redirects player to correct follower location

*/

int WM_HandleEventsFADE();
int WM_HandleEventsFADE()
{

    string sArea = GetLocalString(GetModule(), WM_STORED_AREA);
    string sWP   = GetLocalString(GetModule(), WM_STORED_WP);
    object oMap = GetObjectByTag(WM_FAD_TAG);
    object oWMLoc;

    if ( sArea == "Fade_Follower" )
    {
        int nFollower;
        switch (StringToInt(sWP))
        {
            case 1:
            {
                nFollower = GetLocalInt(GetModule(),CIR_FADE_FOLLOWER_1);
                oWMLoc = GetObjectByTag("wml_fad_comp_a");
                SetWorldMapPlayerLocation(oMap, oWMLoc);
                break;
            }
            case 2:
            {
                nFollower = GetLocalInt(GetModule(),CIR_FADE_FOLLOWER_2);
                oWMLoc = GetObjectByTag("wml_fad_comp_b");
                SetWorldMapPlayerLocation(oMap, oWMLoc);
                break;
            }
            case 3:
            {
                nFollower = GetLocalInt(GetModule(),CIR_FADE_FOLLOWER_3);
                oWMLoc = GetObjectByTag("wml_fad_comp_c");
                SetWorldMapPlayerLocation(oMap, oWMLoc);
                break;
            }
        }

        CIR_JumpToFadeFollower(nFollower);
    }
    else
        UT_PCJumpOrAreaTransition( sArea, sWP );

    return TRUE;

}