#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, CAT_LADYS_HOBBLESTICK ) == TRUE ) return;

  object oContainer = GetObjectByTag("den960cr_rabid_wardog", 0);

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"val_im_gift_stick.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, CAT_LADYS_HOBBLESTICK, TRUE );
    return;
  }
}