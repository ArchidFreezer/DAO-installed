#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, HIGH_REGARD_OF_HOUSE_DACE ) == TRUE ) return;

  object oContainer = GetObjectByTag("orz310ip_chest", 0);

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prc_im_gib_acc_amu_dao.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, HIGH_REGARD_OF_HOUSE_DACE, TRUE );
    return;
  }
}