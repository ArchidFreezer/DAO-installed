#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, GRIMOIRE_OF_THE_FROZEN_WASTES ) == TRUE ) return;

  object oContainer = GetObjectByTag("gwb100cr_summoner_demon");
  object oContainer2 = GetObjectByTag("gwb100cr_lt_skel_scribe");
  if (IsObjectValid(oContainer) || IsObjectValid(oContainer2))
  {
    CreateItemOnObject(R"prm000im_grimoire_frozen.uti", oContainer, 1, "", TRUE);
    CreateItemOnObject(R"prm000im_grimoire_frozen.uti", oContainer2, 1, "", TRUE);
    
    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, GRIMOIRE_OF_THE_FROZEN_WASTES, TRUE );
    return;
  }
}