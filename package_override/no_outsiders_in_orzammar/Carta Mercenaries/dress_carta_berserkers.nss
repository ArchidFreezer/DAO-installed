#include "wrappers_h"
#include "plt_no_orzammar_outsiders"

void DressBerserker(object oTarget);

//equips berserkers with orz260cr_prov_fight_3's armor set
void main()
{
  if ( WR_GetPlotFlag( PLT_NO_ORZAMMAR_OUTSIDERS, CARTA_BERSERKERS ) == TRUE ) return;

  object oArea = GetObjectByTag("orz230ar_gangsters_hideout");
  object[] oQunari = GetObjectsInArea(oArea, "orz230cr_qunari");
  object[] oElves = GetObjectsInArea(oArea, "orz230cr_elf");

  int i;
  for (i = 0; i < GetArraySize(oQunari); i++)
  {
    DressBerserker(oQunari[i]);
  }

  for (i = 0; i < GetArraySize(oElves); i++)
  {
    DressBerserker(oElves[i]);
  }

  WR_SetPlotFlag( PLT_NO_ORZAMMAR_OUTSIDERS, CARTA_BERSERKERS, TRUE );
}

void DressBerserker(object oTarget)
{
/*
  //create dummy character that armor is taken from
  object oArea = GetObjectByTag("orz230ar_gangsters_hideout");
  vector vLocation = Vector(0.0f, 0.0f, 100.0f);
  object oDummy = CreateObject(
    OBJECT_TYPE_CREATURE,
    R"orz260cr_prov_fight_3.utc",
    Location(oArea, vLocation, 0.0f)
  );

  object oArmor = GetItemInEquipSlot(INVENTORY_SLOT_CHEST, oDummy);
  EquipItem(oTarget, oArmor, INVENTORY_SLOT_CHEST);
  object oGloves = GetItemInEquipSlot(INVENTORY_SLOT_GLOVES, oDummy);
  EquipItem(oTarget, oGloves, INVENTORY_SLOT_GLOVES);
  object oBoots = GetItemInEquipSlot(INVENTORY_SLOT_BOOTS, oDummy);
  EquipItem(oTarget, oBoots, INVENTORY_SLOT_BOOTS);
  object oWeapon = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oDummy);
  EquipItem(oTarget, oWeapon, INVENTORY_SLOT_MAIN);

  Safe_Destroy_Object(oDummy);  
  */
  LoadItemsFromTemplate(oTarget, "orz260cr_prov_fight_3");   
/*   
  object[] oItems = GetItemsInInventory(oTarget, GET_ITEMS_OPTION_ALL);
  int nList = GetArraySize(oItems);
  int nCount = 0;
  for (nCount = 0; nCount < nList; nCount++)
  {
    EquipItem(oPC, oItems[nCount]);
  }
  */
}