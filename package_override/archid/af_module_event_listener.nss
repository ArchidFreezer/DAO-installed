#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "af_nohelmet_h"

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
            NoHelmetBookAdd();
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