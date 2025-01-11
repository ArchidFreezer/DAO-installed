#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, ALISTAIR_DOLL ) == TRUE ) return;

  object oContainer = GetObjectByTag("pre211ip_chest_iron");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"val_im_gift_doll.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, ALISTAIR_DOLL, TRUE );
    return;
  }
}