#include "wrappers_h"
#include "plt_no_orzammar_outsiders"

void DressBerserker(object oTarget);

// equips berserker with orz510cr_ambusher's armor set
void main()
{
  
  if ( WR_GetPlotFlag( PLT_NO_ORZAMMAR_OUTSIDERS, CARADIN_BERSERKERS ) == TRUE ) {
    return;
  }

  object oTarget = GetObjectByTag("orz510cr_ambusher_1");
  
  DressBerserker(oTarget);
  
  WR_SetPlotFlag( PLT_NO_ORZAMMAR_OUTSIDERS, CARADIN_BERSERKERS, TRUE );

}

void DressBerserker(object oTarget)
{
  LoadItemsFromTemplate(oTarget, "orz510cr_ambusher");
}