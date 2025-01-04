#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, HELM_OF_THE_DEEP ) == TRUE ) return;

  object oContainer = GetObjectByTag("genip_sarcophagus_dwarven", 12);

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prm000im_helmdeep.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, HELM_OF_THE_DEEP, TRUE );
    return;
  }
}