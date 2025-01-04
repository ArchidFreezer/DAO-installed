#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, ROTTEN_ONION) == TRUE ) return;

  object oContainer = GetObjectByTag("store_orz530cr_ruck");

  if (IsObjectValid(oContainer))
  {
    object oItem = CreateItemOnObject(R"val_im_gift_onion.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, ROTTEN_ONION, TRUE );
    return;
  }
}