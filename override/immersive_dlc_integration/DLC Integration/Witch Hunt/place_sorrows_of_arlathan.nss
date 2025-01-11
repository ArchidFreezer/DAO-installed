#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, SORROWS_OF_ARLATHAN ) == TRUE ) return;

  object oContainer = GetObjectByTag("ntb330ip_codex_coffin");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prc_im_reward2.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, SORROWS_OF_ARLATHAN, TRUE );
    return;
  }
}