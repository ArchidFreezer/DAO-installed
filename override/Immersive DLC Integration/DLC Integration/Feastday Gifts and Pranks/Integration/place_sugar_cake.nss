#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, SUGAR_CAKE) == TRUE ) return;

  object oContainer = GetObjectByTag("store_den220cr_bartender");

  if (IsObjectValid(oContainer))
  {
    object oItem = CreateItemOnObject(R"val_im_gift_parfait.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, SUGAR_CAKE, TRUE );
    return;
  }
}