////////////////////////////////////////////////////////////////////////////////
//  Placeable Events Template
//  Copyright © 2007 Bioware Corp.
////////////////////////////////////////////////////////////////////////////////
/*
    The gentled mage talks to you if you try to loot the chest in the day time.
*/
////////////////////////////////////////////////////////////////////////////////


#include "placeable_h"
#include "pre_objects_h"
#include "plt_pre100pt_generic"
#include "plt_pre100pt_prisoner"


void main()
{
    event ev          = GetCurrentEvent();
    int nEventType    = GetEventType(ev);
    int bEventHandled = FALSE;
    object oPC        = GetHero();
    object oParty     = GetParty(oPC);


    switch (nEventType)
    {

        case EVENT_TYPE_USE:
        {
            int     nAction         = GetPlaceableAction(OBJECT_SELF);
            int     nVariation      = GetEventInteger(ev, 0);
            int     nActionResult   = FALSE;

            object  oArea      = GetArea(oPC);
            object  oTranquil  = UT_GetNearestCreatureByTag(oPC, PRE_CR_TRANQUIL);
            object  oUser = GetEventCreator(ev);
            //vector  vPositionToFace = GetPosition(oUser) - GetPosition(oTranquil);
            //float   fAngleToFace = VectorToAngle(vPositionToFace);

            if (GetTag(oArea) == PRE_AR_KINGS_CAMP)
            {

                SetFacingObject(oTranquil, oPC);
                WR_AddCommand(oTranquil, CommandPlayAnimation(824, 1, TRUE), FALSE, FALSE, COMMAND_ADDBEHAVIOR_DONTCLEAR);
                WR_SetPlotFlag(PLT_PRE100PT_GENERIC, PRE_GENERIC_GENTLE_GUARDING_CHEST, TRUE);
                UT_Talk(oTranquil, oPC);
                bEventHandled = TRUE;
            }



            if (bEventHandled)
            {
                SetPlaceableActionResult(OBJECT_SELF, nAction, nActionResult, nVariation);
            }
            break;
        }

        case EVENT_TYPE_OPENED:
        {
            int     nAction         = GetPlaceableAction(OBJECT_SELF);
            int     nVariation      = GetEventInteger(ev, 0);
            int     nActionResult   = FALSE;

            object  oArea      = GetArea(oPC);
            object  oUser = GetEventCreator(ev);
            
            // Qwinn:  Added second TRUE, without it the plot reward doesn't trigger
            WR_SetPlotFlag(PLT_PRE100PT_PRISONER, PRE_PRISONER_GOT_FOOD, TRUE, TRUE);

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