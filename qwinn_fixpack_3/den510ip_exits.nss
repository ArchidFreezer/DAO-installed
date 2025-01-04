////////////////////////////////////////////////////////////////////////////////
//  Placeable Events Template
//  Copyright © 2007 Bioware Corp.
////////////////////////////////////////////////////////////////////////////////
/*
    Handles placeable events.
*/
////////////////////////////////////////////////////////////////////////////////

#include "placeable_h"
#include "plt_denpt_rescue_the_queen"
#include "den_functions_h"


int DEN_HandleExit()
{
    object  oPC         = GetHero();
    object  oErlina     = UT_GetNearestCreatureByTag(oPC, DEN_CR_ERLINA);
    object  oAnora      = UT_GetNearestCreatureByTag(oPC, DEN_CR_ANORA);
    int     bCannotExit = FALSE;
    // Make Erlina or Anora speak up if they are following
    int bErlinaFollowing = WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_ERLINA_ENTERS_KITCHEN)
                           && !WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_ANORA_FOUND);
    int bAnoraFollowing = WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_ANORA_FREED)
                           && !WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_CAUTHRIEN_SPEAKS);


    if (bErlinaFollowing || bAnoraFollowing)
    {
        // Qwinn addded flag set
        WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_PC_LEAVING_MAIN_FLOOR,TRUE);
        UT_Talk(oErlina, oPC);
        bCannotExit = TRUE;
    }
    return bCannotExit;
}
void DEN_HandleDisguise()
{
    if ( WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_PARTY_IS_DISGUISED, TRUE))
    {
        //Log_Trace(LOG_CHANNEL_TEMP, GetCurrentScriptName(), "Removing disguises.");
        DEN_RemoveDisguises();
    }
}

void main()
{
    event ev          = GetCurrentEvent();
    int nEventType    = GetEventType(ev);
    int bEventHandled = FALSE;

    switch (nEventType)
    {
        case EVENT_TYPE_POPUP_RESULT:
        {
            object oOwner = GetEventObject(ev, 0);      // owner of popup
            int nPopupID  = GetEventInteger(ev, 0);     // popup ID (index into popup.xls)
            int nButton   = GetEventInteger(ev, 1);     // button result (1 - 4)

            switch (nPopupID)
            {
                case 1:     // Placeable area transition
                {
                    if (nButton == 1)
                    {
                        DEN_HandleDisguise();
                        break;
                    }
                }
     }
            break;
        }
        case EVENT_TYPE_PLACEABLE_COLLISION:
        {
            bEventHandled = DEN_HandleExit();
            break;
        }
        //----------------------------------------------------------------------
        // Sent by engine when a creature uses the placeable.
        //----------------------------------------------------------------------
        case EVENT_TYPE_USE:
        {
            object  oUser       = GetEventCreator(ev);

            bEventHandled = DEN_HandleExit();

            // Restore equipment to move into the next area
            if (!bEventHandled
                && !GetCombatState(oUser)
                && !(GetPlaceableState(OBJECT_SELF) == PLC_STATE_AREA_TRANSITION_LOCKED))
            {
                DEN_HandleDisguise();
            }


            break;
        }
    }

    if (!bEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_PLACEABLE_CORE);
    }
}