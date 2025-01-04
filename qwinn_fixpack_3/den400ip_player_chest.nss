////////////////////////////////////////////////////////////////////////////////
//  Placeable Events Template
//  Copyright © 2007 Bioware Corp.
////////////////////////////////////////////////////////////////////////////////
/*
    Handles placeable events.
*/
////////////////////////////////////////////////////////////////////////////////

#include "placeable_h"
#include "den_constants_h"
#include "den_functions_h"
#include "plt_denpt_captured"
#include "party_h"


void main()
{
    event ev          = GetCurrentEvent();
    int nEventType    = GetEventType(ev);
    int bEventHandled = FALSE;

    switch (nEventType)
    {
        //----------------------------------------------------------------------
        // Sent by engine when a creature uses the placeable.
        //----------------------------------------------------------------------
        case EVENT_TYPE_USE:
        {
            object  oUser           = GetEventCreator(ev);
            object oPC              = GetHero();
            object oThis            = OBJECT_SELF;
            int     nAction         = GetPlaceableAction(OBJECT_SELF);
            int     nVariation      = GetEventInteger(ev, 0);
            int     nActionResult   = TRUE;

            string sKeyTag = GetPlaceableKeyTag(oThis);

            switch (nAction)
            {
                case PLACEABLE_ACTION_USE:
                case PLACEABLE_ACTION_OPEN:
                case PLACEABLE_ACTION_CLOSE:
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
                case PLACEABLE_ACTION_DESTROY:
                {
                    // *** Handle custom placeable usage here. ***

                    // Set the new state of the placeable using nActionResult
                    // (TRUE means the action succeeded, FALSE means action failed).


                    object oAlistair = Party_GetFollowerByTag(GEN_FL_ALISTAIR);
                                           
                    /*  None of the code for having a disguise worked.  Equipment permanently lost.
                    // if PC has a disguise on
                    if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISED, TRUE))
                    {
                        // Restore inventory to shared inventory, rather than equipped items
                        DEN_RestoreInventory(OBJECT_INVALID, DEN_IP_PARTY_DISGUISE_CHEST);

                        if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_ALISTAIR_CAPTURED))
                        {
                            DEN_RestoreInventory(OBJECT_INVALID, DEN_DISGUISE_CHEST + GEN_FL_ALISTAIR);
                        }
                    }
                    else
                    {
                        DEN_RestoreInventory(oPC);

                        if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_ALISTAIR_CAPTURED))
                        {
                            DEN_RestoreInventory(oAlistair);
                        }
                    }
                    */

                    // Begin Qwinn version
                    int nWasDisguised = FALSE;

                    if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISED, TRUE))
                    {
                        nWasDisguised = TRUE;
                        DEN_RemoveDisguises();
                    }

                    DEN_RestoreInventory(oPC);
                    if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_ALISTAIR_CAPTURED))
                        DEN_RestoreInventory(oAlistair);

                    if (nWasDisguised)
                       DEN_CreateDisguises();
                    // End Qwinn version


                    if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_ESCAPING))
                    {
                        DEN_RestoreInventory();
                    }

                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_GOT_EQUIPMENT_BACK, TRUE);

                    SetObjectInteractive(oThis, FALSE);
                    bEventHandled = TRUE;
                    break;
                }
            }
            break;
        }

    }

    if (!bEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_PLACEABLE_CORE);
    }
}