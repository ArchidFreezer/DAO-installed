#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, CINCH_OF_SKILLFUL_MANEUVERING ) == TRUE ) return;

  object oContainer = GetObjectByTag("genip_chest_iron", 0);

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prc_im_reward4.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, CINCH_OF_SKILLFUL_MANEUVERING, TRUE );
    return;
  }
}