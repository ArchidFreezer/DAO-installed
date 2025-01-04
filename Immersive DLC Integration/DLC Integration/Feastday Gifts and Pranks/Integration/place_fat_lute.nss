#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, FAT_LUTE) == TRUE ) return;

  object oContainer = GetObjectByTag("den250ip_chest_iron");

  if (IsObjectValid(oContainer))
  {
    object oItem = CreateItemOnObject(R"val_im_gift_lute.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, FAT_LUTE, TRUE );
    return;
  }
}