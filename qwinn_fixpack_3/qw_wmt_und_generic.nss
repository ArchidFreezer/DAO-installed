////////////////////////////////////////////////////////////////////////////////
//  Written by Paul Escalona (Qwinn) 02/28/2017
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#include "placeable_h"

// This script replaces placeable_core in each of the area transitions in the
// Deep Roads and disables the wide world map before letting placeable_core
// do the rest of the work.
// Set in:  wmt_und_cc_to_ortan.utp, wmt_und_cc_to_ruined, wmt_und_cc_to_trenches,
// wmt_und_generic, wmt_und_orzammar_commons, wmt_und_ruined_to_outskirts,
// wmt_und_trenches_to_anvil.

void main()
{
    event ev          = GetCurrentEvent();
    int nEventType    = GetEventType(ev);
    int bEventHandled = FALSE;
    
    object oInvalid = OBJECT_INVALID;
    WR_SetWorldMapSecondary( oInvalid );
    
    HandleEvent(ev, RESOURCE_SCRIPT_PLACEABLE_CORE);
}
    
    
