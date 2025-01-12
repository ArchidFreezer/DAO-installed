#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, CHANT_OF_LIGHT_UNABRIDGED ) == TRUE ) return;

  object oContainer = GetObjectByTag("lot100ip_holy_sym_chest");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"val_im_gift_chant.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, CHANT_OF_LIGHT_UNABRIDGED, TRUE );
    return;
  }
}