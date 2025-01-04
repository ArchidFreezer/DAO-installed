// Flemeth's hut exterior
 // On-entering Flemeth's hut exterior:
//      activate Alistair at the hut exterior
//      init dialog with Flemeth

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "pre_objects_h"

#include "party_h"
#include "PLT_ZZ_PREPT_DEBUG"
#include "PLT_GEN00PT_PARTY"
#include "PLT_GENPT_MORRIGAN_MAIN"
#include "plt_genpt_morrigan_events"
#include "plt_pre100pt_light_beacon"
#include "PLT_PRE100PT_GENERIC"
#include "plt_prept_generic_actions"
#include "plt_pre100pt_the_cache"
#include "plt_cod_cha_flemeth"

#include "plt_genpt_app_morrigan"

void main()
{
    event   ev          = GetCurrentEvent();
    int     nEventType  = GetEventType(ev);
    int     nEventHandled = FALSE;
    string  sDebug;

    object oPlayer      = GetEventCreator(ev);
    object oPC          = GetHero();
    object oParty       = GetParty(oPlayer);
    object oAlistair    = Party_GetFollowerByTag(GEN_FL_ALISTAIR);
    object oDog         = Party_GetFollowerByTag(GEN_FL_DOG);
    object oMorrigan    = UT_GetNearestCreatureByTag(oPlayer, GEN_FL_MORRIGAN);
    object oFlemeth     = UT_GetNearestCreatureByTag(oPlayer, PRE_CR_FLEMETH);
    object oFlemethBoss = UT_GetNearestCreatureByTag(oPlayer, PRE_CR_FLEMETH_BOSS);




    switch(nEventType)
    {
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature enters the area
        ////////////////////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            // Beacon is lit and player walks outside after waking up
            // in Flemeth's hut for first time.
            if(WR_GetPlotFlag( PLT_PRE100PT_LIGHT_BEACON, PRE_BEACON_LIT) &&
                !WR_GetPlotFlag( PLT_PREPT_GENERIC_ACTIONS, PRE_GA_PC_ENTERED_FLEMETH_HUT_EXTERIOR_AFTER_BEACON))
            {

                WR_SetObjectActive(oMorrigan, FALSE);
                WR_SetObjectActive(oAlistair, TRUE);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY, TRUE, TRUE);
                // cleaning up Alistair
                Gore_RemoveAllGore(oAlistair);

                if (IsObjectValid(oDog))
                {
                    WR_SetObjectActive(oDog, TRUE);
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY, TRUE, TRUE);
                }


            }

            // DEBUG: If using debugger, restart debug conversation
            else if (WR_GetPlotFlag(PLT_ZZ_PREPT_DEBUG, DEBUG_JUMP_TO_FLEMETH_END_PRELUDE))
            {
                WR_SetPlotFlag(PLT_ZZ_PREPT_DEBUG, DEBUG_JUMP_TO_FLEMETH_END_PRELUDE, FALSE);
                WR_SetObjectActive(oMorrigan, TRUE);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_IN_PARTY, TRUE, TRUE);
                if (!WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY))
                {
                    WR_SetObjectActive(oAlistair, TRUE);
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY, TRUE, TRUE);
                }
            }
            // Also Debug - Jump to Prelude end
            else if (WR_GetPlotFlag(PLT_ZZ_PREPT_DEBUG, DEBUG_JUMP_TO_PRELUDE_END))
            {
                WR_SetObjectActive(oMorrigan, TRUE);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_IN_PARTY, TRUE, TRUE);
                if (!WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY))
                {
                    WR_SetObjectActive(oAlistair, TRUE);
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY, TRUE, TRUE);
                }
            }
            // END DEBUG


            break;
        }
        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {
            // heal party
            HealPartyMembers();

            // Qwinn added to despawn Flemeth when returning after agreeing to her deal:
            if (WR_GetPlotFlag(PLT_GENPT_MORRIGAN_MAIN, MORRIGAN_MAIN_FLEMITH_ALIVE))
            {
                SetObjectActive(oFlemethBoss, FALSE);
                SetObjectActive(oFlemeth, FALSE);
            } else

            // If returning to Fight Flemeth during Morrigan's Quest
            if((WR_GetPlotFlag( PLT_GENPT_MORRIGAN_MAIN, MORRIGAN_MAIN_FLEMITH_PLOT_ACTIVE)) &&
            !(WR_GetPlotFlag( PLT_GENPT_MORRIGAN_MAIN, MORRIGAN_MAIN_FLEMITH_READY_TO_FIGHT)))
            {
                // Check if Morrigan is in the party
                // If she is, Flemeth won't be there.  Morrigan will also warn
                // the PC she won't be around with her in the party.
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_IN_PARTY))
                {
                    // Morrigan chastizes the player for having her in the party
                    SetObjectActive(oFlemethBoss, FALSE);
                    SetObjectActive(oFlemeth, FALSE);
                    WR_SetPlotFlag(PLT_GENPT_MORRIGAN_EVENTS, MORRIGAN_EVENT_ON, TRUE, TRUE);
                    WR_SetPlotFlag(PLT_GENPT_MORRIGAN_EVENTS, MORRIGAN_EVENT_ARRIVED_AT_FELEMTHS_HUT, TRUE, TRUE);
                    UT_Talk(oMorrigan, oPC);

                } else  // If Morrigan not in party Flemeth will be there.
                {
                    SetObjectActive(oFlemethBoss, TRUE);
                    SetObjectActive(oFlemeth, FALSE);
                }
            }

            // Player enters area right after lighting signal beacon
            else if(WR_GetPlotFlag( PLT_PRE100PT_LIGHT_BEACON, PRE_BEACON_LIT) &&
                !WR_GetPlotFlag( PLT_PREPT_GENERIC_ACTIONS, PRE_GA_PC_ENTERED_FLEMETH_HUT_EXTERIOR_AFTER_BEACON))
            {


                    SetPartyPickerGUIStatus(PP_GUI_STATUS_NO_USE);
                    SetLocalInt(GetModule(), PARTY_PICKER_GUI_ALLOWED_TO_POP_UP, FALSE);

                WR_SetPlotFlag( PLT_PREPT_GENERIC_ACTIONS, PRE_GA_PC_ENTERED_FLEMETH_HUT_EXTERIOR_AFTER_BEACON, TRUE);
                WR_SetObjectActive(oAlistair, TRUE);
                WR_SetObjectActive(oMorrigan, FALSE);

                // Qwinn:  Added this because our pre-recruit of Morrigan can mess up Flemeth's dialogue
                // Also turn Morrigan approval notifications back on, and have next notification display from zero.
                WR_SetPlotFlag (PLT_GEN00PT_PARTY, GEN_MORRIGAN_RECRUITED, FALSE, FALSE);
                WR_SetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_NO_APPROVAL_NOTIFICATION, FALSE);
                WR_SetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_NOTIFY_APPROVAL_FROM_ZERO, TRUE);
                UT_Talk(oFlemeth, oPlayer);
            }
            // Talking to Flemeth after Signal Fire, - For Debug jump script
            else if(WR_GetPlotFlag( PLT_PRE100PT_THE_CACHE, PRE_CACHE_JUMP_TO_FLEMETH) &&
                !WR_GetPlotFlag( PLT_PREPT_GENERIC_ACTIONS, PRE_GA_PC_ENTERED_FLEMETH_HUT_EXTERIOR_FIRST_TIME))
            {


                    SetPartyPickerGUIStatus(PP_GUI_STATUS_NO_USE);
                    SetLocalInt(GetModule(), PARTY_PICKER_GUI_ALLOWED_TO_POP_UP, FALSE);

                WR_SetPlotFlag( PLT_PREPT_GENERIC_ACTIONS, PRE_GA_PC_ENTERED_FLEMETH_HUT_EXTERIOR_FIRST_TIME, TRUE);
                WR_SetObjectActive(oMorrigan, TRUE);
                UT_Talk(oMorrigan, oPlayer);

            }
            // Returning to Hut and it's Empty
            // Return before hearing about Flemeth's secret, or after defeating her
            else if(WR_GetPlotFlag(PLT_PRE100PT_GENERIC, PRE_GENERIC_PARTY_LEFT_PRELUDE_AREAS))
            {

                // SetObjectActive(GetObjectByTag("gen00fl_morrigan",1), FALSE);
                // Disable Flemeth
                SetObjectActive(oFlemeth, FALSE);
                // Unlock flemeth's door
                SetPlaceableState(GetObjectByTag("pre210ip_to_flem_interior"), PLC_STATE_DOOR_UNLOCKED);
            }




            // End of: case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
            break;
        }
        case EVENT_TYPE_ENTER:
        {
            object oCreature = GetEventCreator(ev);

            break;
        }

        case EVENT_TYPE_TEAM_DESTROYED:
        {
            int nTeamID = GetEventInteger( ev, 0 );

            // Flemeth is turning into dragon
            if (nTeamID == PRE_TEAM_WILDS_FLEMETH_CHARACTER)
            {

            }

            // Kill Flemeth in Dragon Form
            if (nTeamID == PRE_TEAM_WILDS_FLEMETH)
            {
                WR_SetPlotFlag( PLT_GENPT_MORRIGAN_MAIN, MORRIGAN_MAIN_FLEMITH_PLOT_COMPLETED, TRUE, TRUE);
                WR_SetPlotFlag( PLT_COD_CHA_FLEMETH, COD_CHA_FLEMETH_SLAIN, TRUE, TRUE);

            }

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature exits the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_EXIT:
        {
            object oCreature = GetEventCreator(ev);

            break;
        }
    }
    HandleEvent(ev, RESOURCE_SCRIPT_AREA_CORE);
}