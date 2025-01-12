////////////////////////////////////////////////////////////////////////////////
//  Placeable Events Template
//  Copyright © 2007 Bioware Corp.
////////////////////////////////////////////////////////////////////////////////
/*
    Written by Qwinn on July 20, 2017
    Handles triggering Loghain and Anora's ambient dialogue.
*/
////////////////////////////////////////////////////////////////////////////////

#include "placeable_h"
#include "lit_constants_h"

#include "plt_gen00pt_party"

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
        case EVENT_TYPE_OPENED:
        {
            object  oUser           = GetEventCreator(ev);
            if (WR_GetPlotFlag(PLT_GEN00PT_PARTY,GEN_LOGHAIN_RECRUITED))
            {
                SetObjectInteractive(OBJECT_SELF,FALSE);  // so it can't be closed again, which would block her exit
                object oAnora = UT_GetNearestCreatureByTag(oUser,"den510cr_anora");
                object oLoghain = UT_GetNearestCreatureByTag(oUser,"gen00fl_loghain");
                AddCommand(oAnora,CommandMoveToObject(oLoghain,FALSE,1.5),TRUE,TRUE);
                UT_Talk( oAnora, oLoghain );
            }   
            break;
        }

    }

    if (!bEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_PLACEABLE_CORE);
    }
}