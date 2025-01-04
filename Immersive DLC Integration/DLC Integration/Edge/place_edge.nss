#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, EDGE ) == TRUE ) return;

  object oContainer = GetObjectByTag("den200ip_pick3_silversmith");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prm000im_edge_.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, EDGE, TRUE );
    return;
  }
}