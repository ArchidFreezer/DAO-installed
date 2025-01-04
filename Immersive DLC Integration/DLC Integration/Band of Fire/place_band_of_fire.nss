#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, BAND_OF_FIRE ) == TRUE ) return;

  object oContainer = GetObjectByTag("store_den230cr_proprietor");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prm000im_band_of_fire.uti", oContainer, 1, "", TRUE);
    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, BAND_OF_FIRE, TRUE );
    return;
  }
}