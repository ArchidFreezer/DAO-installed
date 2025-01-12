#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, STICK) == TRUE ) return;

  object oContainer = GetObjectByTag("ntb200ip_ironbark");

  if (IsObjectValid(oContainer))
  {
    object oItem = CreateItemOnObject(R"val_im_gift_ball.uti", oContainer, 1, "", TRUE);
    EquipItem(oContainer, oItem);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, STICK, TRUE );
    return;
  }
}