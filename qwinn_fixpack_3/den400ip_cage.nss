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
#include "plt_denpt_generic"



void main()
{
    event ev          = GetCurrentEvent();
    int nEventType    = GetEventType(ev);
    int bEventHandled = FALSE;

    switch (nEventType)
    {

        //----------------------------------------------------------------------
        //  Sent by script when unlock attempt fails.
        //----------------------------------------------------------------------
        case EVENT_TYPE_UNLOCK_FAILED:
        {
            object  oPC             = GetHero();
            object oJailor          = UT_GetNearestCreatureByTag(oPC, DEN_CR_JAILOR);
            //object oUser = GetEventObject(ev, 0);

            // if pc escaping but jailor isn't neutralized, open dialog
            if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_ESCAPING)
                && !WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_JAILOR_SHOULD_NOT_TALK_WHEN_DOOR_CLICKED))
            {
                WR_SetPlotFlag(PLT_DENPT_GENERIC, DEN_GENERIC_TALK_DOOR_STILL_LOCKED, TRUE);

                UT_Talk(oJailor, oPC);
            }
            break;
        }

        //----------------------------------------------------------------------
        // Sent by engine when a creature uses the placeable.
        //----------------------------------------------------------------------
        case EVENT_TYPE_USE:
        {
            object  oUser           = GetEventCreator(ev);
            object  oPC             = GetHero();
            int     nAction         = GetPlaceableAction(OBJECT_SELF);
            int     nVariation      = GetEventInteger(ev, 0);
            int     nActionResult   = TRUE;
            object  oJailor         = UT_GetNearestCreatureByTag(oUser, DEN_CR_JAILOR);

            if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PARTY_COMING_IN))

            {
                // start rescue party dialog with player if jailor is dead and door
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_JAILOR_KILLED)
                    && nAction == PLACEABLE_ACTION_OPEN)
                {
                    DEN_SetPartyDialogOverride(INVALID_RESOURCE);
                    // Qwinn:  Doesn't work right if user is 2nd party member
                    // UT_Talk(oUser, oPC, DEN_CONV_RESCUE_PARTY);
                    UT_Talk(GetPartyLeader(), oPC, DEN_CONV_RESCUE_PARTY);
                }
            }
            else
            {
                // if player has locked the jailor in, have jailor shout his "I'll get you" line (attacking could involve uniform change and be complicated)
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_JAILOR_LOCKED_UP))
                {
                    UT_Talk(oJailor, oPC);
                    bEventHandled = TRUE;
                    nActionResult = FALSE;

                }
                else
                {
                    // start combat if door is opened by player
                    if (nAction == PLACEABLE_ACTION_OPEN)
                    {
                        if (!WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_JAILOR_SHOULD_NOT_TALK_WHEN_DOOR_CLICKED))
                        {
                            WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_JAILOR_PC_OPENED_DOOR, TRUE, TRUE);
                            UT_Talk(oJailor, oPC);
                        }
                    }
                }

            }

            if (bEventHandled)
            {
                SetPlaceableActionResult(OBJECT_SELF, nAction, nActionResult, nVariation);
            }


            break;
        }



    }

    if (!bEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_PLACEABLE_CORE);
    }
}