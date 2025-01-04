#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, BLOOD_DRAGON_PLATE_GAUNTLETS ) == TRUE ) return;

  object oContainer = GetObjectByTag("genip_chest_iron", 0);

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prm000im_dragon_blood_glove.uti", oContainer, 1, "", TRUE);
                                                       
    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, BLOOD_DRAGON_PLATE_GAUNTLETS, TRUE );
    return;
  }
}