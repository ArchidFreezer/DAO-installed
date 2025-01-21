#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "af_nohelmet_h"
#include "af_constants_h"
#include "af_logging_h"

void testSpellShapingConfig() {
    string appStr = GetM2DAString(TABLE_EVENTS, "Script", EVENT_TYPE_APPLY_EFFECT);
    string ablStr = GetM2DAString(TABLE_EVENTS, "Script", EVENT_TYPE_ABILITY_CAST_IMPACT);

    if (ablStr != "af_ablity_cast_impact" && ablStr != "eventmanager")
    {
        ShowPopup(SPELLSHAPING_WARNING_STRREFID, 1, OBJECT_INVALID, FALSE, 0);
    }
}

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    // We will watch for every event type and if the one we need
    // appears we will handle it as a special case. We will ignore the rest
    // of the events
    switch ( nEventType )
    {
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: The module loads from a save game. This event can fire more than
        //       once for a single module or game instance.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_MODULE_LOAD:
        {
            ReadIniLogLevel();
            NoHelmetBookAdd();
            testSpellShapingConfig();
            break;
        }
        case EVENT_TYPE_GUI_OPENED:
        {

            int nGUIID = GetEventInteger(ev, 0); // ID number of the GUI that was opened
            if (nGUIID == GUI_INVENTORY)
            {
                NoHelmetShowInventory(); // No helmet mod
            }
            break;
        }
        case EVENT_TYPE_GAMEMODE_CHANGE:
        {

            int nNewGameMode = GetEventInteger(ev, 0); // New Game Mode (GM_* constant)
            int nOldGameMode = GetEventInteger(ev, 1); // Old Game Mode (GM_* constant)

            // Test when exiting any GUI
            if (nOldGameMode == GM_GUI)
            {
                NoHelmetLeaveGUI(); // No helmet mod
            }
            break;
        }
        default:
            break;
    }
}