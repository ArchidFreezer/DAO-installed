#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, EMBRIS_MANY_POCKETS ) == TRUE ) return;

  object oContainer = GetObjectByTag("cir220cr_tranquil_mon", 0);

  if (IsObjectValid(oContainer))
  {
    object oItem = CreateItemOnObject(R"prm000im_embri.uti", oContainer, 1, "", TRUE);
    EquipItem(oContainer, oItem);        

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, EMBRIS_MANY_POCKETS, TRUE );
    return;
  }
}