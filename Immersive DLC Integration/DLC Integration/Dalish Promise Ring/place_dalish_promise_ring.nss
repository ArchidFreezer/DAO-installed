#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, DALISH_PROMISE_RING ) == TRUE ) return;

  object oContainer = GetObjectByTag("ntb100ip_lanaya_chest");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prm000im_dalish_ring.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, DALISH_PROMISE_RING, TRUE );
    return;
  }
}