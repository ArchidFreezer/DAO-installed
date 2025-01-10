#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, KING_MARICS_SHIELD) == TRUE ) return;

  object oContainer = GetObjectByTag("genip_chest_iron");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"val_im_gift_shield.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, KING_MARICS_SHIELD, TRUE );
    return;
  }
}