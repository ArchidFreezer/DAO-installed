#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, BULWARK_OF_THE_TRUE_KING ) == TRUE ) return;

  object oContainer = GetObjectByTag("genip_chest_ornate", 0);

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prm000im_bulwarktk.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, BULWARK_OF_THE_TRUE_KING, TRUE );
    return;
  }
}