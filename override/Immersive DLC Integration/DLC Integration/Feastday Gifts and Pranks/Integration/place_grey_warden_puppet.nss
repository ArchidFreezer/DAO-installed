#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, GREY_WARDEN_HAND_PUPPET) == TRUE ) return;

  object oContainer = GetObjectByTag("genip_chest_wood_1", 4);

  if (IsObjectValid(oContainer))
  {
    object oItem = CreateItemOnObject(R"val_im_gift_horse.uti", oContainer, 1, "", TRUE);
    EquipItem(oContainer, oItem);    

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, GREY_WARDEN_HAND_PUPPET, TRUE );
    return;
  }
}