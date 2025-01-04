#include "wrappers_h"
#include "plt_immersive_dlc"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_DLC, AMULET_OF_THE_WAR_MAGE ) == TRUE ) return;

  object oContainer = GetObjectByTag("den961cr_blood_mage_last");

  if (IsObjectValid(oContainer))
  {
    object oItem = CreateItemOnObject(R"prm000im_warmage.uti", oContainer, 1, "", TRUE);
    EquipItem(oContainer, oItem);    

    WR_SetPlotFlag( PLT_IMMERSIVE_DLC, AMULET_OF_THE_WAR_MAGE, TRUE );
    return;
  }
}