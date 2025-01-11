#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, DRAGONBONE_CLEAVER ) == TRUE ) return;

  object oContainer = GetObjectByTag("ntb340cr_lt_revenant");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prc_im_reward1.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, DRAGONBONE_CLEAVER, TRUE );
    return;
  }
}