#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, ORLESIAN_MASK) == TRUE ) return;

  object oContainer = GetObjectByTag("genip_vanity_2", 0);

  if (IsObjectValid(oContainer))
  {
    object oItem = CreateItemOnObject(R"val_im_gift_mask.uti", oContainer, 1, "", TRUE);
    EquipItem(oContainer, oItem);    

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, ORLESIAN_MASK, TRUE );
    return;
  }
}