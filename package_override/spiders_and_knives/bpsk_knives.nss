//::///////////////////////////////////////////////
//:: Creature Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creature events for: Ser Arbither Cora ('Knives')
*/
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"

#include "plt_bp_spiders_knives"
#include "plt_bpsk_rescue_knives"

const int EVENT_TYPE_CLEANUP_STRAGGLERS = 22055;

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oKnives = GetObjectByTag("bpsk_knives");
    int nEventHandled = FALSE;

    switch(nEventType)
    {

        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: The creature spawns into the game. This can happen only once,
        //       regardless of save games.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_SPAWN:
        {
            // Equip her father's blades, if she has them
            if (WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_BLADES_RETURNED))
            {
                object oCrane = CreateItemOnObject(R"bpsk_crane_low.uti",oKnives);
                object oCrow = CreateItemOnObject(R"bpsk_crow_low.uti",oKnives);
                EquipItem(oKnives,oCrane,INVENTORY_SLOT_MAIN);
                EquipItem(oKnives,oCrow,INVENTORY_SLOT_OFFHAND);
            }

            break;
        }

        //////////////////////////////////////////////////////////////////////////////
        // Sent by: AI scripts
        // When: Knives has been killed
        //////////////////////////////////////////////////////////////////////////////

        case EVENT_TYPE_DYING:
        {
//            DisplayFloatyMessage(oPC,"Knives Killed.",FLOATY_MESSAGE,0xff0000,10.0);
            // If she has died fighting the player, then her death is real
            if ((WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_CAUGHT_STEALING)) &&
                !(WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_BLADES_RETURNED)))
            {
                WR_SetPlotFlag(PLT_BPSK_RESCUE_KNIVES,KNIVES_KILLED,TRUE);
                WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_ARBITHER_KILLED,TRUE);
            }

            break;
        }

        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: When combat is over
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_COMBAT_END:
        {
            if (WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_FINAL_WAVE))
            {
                // Make sure there are no hidden enemies about at the end of the darspawn attack
//                DisplayFloatyMessage(oPC,"Combat ended.",FLOATY_MESSAGE,0xff0000,10.0);
//                UT_KillTeam(5, oPC);
                object oArea = GetArea(oPC);
                DelayEvent(1.0,oArea,Event(EVENT_TYPE_CLEANUP_STRAGGLERS));
            }
            nEventHandled = TRUE;
            break;
        }

    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_CREATURE_CORE);
    }
}