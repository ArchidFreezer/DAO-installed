#include "wrappers_h"
#include "plt_tsm_owen_plot"

void main()
{
  if ( WR_GetPlotFlag( PLT_TSM_OWEN_PLOT, TSM_FARSONG_CHECK_FLAG ) == TRUE ) return;

  object oContainer = GetObjectByTag("store_arl120cr_owen_extra");

  if (IsObjectValid(oContainer))
  {
    CreateItemOnObject(R"gen_im_wep_rng_lbw_fsn.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_TSM_OWEN_PLOT, TSM_FARSONG_CHECK_FLAG, TRUE );
  }
}