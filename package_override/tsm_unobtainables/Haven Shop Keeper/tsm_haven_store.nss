#include "wrappers_h"
#include "plt_tsm_haven_plot"

void main()
{
  if ( WR_GetPlotFlag( PLT_TSM_HAVEN_PLOT, TSM_HAVEN_CHECK_FLAG ) == TRUE ) return;

  object oContainer = GetObjectByTag("store_urn130cr_shopkeeper");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"gen_im_cft_hrb_406.uti", oContainer, 1, "", TRUE);
    CreateItemOnObject(R"gen_im_qck_book_attribute2.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_TSM_HAVEN_PLOT, TSM_HAVEN_CHECK_FLAG, TRUE );
  }
}