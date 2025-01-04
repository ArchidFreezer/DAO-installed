#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  //ostagar night
  object oContainer = GetObjectByTag("pre100ip_wizards_chest");

  if (IsObjectValid(oContainer))
  {    
    if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, MEMORY_BAND_OSTAGAR ) == TRUE ) return;
     
    CreateItemOnObject(R"gen_im_acc_rng_exp.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, MEMORY_BAND_OSTAGAR, TRUE );
    return;
  }

  //return to ostagar
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, MEMORY_BAND_RETURN ) == TRUE ) return;

  object oContainer2 = GetObjectByTag("kcc100ip_wizards_chest");

  if (IsObjectValid(oContainer2))
  {
    CreateItemOnObject(R"gen_im_acc_rng_exp.uti", oContainer2, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, MEMORY_BAND_RETURN, TRUE );
  }
}