#include "wrappers_h"
#include "plt_immersive_feastday"

void RemoveItems(object[] aItems);
void RemoveAdditionalGifts(object oContainer);

// removes all generic gifts from Bodahn.
// This is a compatibility file for users installing mid playthrough or updating from an older version
void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, BODAHN_FEASTDAY) == TRUE ) return;

  object oContainer = GetObjectByTag("store_camp_bodahn");

  if (IsObjectValid(oContainer))
  {
    RemoveAdditionalGifts(oContainer);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, BODAHN_FEASTDAY, TRUE );
    return;
  }

}

// Function to remove all items of a given array
void RemoveItems(object[] aItems)
{
  int i;
  for (i = 0; i < GetArraySize(aItems); i++)
  {
    Safe_Destroy_Object(aItems[i]);
  }
}

// Removes additional gifts from Bodahn's inventory.
// This fixes a bug where Bodahn's inventory breaks from having too many items
void RemoveAdditionalGifts(object oContainer)
{
  object[] aParfaits = GetItemsInInventory(oContainer, GET_ITEMS_OPTION_ALL, 0, "val_im_gift_parfait", FALSE);
  object[] aThoughtfuls = GetItemsInInventory(oContainer, GET_ITEMS_OPTION_ALL, 0, "val_im_gift_thoughtful", FALSE);
  object[] aOnions = GetItemsInInventory(oContainer, GET_ITEMS_OPTION_ALL, 0, "val_im_gift_onion", FALSE);
  object[] aCoals = GetItemsInInventory(oContainer, GET_ITEMS_OPTION_ALL, 0, "val_im_gift_coal", FALSE);

  RemoveItems(aParfaits);
  RemoveItems(aThoughtfuls);
  RemoveItems(aOnions);
  RemoveItems(aCoals);
}
