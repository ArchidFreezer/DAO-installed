#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, THOUGHTFUL_GIFT) == TRUE ) return;

  object oContainer = GetObjectByTag("store_ran700cr_merchant");

  if (IsObjectValid(oContainer))
  {
    object oItem = CreateItemOnObject(R"val_im_gift_thoughtful.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, THOUGHTFUL_GIFT, TRUE );
    return;
  }
}