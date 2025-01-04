#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, BATTLEDRESS_OF_THE_PROVOCATEUR ) == TRUE ) return;

  object oContainer = GetObjectByTag("den250ip_chest_iron");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prc_dao_lel_im_arm_cht_01.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, BATTLEDRESS_OF_THE_PROVOCATEUR, TRUE );
    return;
  }
}