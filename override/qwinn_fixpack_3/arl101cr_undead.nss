//::///////////////////////////////////////////////
//:: Creature Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Events script for the undead attacking the village in Arl Eamon.
*/
//:://////////////////////////////////////////////
//:: Created By: David Sims
//:: Created On: February 12, 2009
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"

#include "plt_arl100pt_siege"

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
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: The creature spawns into the game. This can happen only once,
        //       regardless of save games.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_SPAWN:
        {
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature enters the perception area of this creature.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_PERCEPTION_APPEAR:
        {
            int bStealth = GetEventInteger(ev, 0);
            object oCreature = GetEventObject(ev, 0); // the appearing creature
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature exits the perception area of this creature.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_PERCEPTION_DISAPPEAR:
        {
            object oCreature = GetEventObject(ev, 0); // the disappeating creature
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: AI scripts
        // When: The current creatures suffered 1 or more points of damage in a
        //       single attack
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_DAMAGED:
        {
            object oDamager = GetEventCreator(ev);
            int nDamage = GetEventInteger(ev, 0);
            int nDamageType = GetEventInteger(ev, 1);

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: AI scripts
        // When: Another object tried attacking this creature using melee/ranged
        //       weapons (hit or miss), talents or spells.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_ATTACKED:
        {
            object oAttacker = GetEventObject(ev, 0);

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: AI scripts
        // When: The current creature dies
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_DEATH:
        {
            object oKiller = GetEventCreator(ev);
            if (!IsPartyMember(oKiller) && Random(100) < 70)
               UT_Talk(oKiller,oKiller);

            int bSecondWaveStarted = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_START_SECOND_WAVE);
            int bStartedFlankAttack = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_START_WINDMILL_FLANK_ATTACK);

            if ((bStartedFlankAttack == FALSE) && (bSecondWaveStarted == TRUE))
            {
                WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_FIRST_VILLAGE_CORPSE_KILLED, TRUE);
                WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_START_WINDMILL_FLANK_ATTACK, TRUE, TRUE);
            }

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: engine or scripting
        // When: this object is initiating dialog as the main speaker. This can
        //       happen when:
        //       1) (engine) A player object clicked to talk on this object
        //       2) (scripting) A trigger script or other script used the utility function UT_Talk to
        //          trigger dialog with this object
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_DIALOGUE:
        {
            object oTarget = GetEventObject(ev, 0); // player or NPC to talk to.
            resource rConversation = GetEventResource(ev, 0); // conversation to use, "" for default

            break;
        }

        ////////////////////////////////////////////////////////////////////////
        // Sent by: Engine
        // When: An item is added to the personal inventory of the current creature
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_INVENTORY_ADDED:
        {
            object oOwner = GetEventCreator(ev); // old owner of the item
            object oItem = GetEventObject(ev, 0); // item added

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: Engine
        // When: An item is removed from the personal inventory of the current creature
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_INVENTORY_REMOVED:
        {
            object oOwner = GetEventCreator(ev); // old owner of the item
            object oItem = GetEventObject(ev, 0); // item added

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: Engine
        // When: The current creature has equipped an item
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_EQUIP:
        {
            object oItem = GetEventCreator(ev); // the item being equipped
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: Engine
        // When: The current creature has unequipped an item
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_UNEQUIP:
        {
            object oItem = GetEventCreator(ev); // the item being unequipped
            break;
        }

        ////////////////////////////////////////////////////////////////////////
        // Sent by: Scripting
        // When: The last creature of a team dies
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_TEAM_DESTROYED:
        {
            int nTeamID = GetEventInteger(ev, 0); // Team ID
            break;
        }

    }
    if (!nEventHandled)
    {
        HandleEvent(ev, R"cli000cr_army_ds.ncs");
    }
}