#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, FORMATI_TOME ) == TRUE ) return;

  object oContainer = GetObjectByTag("genip_corpse_charred", 0);
  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"gen_im_qck_book_formari.uti", oContainer, 1, "", TRUE);
    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, FORMATI_TOME, TRUE );
    return;
  }
}