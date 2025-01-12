////////////////////////////////////////////////////////////////////////////////
//  Placeable Events Template
//  Copyright © 2007 Bioware Corp.
////////////////////////////////////////////////////////////////////////////////
/*
    Handles clicking on a mystical site of power - for lite_mage_places

    Keith W
    Jan 14/09
*/
////////////////////////////////////////////////////////////////////////////////

#include "placeable_h"
#include "lit_constants_h"
#include "plt_lite_mage_places"

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

            switch (nAction)
            {

                case PLACEABLE_ACTION_EXAMINE:
                {
                    //vfx
                    //this placeable becomes deactivated
                    //Set that this site has been clicked
                    // Qwinn:  Put this condition around everything to prevent spam click
                    // completion of quest.
                    if (GetObjectActive(OBJECT_SELF))
                    {
                       location lSelf = GetLocation(OBJECT_SELF);
                       Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_INSTANT, EffectVisualEffect(90125), lSelf);
                       WR_SetPlotFlag(PLT_LITE_MAGE_PLACES, PLACES_ACTIVATE_GLYPH, TRUE, TRUE);
                       WR_SetObjectActive(OBJECT_SELF, FALSE);                       
                    }
                    break;
                }

            }
            break;
        }

        \
    }

    if (!bEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_PLACEABLE_CORE);
    }
}