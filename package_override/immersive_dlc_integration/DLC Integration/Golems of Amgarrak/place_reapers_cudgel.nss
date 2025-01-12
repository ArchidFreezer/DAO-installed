#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, REAPERS_CUDGEL ) == TRUE ) return;

  object oContainer = GetObjectByTag("orz510ip_drifters_cache", 0);

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prc_im_gib_wep_mac_dao.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, REAPERS_CUDGEL, TRUE );
    return;
  }
}