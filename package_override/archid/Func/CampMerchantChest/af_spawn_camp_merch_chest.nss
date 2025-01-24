#include "af_camp_merch_chest_h"

void main()
{
    object oMainControlled = GetMainControlled();
    object oChest = UT_GetNearestObjectByTag(oMainControlled, AF_IP_CAMP_MERCH_CHEST);

    if (!IsObjectValid(oChest))
    {
        location lSpawn = Location(GetArea(oMainControlled), Vector(149.692,144.812,-0.968447), 199.0);

        CreateObject(OBJECT_TYPE_PLACEABLE, AF_IPR_CAMP_MERCH_CHEST, lSpawn);

    }

}