#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, BLIGHTBLOOD ) == TRUE ) return;

  object oContainer = GetObjectByTag("kcc100cr_commander_d");

  if (IsObjectValid(oContainer))
  {
    object oItem = CreateItemOnObject(R"prc_im_wep_mel_lsw_drk_dao.uti", oContainer, 1, "", TRUE);
    EquipItem(oContainer, oItem, INVENTORY_SLOT_MAIN, 0);
    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, BLIGHTBLOOD, TRUE);
    return;
  }
}