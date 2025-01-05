#include "wrappers_h"
#include "plt_no_orzammar_outsiders"

//equips berserkers with orz260cr_prov_fight_3's armor set, champion with orz260cr_prov_fight_2's
void main()
{
  if ( WR_GetPlotFlag( PLT_NO_ORZAMMAR_OUTSIDERS, PROVING_OUTSIDERS ) == TRUE ) return;

  string sBerserker = "orz260cr_prov_fight_3";  
  string sChampion = "orz260cr_prov_fight_2";  
  object oArea = GetObjectByTag("orz260ar_proving");
  object[] oFighters = GetObjectsInArea(oArea, "orz260cr_prov_lite");

  int i;
  for (i = 0; i < GetArraySize(oFighters); i++)
  {
    string sResRef = GetResRef(oFighters[i]);
    if (sResRef == "orz260cr_prov_fight_0"
        || sResRef == "orz260cr_prov_fight_7"
        || sResRef == "orz260cr_prov_fight_9")
    {
      LoadItemsFromTemplate(oFighters[i], sBerserker); 
    }
    else if (sResRef == "orz260cr_prov_fight_8")
    {
      LoadItemsFromTemplate(oFighters[i], sChampion); 
    }
  }

  WR_SetPlotFlag( PLT_NO_ORZAMMAR_OUTSIDERS, PROVING_OUTSIDERS, TRUE );
}