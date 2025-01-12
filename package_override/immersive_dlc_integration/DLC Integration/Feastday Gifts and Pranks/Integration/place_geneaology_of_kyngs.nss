#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, COMPLEAT_GENEAOLOGY_OF_THE_KYNGS_OF_FERELDEN ) == TRUE ) return;

  object oContainer = GetObjectByTag("arl220ip_books_1");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"val_im_gift_sermon.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, COMPLEAT_GENEAOLOGY_OF_THE_KYNGS_OF_FERELDEN, TRUE );
    return;
  }
}