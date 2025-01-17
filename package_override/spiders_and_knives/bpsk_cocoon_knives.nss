////////////////////////////////////////////////////////////////////////////////
//  Placeable Events Template
//  Copyright © 2007 Bioware Corp.
////////////////////////////////////////////////////////////////////////////////
/*
    Handles placeable events.
*/
////////////////////////////////////////////////////////////////////////////////

#include "placeable_h"

#include "plt_bp_spiders_knives"
#include "plt_bpsk_rescue_knives"


void main()
{
    event ev          = GetCurrentEvent();
    int nEventType    = GetEventType(ev);
    int bEventHandled = FALSE;

    switch (nEventType)
    {
        //----------------------------------------------------------------------
        // Sent by engine when object spawns in game. This happens once
        // regardless of save games.
        //----------------------------------------------------------------------
        case EVENT_TYPE_SPAWN:
        {
            break;
        }

        //----------------------------------------------------------------------
        // Sent by engine when player clicks on object.
        //----------------------------------------------------------------------
        case EVENT_TYPE_PLACEABLE_ONCLICK:
        {
            break;
        }

        //----------------------------------------------------------------------
        // Sent by engine when a creature uses the placeable.
        //----------------------------------------------------------------------
        case EVENT_TYPE_USE:
        {
            object  oUser           = GetEventCreator(ev);
            int     nAction         = GetPlaceableAction(OBJECT_SELF);
            int     nVariation      = GetEventInteger(ev, 0);
            int     nActionResult   = TRUE;

            switch (nAction)
            {
                case PLACEABLE_ACTION_OPEN:
                    nVariation = !nVariation;  // Makes doors swing away from player
                case PLACEABLE_ACTION_CLOSE:
                case PLACEABLE_ACTION_USE:
                case PLACEABLE_ACTION_AREA_TRANSITION:
                case PLACEABLE_ACTION_DIALOG:
                case PLACEABLE_ACTION_EXAMINE:
                case PLACEABLE_ACTION_TRIGGER_TRAP:
                case PLACEABLE_ACTION_DISARM:
                case PLACEABLE_ACTION_UNLOCK:
                case PLACEABLE_ACTION_OPEN_INVENTORY:
                case PLACEABLE_ACTION_FLIP_COVER:
                case PLACEABLE_ACTION_USE_COVER:
                case PLACEABLE_ACTION_LEAVE_COVER:
                case PLACEABLE_ACTION_TOPPLE:
                {
                    // *** Handle custom placeable usage here. ***
                    // Show options for player actions
                    Placeable_HandleDialog(ev);
                    bEventHandled = TRUE;

                    // Set the new state of the placeable using nActionResult
                    // (TRUE means the action succeeded, FALSE means action failed).
                    if (bEventHandled)
                    {
                        SetPlaceableActionResult(OBJECT_SELF, nAction, nActionResult, nVariation);
                    }
                    break;
                }
                case PLACEABLE_ACTION_DESTROY:
            }
            break;
        }

        //----------------------------------------------------------------------
        // Sent by engine or scripting when this object is initiating dialog as
        // the speaker either when a player clicks to talk to this object or
        // a script initiates dialog with this object
        //----------------------------------------------------------------------
        case EVENT_TYPE_DIALOGUE:
        {
            //object oTarget = GetEventObject(ev, 0);               // player or NPC to talk to.
            //resource rConversationName = GetEventResource(ev, 0); // conversation to use, "" for default
            break;
        }

        //----------------------------------------------------------------------
        // Sent by engine when an item is added to the inventory of this object.
        //----------------------------------------------------------------------
        case EVENT_TYPE_INVENTORY_ADDED:
        {
            //object oOwner = GetEventCreator(ev);    // old owner of the item
            //object oItem  = GetEventObject(ev, 0);  // item added
            break;
        }

        //----------------------------------------------------------------------
        // Sent by engine when an item is removed from inventory of this object.
        //----------------------------------------------------------------------
        case EVENT_TYPE_INVENTORY_REMOVED:
        {
            //object oOwner = GetEventCreator(ev);    // old owner of the item
            //object oItem  = GetEventObject(ev, 0);  // item added
            break;
        }

        //----------------------------------------------------------------------
        // Sent by engine when a placeable trap strikes an object.
        //----------------------------------------------------------------------
        case EVENT_TYPE_TRAP_TRIGGERED:
        {
            //object   oTarget = GetEventObject(ev, 0);    // Target hit by trap
            //location lImpact = GetEventLocation(ev, 0);  // Impact location
            break;
        }

        //----------------------------------------------------------------------
        // Sent by engine when this object is attacked.
        //----------------------------------------------------------------------
        case EVENT_TYPE_ATTACKED:
        {
            //object oAttacker = GetEventCreator(ev);
            break;
        }

        //----------------------------------------------------------------------
        // Sent by AI scripts when object suffers 1 or more points of damage.
        //----------------------------------------------------------------------
        case EVENT_TYPE_DAMAGED:
        {
            //object oDamager = GetEventCreator(ev);
            //int nDamage     = GetEventInteger(ev, 0);
            //int nDamageType = GetEventInteger(ev, 1);
            break;
        }

        //----------------------------------------------------------------------
        // Sent by AI scripts when object is destroyed.
        //----------------------------------------------------------------------
        case EVENT_TYPE_DEATH:
        {
            //object oKiller = GetEventCreator(ev);
            break;
        }

        //----------------------------------------------------------------------
        // Sent by engine when object is hit by a spell.
        //----------------------------------------------------------------------
        case EVENT_TYPE_CAST_AT:
        {
            break;
        }

        //----------------------------------------------------------------------
        // Sent by engine when object needs to have an effect applied to itself
        //----------------------------------------------------------------------
        case EVENT_TYPE_APPLY_EFFECT:
        {
            //effect eEffect = GetCurrentEffect();    // effect to be applied
            break;
        }

        //----------------------------------------------------------------------
        // Sent by engine when object needs to have an effect removed from itself
        //----------------------------------------------------------------------
        case EVENT_TYPE_REMOVE_EFFECT:
        {
            //effect eEffect = GetCurrentEffect();    // effect to be removed
            break;
        }
    }

    if (!bEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_PLACEABLE_CORE);
    }
}