#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, GUILDMASTERS_BELT ) == TRUE ) return;

  object oContainer = GetObjectByTag("genip_chest_wood_1", 0);

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prm000im_gm_belt.uti", oContainer, 1, "", TRUE);
    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, GUILDMASTERS_BELT, TRUE );
    return;
  }
}