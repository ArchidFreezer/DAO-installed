#include "wrappers_h"
#include "utility_h"
#include "lit_constants_h"
#include "plt_lite_fite_deserters"  
#include "plt_lite_mage_banastor"
#include "plt_cod_lite_tow_banastor"
#include "plt_lite_chant_red_zombie"

const string LITE_IM_CORPSE_GALL = "gen_it_corpse_gall";

// Something is causing plot item stacks to get their ITEM_SEND_ACQUIRED_EVENT flag set to 0
// New items added to that stack don't send acquired event, which breaks quest.

void main()
{                                           
   object oPC = GetMainControlled();
   int nIndex;
   int nColor = 0xffffff;
   float fDuration = 15.0f;
   string sMessage;
   
    
   // Dereliction of Duty fix
   if(WR_GetPlotFlag(PLT_LITE_FITE_DESERTERS, DESERTERS_QUEST_GIVEN) == TRUE &&
      WR_GetPlotFlag(PLT_LITE_FITE_DESERTERS, DESERTERS_FOUND) == FALSE)
   {
      object [] arrSuppliesCount = GetItemsInInventory(oPC, GET_ITEMS_OPTION_ALL, 0, LITE_IM_DESERTERS_SUPPLIES);
      if (IsObjectValid(arrSuppliesCount[0]) == TRUE)
      {
         if(GetLocalInt(arrSuppliesCount[0], "ITEM_SEND_ACQUIRED_EVENT") == 0)
         {
            int nSuppliesCount = GetItemStackSize(arrSuppliesCount[0]);
            UT_RemoveItemFromInventory(rLITE_IM_FITE_DESERTERS_SUP,nSuppliesCount,oPC,LITE_IM_DESERTERS_SUPPLIES);
            if(nSuppliesCount >= 1)
               WR_SetPlotFlag(PLT_LITE_FITE_DESERTERS, DESERTERS_KILLED_ONE, TRUE, TRUE);            
            if(nSuppliesCount >= 2)
               WR_SetPlotFlag(PLT_LITE_FITE_DESERTERS, DESERTERS_KILLED_TWO, TRUE, TRUE);         
            UT_AddItemToInventory(rLITE_IM_FITE_DESERTERS_SUP,nSuppliesCount,oPC,LITE_IM_DESERTERS_SUPPLIES,TRUE,FALSE);
            
            sMessage = "Stack of Guild Supplies fixed! Please report area you last transitioned FROM to Qwinn at Nexusmods!";
            DisplayFloatyMessage(oPC,sMessage,0,nColor,fDuration);
         }
      }
   }
      
   // Scrolls of Banastor fix   
   if(WR_GetPlotFlag(PLT_LITE_MAGE_BANASTOR, BANASTOR_SCROLLS_FOUND) == FALSE)
   {   

      object [] arrScrollCount = GetItemsInInventory(oPC, GET_ITEMS_OPTION_ALL, 0, LITE_IM_MAGE_BANASTOR);
      if (IsObjectValid(arrScrollCount[0]) == TRUE)
      {
         if(GetLocalInt(arrScrollCount[0], "ITEM_SEND_ACQUIRED_EVENT") == 0)
         {
            int nScrollCount = GetItemStackSize(arrScrollCount[0]);
            
            UT_RemoveItemFromInventory(rLITE_IM_MAGE_BANASTOR,nScrollCount,oPC,LITE_IM_MAGE_BANASTOR);
            if (nScrollCount >= 1)
                WR_SetPlotFlag(PLT_COD_LITE_TOW_BANASTOR, TOW_BANASTOR_1, TRUE, TRUE);
            if (nScrollCount >= 2)
                WR_SetPlotFlag(PLT_COD_LITE_TOW_BANASTOR, TOW_BANASTOR_2, TRUE, TRUE);
            if (nScrollCount >= 3)
                WR_SetPlotFlag(PLT_COD_LITE_TOW_BANASTOR, TOW_BANASTOR_3, TRUE, TRUE);
            if (nScrollCount >= 4)
                WR_SetPlotFlag(PLT_COD_LITE_TOW_BANASTOR, TOW_BANASTOR_4, TRUE, TRUE);
            UT_AddItemToInventory(rLITE_IM_MAGE_BANASTOR,nScrollCount,oPC,LITE_IM_MAGE_BANASTOR,TRUE,FALSE);
            
            sMessage = "Stack of Scrolls of Banastor fixed! Please report area you last transitioned FROM to Qwinn at Nexusmods!";
            DisplayFloatyMessage(oPC,sMessage,0,nColor,fDuration);
         }
      }
   }
   
   // Skin Deep fix
   if(WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_ACCEPTED) == TRUE && 
      WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_COMPLETE_WITH_18) == FALSE &&
      WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_CLOSED_WITH_9) == FALSE)
   {
      object [] arrGallCount = GetItemsInInventory(oPC, GET_ITEMS_OPTION_ALL, 0, LITE_IM_CORPSE_GALL);
      if (IsObjectValid(arrGallCount[0]) == TRUE)
      {
         if(GetLocalInt(arrGallCount[0], "ITEM_SEND_ACQUIRED_EVENT") == 0)
         {
            int nGallCount = GetItemStackSize(arrGallCount[0]);
            UT_RemoveItemFromInventory(rLITE_IM_CORPSE_GALL,nGallCount,oPC,LITE_IM_CORPSE_GALL);
            UT_AddItemToInventory(rLITE_IM_CORPSE_GALL,nGallCount,oPC,LITE_IM_CORPSE_GALL,TRUE,FALSE);
            
            sMessage = "Stack of Corpse Galls fixed! Please report area you last transitioned FROM to Qwinn at Nexusmods!";
            DisplayFloatyMessage(oPC,sMessage,0,nColor,fDuration);
         }
      }
   }
}
