#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, AMULET_OF_MEMORIES ) == TRUE ) return;

  object oContainer = GetObjectByTag("cir200cr_lt_rea_demon");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"val_im_gift_amulet.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, AMULET_OF_MEMORIES, TRUE );
    return;
  }
}