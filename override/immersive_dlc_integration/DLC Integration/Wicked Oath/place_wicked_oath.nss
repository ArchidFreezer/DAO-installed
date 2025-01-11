#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, WICKED_OATH ) == TRUE ) return;

  object oContainer = GetObjectByTag("den920cr_taliesen");

  if (IsObjectValid(oContainer))
  {
    object oItem = CreateItemOnObject(R"prm000im_wickedoath.uti", oContainer, 1, "", TRUE);
    EquipItem(oContainer, oItem);       

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, WICKED_OATH, TRUE );
    return;
  }
}