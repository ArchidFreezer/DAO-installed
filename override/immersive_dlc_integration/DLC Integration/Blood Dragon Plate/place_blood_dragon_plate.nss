#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, BLOOD_DRAGON_PLATE ) == TRUE ) return;

  object oContainer = GetObjectByTag("urn220cr_dragon");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prm000im_dragon_blood_plate.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, BLOOD_DRAGON_PLATE, TRUE );
    return;
  }
}