#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, FERAL_WOLF_CHARM ) == TRUE ) return;

  object oContainer = GetObjectByTag("pre200ip_iron_chest2");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prm000im_wolf_charm.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, FERAL_WOLF_CHARM, TRUE );
    return;
  }
}