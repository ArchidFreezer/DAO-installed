#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, BLOOD_DRAGON_PLATE_BOOTS ) == TRUE ) return;

  object oContainer = GetObjectByTag("ntb310ip_dragonhorde");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prm000im_dragon_blood_boots.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, BLOOD_DRAGON_PLATE_BOOTS, TRUE );
    return;
  }
}