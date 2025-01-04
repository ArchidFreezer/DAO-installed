#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, DARKSPAWN_CHRONICLES ) == TRUE ) return;

  object oContainer = GetObjectByTag("drk_riordan", 0);

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prc_im_wep_mel_lsw_drk_dao.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, DARKSPAWN_CHRONICLES, TRUE );
    return;
  }
}