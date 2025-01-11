#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, SCENTED_SOAP) == TRUE ) return;

  object oContainer = GetObjectByTag("arl170ip_dwarven_chest");

  if (IsObjectValid(oContainer))
  {
    object oItem = CreateItemOnObject(R"val_im_gift_soap.uti", oContainer, 1, "", TRUE);
    EquipItem(oContainer, oItem);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, SCENTED_SOAP, TRUE );
    return;
  }
}