#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, PEARL_OF_THE_ANOINTED ) == TRUE ) return;

  object oContainer = GetObjectByTag("urn110ip_chest");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prm000im_pearlan.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, PEARL_OF_THE_ANOINTED, TRUE );
    return;
  }
}