#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, RARE_ANTIVAN_BRANDY) == TRUE ) return;

  object oContainer = GetObjectByTag("genip_crate_wood_large");

  if (IsObjectValid(oContainer))
  {
    object oItem = CreateItemOnObject(R"val_im_gift_brandy.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, RARE_ANTIVAN_BRANDY, TRUE );
    return;
  }
}