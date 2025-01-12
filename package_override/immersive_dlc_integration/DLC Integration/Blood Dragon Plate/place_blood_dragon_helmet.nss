#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, BLOOD_DRAGON_PLATE_HELMET ) == TRUE ) return;

  object oContainer = GetObjectByTag("orz320cr_lt_dragon");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"prm000im_dragon_blood_helm.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, BLOOD_DRAGON_PLATE_HELMET, TRUE );
    return;
  }
}