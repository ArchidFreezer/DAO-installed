#include "placeable_h"
#include "af_scalestorefix_h"

void main()
{
    event ev          = GetCurrentEvent();
    int nEventType    = GetEventType(ev);
    int bEventHandled = FALSE;

    object oStore = GetObjectByTag("store_" + GetTag(OBJECT_SELF));

    switch (nEventType)
    {
        case EVENT_TYPE_USE:
        {
            object  oUser           = GetEventCreator(ev);
            int     nAction         = GetPlaceableAction(OBJECT_SELF);
            int     nVariation      = GetEventInteger(ev, 0);
            int     nActionResult   = TRUE;

            if(IsObjectValid(oStore))
            {
                ScaleStoreEdited(oStore);
                OpenStore(oStore);
            }

            bEventHandled = TRUE;
            break;
        }
    }

    if (!bEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_PLACEABLE_CORE);
    }
}