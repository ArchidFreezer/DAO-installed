#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, BREGANS_BOW ) == TRUE ) return;

  object oContainer = GetObjectByTag("genip_weapon_stand_2");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prm000im_griffbeak.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, BREGANS_BOW, TRUE );
    return;
  }
}