#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, MARK_OF_VIGILANCE ) == TRUE ) return;

  object oContainer = GetObjectByTag("genip_chest_ornate", 1);

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prm000im_vigilance.uti", oContainer, 1, "", TRUE);
                                                       
    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, MARK_OF_VIGILANCE, TRUE );
    return;
  }
}