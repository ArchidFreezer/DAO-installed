#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, VESTMENTS_OF_THE_SEER ) == TRUE ) return;

  object oContainer = GetObjectByTag("cir200cr_lt_rea_demon");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prc_im_reward3.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, VESTMENTS_OF_THE_SEER, TRUE );
    return;
  }
}