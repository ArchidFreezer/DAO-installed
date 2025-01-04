//::///////////////////////////////////////////////
//:: pre211ar_flemeths_hut_int.nss
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
// Flemeth's hut interior
// On-enter: (beacon was lit)
//    activate Morrigan at Flemeth's hut interior
//    init dialog with Morrigan
*/
//:://////////////////////////////////////////////
//:: Created By: Yaron
//:: Created On: October 24th, 2006
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"
#include "party_h"

#include "plt_pre100pt_light_beacon"
#include "plt_prept_generic_actions"
#include "plt_gen00pt_party"
#include "plt_genpt_morrigan_main"
#include "plt_prept_talked_to"
#include "plt_lite_kor_trailsigns"
#include "plt_lite_kor_jogby"
#include "plt_lite_kor_lastwill"

#include "pre_objects_h"

// Qwinn added
#include "plt_pre100pt_prisoner"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    int nEventHandled = FALSE;

    object oAlistair = Party_GetFollowerByTag(GEN_FL_ALISTAIR);
    object oDog = Party_GetFollowerByTag(GEN_FL_DOG);
    object oMorrigan = UT_GetNearestCreatureByTag(oPC, GEN_FL_MORRIGAN);
    object oFootLocker = UT_GetNearestObjectByTag(oPC, PRE_IP_FOOTLOCKER);
    //object oFlemeth = UT_GetNearestCreatureByTag(oPC, "pre211cr_flemeth");

    switch(nEventType)
    {
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            int bBeaconLit = WR_GetPlotFlag( PLT_PRE100PT_LIGHT_BEACON, PRE_BEACON_LIT);
            int bHutVisited = WR_GetPlotFlag( PLT_PREPT_GENERIC_ACTIONS, PRE_GA_PC_ENTERED_FLEMETH_HUT_INTERIOR_AFTER_BEACON);
            int bMorriganTalkedTo = WR_GetPlotFlag( PLT_PREPT_TALKED_TO, PRE_TT_MORRIGAN_AT_HUT);

            object oArea = GetArea(oPC);

            object [] oMorriganArray = GetObjectsInArea(oArea, GEN_FL_MORRIGAN);


            // If Beacon is lit and haven't entered the home already
            if(WR_GetPlotFlag( PLT_PRE100PT_LIGHT_BEACON, PRE_BEACON_LIT) &&
                !WR_GetPlotFlag( PLT_PREPT_GENERIC_ACTIONS, PRE_GA_PC_ENTERED_FLEMETH_HUT_INTERIOR_AFTER_BEACON))
            {

                ResurrectCreature(oPC);
                HealCreature(oPC);
                Effects_RemoveUpkeepEffect(oPC, 0);
                //RemoveAllEffects(oPC, TRUE, FALSE);
                Injury_RemoveAllInjuries(oPC);

                StoreFollowerInventory(oPC, oFootLocker);

                ResurrectCreature(oAlistair);
                HealCreature(oAlistair);
                Injury_RemoveAllInjuries(oAlistair);

                if (IsObjectValid(oDog))
                {
                    ResurrectCreature(oDog);
                    HealCreature(oDog);
                    Injury_RemoveAllInjuries(oDog);
                }

                //close off any light content plots from the wilds that may be open
                if (WR_GetPlotFlag(PLT_LITE_KOR_TRAILSIGNS, TRAILSIGNS_CACHE_ALERT) == TRUE &&
                    WR_GetPlotFlag(PLT_LITE_KOR_TRAILSIGNS, TRAILSIGNS_CACHE_COMPLETE) == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_KOR_TRAILSIGNS, TRAILSIGNS_CACHE_FAIL, TRUE, TRUE);
                }

                if (WR_GetPlotFlag(PLT_LITE_KOR_JOGBY, JOGBY_QUEST_GIVEN) == TRUE &&
                    WR_GetPlotFlag(PLT_LITE_KOR_JOGBY, JOGBY_QUEST_COMPLETE) == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_KOR_JOGBY, JOGBY_QUEST_FAIL, TRUE, TRUE);
                }

                if (WR_GetPlotFlag(PLT_LITE_KOR_LASTWILL, LASTWILL_GIVEN) == TRUE &&
                    WR_GetPlotFlag(PLT_LITE_KOR_LASTWILL, CACHE_FOUND) == FALSE &&
                    WR_GetPlotFlag(PLT_LITE_KOR_LASTWILL, CACHE_OPENED) == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_KOR_LASTWILL, LASTWILL_FAIL, TRUE, TRUE);
                }

                // Qwinn:  New closing entry if you leave Ostagar with the key, which you want to do for Return to Ostagar DLC
                if (WR_GetPlotFlag(PLT_PRE100PT_PRISONER, PRE_PRISONER_GIVE_KEY) == TRUE &&
                    WR_GetPlotFlag(PLT_PRE100PT_PRISONER, PRE_PRISONER_GOT_FOOD) == FALSE) // Qwinn: Odd name for the "opened the chest" flag.
                {
                   WR_SetPlotFlag(PLT_PRE100PT_PRISONER, PRE_PRISONER_LEFT_WITH_KEY_DID_NOT_USE,TRUE,TRUE);
                }
            }

            int i; // Counter

            // After lighting the signal beacon
            if (( bBeaconLit && !bHutVisited ) || !bMorriganTalkedTo)
            {
                WR_SetPlotFlag( PLT_PREPT_GENERIC_ACTIONS, PRE_GA_PC_ENTERED_FLEMETH_HUT_INTERIOR_AFTER_BEACON, TRUE);
                WR_SetObjectActive(oMorrigan, TRUE);
                UT_Talk(oMorrigan, oPC);
            } else
            {
                // The false Morrigan should not appear
                // Make sure the Morrigan grabbed isn't in the party
                for (i = 0; i < GetArraySize(oMorriganArray); i++)
                {
                    if (IsPartyMember(oMorriganArray[i]) == FALSE)
                        WR_SetObjectActive(oMorriganArray[i], FALSE);
                }
            }

            break;
        }
        // AREA EXIT
        case EVENT_TYPE_EXIT:
        {
            object oCreature = GetEventCreator(ev);
            object oFlemethChest = GetObjectByTag("pre211ip_chest_iron");

            if (IsHero(oCreature))
            {
                if (GetLocalInt(oFlemethChest, "TS_TREASURE_GENERATED") == FALSE)
                    SetLocalInt(oFlemethChest, "TS_TREASURE_GENERATED", 1);
                TrackPartyAreaEvent(OBJECT_SELF,nEventType);
            }
            break;
        }
    }
    if (!nEventHandled)
    {
        HandleEvent(ev, PRE_RS_AREA_CORE);
    }
}