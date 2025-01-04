#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, LIONS_PAW ) == TRUE ) return;

  object oContainer = GetObjectByTag("litip_kor_trail_cache");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prm000im_lionspaw.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, LIONS_PAW, TRUE );
    return;
  }
}