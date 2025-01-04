//::///////////////////////////////////////////////
//:: Area Core
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Handles global area events
*/
//:://////////////////////////////////////////////
//:: Created By: Craig Graff
//:: Created On: February 27, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"

#include "den_functions_h"
#include "plt_denpt_rescue_the_queen"
#include "plt_bec000pt_main"

#include "plt_qwinn"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    int nEventHandled = FALSE;


    switch(nEventType)
    {
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: it is for playing things like cutscenes and movies when
        // you enter an area, things that do not involve AI or actual game play
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_SPECIAL:
        {
            break;
        }
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            object oErlina          = UT_GetNearestObjectByTag(oPC, DEN_CR_ERLINA);
            object oVaughan         = UT_GetNearestObjectByTag(oPC, DEN_CR_VAUGHAN);
            object oRiordan         = UT_GetNearestObjectByTag(oPC, DEN_CR_RIORDAN);
            object oJailor          = UT_GetNearestObjectByTag(oPC, DEN_CR_RIORDAN_JAILOR_DEAD);

            if (!GetLocalInt(OBJECT_SELF, ENTERED_FOR_THE_FIRST_TIME))
            {
                UT_TeamGoesHostile(DEN_TEAM_RESCUE_KENNEL, FALSE);
                UT_TeamMerge(DEN_TEAM_RESCUE_KENNEL, DEN_TEAM_RESCUE_CAPTAIN);
                DEN_SwitchEquipment(oRiordan);
                DEN_SwitchEquipment(oJailor);
                KillCreature(oJailor);
            }

            if (WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_PARTY_IS_DISGUISED, TRUE))
            {
                DEN_CreateDisguises();
                Rescue_TeamsGoHostile(FALSE);
            }
            else
            {
                Rescue_TeamsGoHostile(TRUE, FALSE);
            }


            if (WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_HOWE_KILLED)
                && !GetLocalInt(OBJECT_SELF, AREA_DO_ONCE_A))
            {
                SetLocalInt(OBJECT_SELF, AREA_DO_ONCE_A, TRUE);


                UT_SetTeamStationary(DEN_TEAM_CAPTURED_CAUTHRIEN_GUARD, AI_STATIONARY_STATE_DISABLED);
                UT_SetTeamStationary(DEN_TEAM_CAPTURED_CAUTHRIEN_RANGED, AI_STATIONARY_STATE_HARD);
                UT_TeamMerge(DEN_TEAM_CAPTURED_CAUTHRIEN_GUARD, DEN_TEAM_CAPTURED_CAUTHRIEN);
                UT_TeamMerge(DEN_TEAM_CAPTURED_CAUTHRIEN_RANGED, DEN_TEAM_CAPTURED_CAUTHRIEN);

                UT_TeamAppears(DEN_TEAM_RESCUE_MAIN_ENTRANCE, FALSE);

                object oAnora           = UT_GetNearestObjectByTag(oPC, DEN_CR_ANORA);
                object oAnoraDoor       = UT_GetNearestObjectByTag(oPC, DEN_IP_RESCUE_ANORA_DOOR);
                object oAnoraDisguise = UT_AddItemToInventory(DEN_IM_CAPTURED_DISGUISE, 1, oAnora);
                object oAnoraHelmet = UT_AddItemToInventory(DEN_IM_CAPTURED_DISGUISE_HELM, 1, oAnora);
                object oAnoraGloves = UT_AddItemToInventory(DEN_IM_CAPTURED_DISGUISE_GLOVES, 1, oAnora);
                object oAnoraBoots = UT_AddItemToInventory(DEN_IM_CAPTURED_DISGUISE_BOOTS, 1, oAnora);

                EquipItem(oAnora, oAnoraDisguise);
                EquipItem(oAnora, oAnoraHelmet);
                EquipItem(oAnora, oAnoraGloves);
                EquipItem(oAnora, oAnoraBoots);
                SetObjectInteractive(oErlina, FALSE);

                SetPlaceableState(oAnoraDoor, PLC_STATE_DOOR_UNLOCKED);
                RemoveVisualEffect(oAnoraDoor, 5036);

                DoAutoSave();
            }
            // Qwinn:  The following was in the above DO_ONCE block, which made these actions
            // never happen if the player left the dungeon prior to freeing Vaughan or getting the key.

            if (WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_VAUGHAN_FREED) &&
               // Qwinn added this condition
               (!WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_VAUGHAN_CHANTRY)))
            {
                WR_SetObjectActive(oVaughan, TRUE);
            }

            if (WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_VAUGHAN_GIVES_KEY) &&
                !WR_GetPlotFlag(PLT_QWINN, DEN_VAUGHAN_CHEST_ACTIVATED))
            {
                int nCoins = 10000 * DEN_MONEY_VAUGHAN_BRIBE_GOLD;
                object oVaughansChest   = UT_GetNearestObjectByTag(oPC, DEN_IP_RESCUE_VAUGHANS_LOCKBOX);
                object oVaughanRoom     = UT_GetNearestObjectByTag(oPC, DEN_WP_RESCUE_VAUGHAN_ROOM);

                if (WR_GetPlotFlag(PLT_BEC000PT_MAIN, BEC_MAIN_BRIBE_HIDDEN))
                {
                    nCoins += 10000 * BEC_VAUGHAN_BRIBE_GOLD;
                }

                SetObjectInteractive(oVaughansChest, TRUE);
                UT_AddItemToInventory(GEN_IM_COPPER, nCoins, oVaughansChest);
                SetMapPinState(oVaughanRoom, TRUE);
                WR_SetPlotFlag(PLT_QWINN, DEN_VAUGHAN_CHEST_ACTIVATED, TRUE);
            }

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: fires at the same time that the load screen is going away,
        // and can be used for things that you want to make sure the player sees.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {
            if (!GetLocalInt(OBJECT_SELF, ENTERED_FOR_THE_FIRST_TIME))
            {
                DoAutoSave();
            }
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature enters the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_ENTER:
        {
            object oCreature = GetEventCreator(ev);

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
    if (!nEventHandled)
    {
        HandleEvent(ev, DEN_SCRIPT_AREA_CORE);
    }
}