#include "wrappers_h"
#include "plt_tsm_tegrin_plot"

void main()
{
  if ( WR_GetPlotFlag( PLT_TSM_TEGRIN_PLOT, TSM_TEGRIN_CHECK_FLAG ) == TRUE ) return;

  object oContainer = GetObjectByTag("store_ran700cr_merchant");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"gen_im_gift_map4.uti", oContainer, 1, "", TRUE);
    CreateItemOnObject(R"gen_im_gift_armband.uti", oContainer, 1, "", TRUE);
    CreateItemOnObject(R"gen_im_gift_ring4.uti", oContainer, 1, "", TRUE);
    CreateItemOnObject(R"gen_im_gift_earring.uti", oContainer, 1, "", TRUE);
    CreateItemOnObject(R"gen_im_gift_ring3.uti", oContainer, 1, "", TRUE);
    CreateItemOnObject(R"gen_im_acc_amu_am8.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_TSM_TEGRIN_PLOT, TSM_TEGRIN_CHECK_FLAG, TRUE );
  }
}