#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, LUCKY_STONE ) == TRUE ) return;

  object oContainer = GetObjectByTag("pre211ip_chest_iron");
  
  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prm000im_luckystone.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, LUCKY_STONE, TRUE );
    return;
  }
}