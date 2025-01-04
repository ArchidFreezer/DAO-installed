#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, CHASTITY_BELT ) == TRUE ) return;

  object oContainer = GetObjectByTag("liteip_rogue_letterchest");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"val_im_gift_chastity.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, CHASTITY_BELT, TRUE );
    return;
  }
}