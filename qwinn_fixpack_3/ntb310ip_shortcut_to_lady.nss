////////////////////////////////////////////////////////////////////////////////
//  Placeable Events
//  Copyright © 2007 Bioware Corp.
////////////////////////////////////////////////////////////////////////////////
/*
    Handles placeable events for transition to Lady of the Forest.
*/
////////////////////////////////////////////////////////////////////////////////


#include "placeable_h"
#include "plt_ntb340pt_lady"
#include "plt_ntb000pt_main"
#include "ntb_constants_h"
#include "ui_h"

/**-----------------------------------------------------------------------------
* @brief        Handles the EVENT_TYPE_USE placeable event.
*
* @param    ev  The event being handled.
* @returns      TRUE if event was handled, FALSE otherwise.
*-----------------------------------------------------------------------------*/
int _HandleEventUsed(event ev);
int _HandleEventUsed(event ev)
{
    object  oUser           = GetEventCreator(ev);
    int     nAction         = GetPlaceableAction(OBJECT_SELF);
    int     nActionResult   = TRUE;
    int     bEventHandled   = FALSE;

    if (!GetObjectActive(OBJECT_SELF))
        return bEventHandled;

    switch (nAction)
    {
        case PLACEABLE_ACTION_USE:
            break;
        case PLACEABLE_ACTION_OPEN:
            break;
        case PLACEABLE_ACTION_CLOSE:
            break;
        case PLACEABLE_ACTION_AREA_TRANSITION:
            break;
        case PLACEABLE_ACTION_DIALOG:
            break;
        case PLACEABLE_ACTION_EXAMINE:
            break;
        case PLACEABLE_ACTION_TRIGGER_TRAP:
            break;
        case PLACEABLE_ACTION_DISARM:
            break;
        case PLACEABLE_ACTION_UNLOCK:
            break;
        case PLACEABLE_ACTION_OPEN_INVENTORY:
            break;
        case PLACEABLE_ACTION_FLIP_COVER:
            break;
        case PLACEABLE_ACTION_USE_COVER:
            break;
        case PLACEABLE_ACTION_LEAVE_COVER:
            break;
        case PLACEABLE_ACTION_TOPPLE:
            break;
        case PLACEABLE_ACTION_DESTROY:
            return bEventHandled;
    }

    if (bEventHandled)
    {
        // nActionResult dictates the new state of the placeable.
        // TRUE means the action succeeded, FALSE means the action failed.
        SetPlaceableActionResult(OBJECT_SELF, nAction, nActionResult);
    }
    return bEventHandled;
}



void main()
{
    event ev          = GetCurrentEvent();
    int nEventType    = GetEventType(ev);
    int bEventHandled = TRUE;
    object oPC        = GetHero();
    object oParty     = GetParty(oPC);
    int nExecuteTransition = FALSE;

    switch (nEventType)
    {
        //----------------------------------------------------------------------
        // Sent by: The engine
        // When: A creature has clicked on this placeable
        //----------------------------------------------------------------------
        case EVENT_TYPE_USE:
        {
            object  oUser           = GetEventCreator(ev);
            bEventHandled = _HandleEventUsed(ev);
            int nShortcut = WR_GetPlotFlag(PLT_NTB340PT_LADY,NTB_LADY_OPENS_SHORTCUT_TO_FOREST);
            int nZathCut = WR_GetPlotFlag(PLT_NTB340PT_LADY, NTB_LADY_PC_BRINGS_ZATHRIAN);

            int nSacrifice = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ZATHRIAN_SACRIFICES_HIMSELF);

            //----------------------------------------------------------------------
            //the shortcut to the Werewolf Lair doesn't work
            // until the Lady opens the way
            //----------------------------------------------------------------------
            if(nShortcut == TRUE || nZathCut == TRUE || nSacrifice == TRUE)
            {
                nExecuteTransition = TRUE;
                bEventHandled = FALSE;
            }
            else
            {
                //update journal
                WR_SetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_PC_FOUND_RUINS_SHORTCUT_BLOCKED, TRUE, TRUE);
                //Message: The werewolves have barred the door from the other side
                UI_DisplayMessage(oUser, 4003);

                // Qwinn:  Added play of party bark 63 when door is clicked (must send 62 as flag)
                string sPlot = GetLocalString(GetModule(), PARTY_TRIGGER_PLOT);
                int nFlag = 62;
                int nPlayedAlready = WR_GetPlotFlag(sPlot,nFlag);
                if (nPlayedAlready == FALSE)
                {

                   object [] arParty = GetPartyList();
                   resource rPartyTriggerDialog = GetLocalResource(GetModule(), PARTY_TRIGGER_DIALOG_FILE);
                   if(rPartyTriggerDialog == R"")
                   {
                      return;
                   }

                   WR_SetPlotFlag(sPlot, nFlag, TRUE);

                   // Init party trigger dialog
                   object oFollower1 = arParty[1]; // first follower - just use to init the dialog - others might actually talk

                   UT_Talk(oFollower1, oPC, rPartyTriggerDialog);
                }   
            }
            break;
        }

    }

    if(nExecuteTransition == TRUE)
    {
        if (!bEventHandled)
        {
            HandleEvent(ev, RESOURCE_SCRIPT_PLACEABLE_CORE);
        }
    }
}