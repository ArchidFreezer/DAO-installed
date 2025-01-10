#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, UGLY_BOOTS ) == TRUE ) return;

  object oContainer = GetObjectByTag("genip_pile_filth");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"val_im_gift_boots.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, UGLY_BOOTS, TRUE );
    return;
  }
}