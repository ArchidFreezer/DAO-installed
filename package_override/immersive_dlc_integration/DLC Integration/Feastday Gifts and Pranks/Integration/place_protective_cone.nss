#include "wrappers_h"
#include "plt_immersive_feastday"

void main()   
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, PROTECTIVE_CONE) == TRUE ) return;

  object oContainer = GetObjectByTag("genip_chest_wood_1", 0);

  if (IsObjectValid(oContainer))
  {
    object oItem = CreateItemOnObject(R"val_im_gift_muzzle.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, PROTECTIVE_CONE, TRUE );
    return;
  }
}