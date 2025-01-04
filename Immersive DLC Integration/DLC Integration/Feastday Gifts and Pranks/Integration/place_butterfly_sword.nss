#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, BUTTERFLY_SWORD ) == TRUE ) return;

  object oContainer = GetObjectByTag("orz530ip_cocoon");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"val_im_gift_skull.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, BUTTERFLY_SWORD, TRUE );
    return;
  }
}