#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, PET_ROCK) == TRUE ) return;

  object oContainer = GetObjectByTag("genip_rubble", 2);

  if (IsObjectValid(oContainer))
  {
    object oItem = CreateItemOnObject(R"val_im_gift_rock.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, PET_ROCK, TRUE );
    return;
  }
}