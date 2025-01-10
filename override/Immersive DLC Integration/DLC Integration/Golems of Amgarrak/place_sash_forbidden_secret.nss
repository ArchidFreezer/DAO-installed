#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, SASH_OF_FORBIDDEN_SECRETS ) == TRUE ) return;

  object oContainer = GetObjectByTag("orz320cr_lt_revenant");

  if (IsObjectValid(oContainer))
  {
    object oItem = CreateItemOnObject(R"prc_im_gib_acc_blt_dao.uti", oContainer, 1, "", TRUE);
    EquipItem(oContainer, oItem);        

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, SASH_OF_FORBIDDEN_SECRETS, TRUE );
    return;
  }
}