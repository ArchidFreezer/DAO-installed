////////////////////////////////////////////////////////////////////////////////
//  Placeable Events Template
//  Copyright © 2007 Bioware Corp.
////////////////////////////////////////////////////////////////////////////////
/*
    One of the ritual statues for the LT Reaching
*/
////////////////////////////////////////////////////////////////////////////////

#include "placeable_h"
#include "plt_cod_lite_tow_reach"
#include "plt_lite_tow_reach"
#include "cir_constants_h"
#include "sys_audio_h"


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
                    //if the statue is hit in the correct order - play a good sound
                    int nStatue1 = WR_GetPlotFlag(PLT_LITE_TOW_REACH, TOW_REACH_STATUE_1);
                    int nStatue2 = WR_GetPlotFlag(PLT_LITE_TOW_REACH, TOW_REACH_STATUE_2);
                    int nStatue3 = WR_GetPlotFlag(PLT_LITE_TOW_REACH, TOW_REACH_STATUE_3);
                    int nStatue4 = WR_GetPlotFlag(PLT_LITE_TOW_REACH, TOW_REACH_STATUE_4);


                    if(nStatue1 == TRUE && nStatue2 == FALSE)
                    {
                        WR_SetPlotFlag(PLT_LITE_TOW_REACH, TOW_REACH_STATUE_2, TRUE);

                        //Play success sound
                        // Qwinn:  1139 does nothing.  1010 fits description of what happens in PS3/XBOX
                        // ApplyEffectVisualEffect(oUser, OBJECT_SELF, 1139, EFFECT_DURATION_TYPE_INSTANT, 0.0);
                        ApplyEffectVisualEffect(oUser, OBJECT_SELF, 1010, EFFECT_DURATION_TYPE_INSTANT, 0.0);
                        //AudioTriggerPlotEvent(34);
                    }
                    else
                    {
                        //Damage player
                        DamageCreature(oUser, OBJECT_SELF, 20.0, DAMAGE_TYPE_ELECTRICITY);
                        //unset all variables
                        WR_SetPlotFlag(PLT_LITE_TOW_REACH, TOW_REACH_STATUE_1, FALSE);
                        WR_SetPlotFlag(PLT_LITE_TOW_REACH, TOW_REACH_STATUE_2, FALSE);
                        WR_SetPlotFlag(PLT_LITE_TOW_REACH, TOW_REACH_STATUE_3, FALSE);
                        WR_SetPlotFlag(PLT_LITE_TOW_REACH, TOW_REACH_STATUE_4, FALSE);

                    }

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