#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, FINAL_REASON ) == TRUE ) return;

  object oContainer = GetObjectByTag("cir210ip_lt_belcache");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prm000im_final_reason.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, FINAL_REASON, TRUE );
    return;
  }
}