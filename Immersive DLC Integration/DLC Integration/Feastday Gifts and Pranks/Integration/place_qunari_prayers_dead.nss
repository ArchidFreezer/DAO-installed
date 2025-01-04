#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, QUNARI_PRAYERS_FOR_THE_DEAD) == TRUE ) return;

  object oContainer = GetObjectByTag("store_orz100cr_faryn");

  if (IsObjectValid(oContainer))
  {
    object oItem = CreateItemOnObject(R"val_im_gift_cookie.uti", oContainer, 1, "", TRUE);
    EquipItem(oContainer, oItem);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, QUNARI_PRAYERS_FOR_THE_DEAD, TRUE );
    return;
  }
}