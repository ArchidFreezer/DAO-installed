////////////////////////////////////////////////////////////////////////////////
//  Placeable Events Template
//  Copyright © 2007 Bioware Corp.
////////////////////////////////////////////////////////////////////////////////
/*
    Codex entry when examined

    Created by: Keith Warner
*/
////////////////////////////////////////////////////////////////////////////////

#include "placeable_h"
#include "plt_cod_dal_the_long_walk"
#include "plt_cod_dal_dirthamen"


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
                    int bNewCodex1 = WR_GetPlotFlag(PLT_COD_DAL_THE_LONG_WALK, COD_DAL_THE_LONG_WALK);
                    if (!bNewCodex1)
                    {
                       WR_SetPlotFlag(PLT_COD_DAL_THE_LONG_WALK, COD_DAL_THE_LONG_WALK, TRUE);
                       RewardXPParty(XP_CODEX, XP_TYPE_CODEX, OBJECT_INVALID, GetHero());
                    }
                    int bNewCodex2 = WR_GetPlotFlag(PLT_COD_DAL_DIRTHAMEN, COD_DAL_DIRTHAMEN_MAIN);
                    if (!bNewCodex2)
                    {
                       WR_SetPlotFlag(PLT_COD_DAL_DIRTHAMEN, COD_DAL_DIRTHAMEN_MAIN, TRUE);
                       RewardXPParty(XP_CODEX, XP_TYPE_CODEX, OBJECT_INVALID, GetHero());
                    }
                    SetObjectInteractive(OBJECT_SELF, FALSE);

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