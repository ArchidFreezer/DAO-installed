#include "wrappers_h"
#include "plt_tsm_garin_plot"

void main()
{
  if ( WR_GetPlotFlag( PLT_TSM_GARIN_PLOT, TSM_GARIN_CHECK_FLAG ) == TRUE ) return;

  object oContainer = GetObjectByTag("store_orz200cr_garin");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"gem_im_gift_gar.uti", oContainer, 1, "", TRUE);
    CreateItemOnObject(R"gen_im_gift_dia.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_TSM_GARIN_PLOT, TSM_GARIN_CHECK_FLAG, TRUE );
  }
}