////////////////////////////////////////////////////////////////////////////////
//  Placeable Events Template
//  Copyright © 2007 Bioware Corp.
////////////////////////////////////////////////////////////////////////////////
/*
    Handles placeable events.
*/
////////////////////////////////////////////////////////////////////////////////

#include "placeable_h"
#include "plt_gen00pt_party"
#include "ui_h"

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
            int     nAction         = GetPlaceableAction(OBJECT_SELF);
            int     nVariation      = GetEventInteger(ev, 0);
            int     nActionResult   = TRUE;
            
            int nColor = 0xffffff;
            float fDuration = 3.0f;
            string sMessage = "Alistair would want to be with you for this";
            

            if(!WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY))
            {
                DisplayFloatyMessage( oUser, sMessage, FLOATY_MESSAGE, nColor, fDuration);
                return;
            }
            break;
        }


    }

    if (!bEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_PLACEABLE_CORE);
    }
}