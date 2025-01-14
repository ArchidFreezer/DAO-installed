#include "sys_itemsets_h"
#include "utility_h"
#include "plt_af_nohelmet"

const resource AF_ITR_MISC_BOOK_NOHELMET      = R"af_misc_book_nohelmet.uti";
const string   AF_IT_MISC_BOOK_NOHELMET       = "af_misc_book_nohelmet";
const int      AF_POPUP_STREF_NOHELMET        = 6610003;

///////////////////////
// Add the the no helmet book to the hero inventory
//
void NoHelmetBookAdd() {
    object oBook = GetObjectByTag(AF_IT_MISC_BOOK_NOHELMET);
    if (!IsObjectValid(oBook)) UT_AddItemToInventory(AF_ITR_MISC_BOOK_NOHELMET,1);
}

///////////////////////
// Show any helmet in the inventory screen
//
void NoHelmetShowInventory() {
    PrintToLog("---> NoHelmetShowInventory");
    if (WR_GetPlotFlag( PLT_AF_NOHELMET, HELMET_SLOT_ACTIVE ) == FALSE )
    {
        // Swap helmets to make visible
        int i;
        object[] oParty;
        object oCloakHelm;
        object oMember;
        string oAreaStr = ObjectToString(GetArea(GetHero()));

        oParty = GetPartyList();
        int nSize = GetArraySize(oParty);
        // Whenever the party size is 1, get from party pool instead
        if (nSize==1)
        {
            oParty = GetPartyPoolList();
            nSize = GetArraySize(oParty);
        }

        for (i = 0; i < nSize; i++)
        {
            oMember = oParty[i];
            oCloakHelm = GetItemInEquipSlot(8,oMember);
            // if there is a helmet in the cloak slot, move it to the helmet slot
            if (ObjectToString(oCloakHelm)!="-1")
            {
                // Try to kick out any helm in the helm slot
                UnequipItem(oMember,oCloakHelm);
                EquipItem(oMember,oCloakHelm,5);
            }
        }
        WR_SetPlotFlag( PLT_AF_NOHELMET, HELMET_SLOT_ACTIVE, TRUE );
    }
}

////////////////////
// Apply item set values when the helmet is not shown
//
void NoHelmetItemSetUpdate(object oCreature) {

    PrintToLog("---> NoHelmetItemSetUpdate");

    #ifdef DEBUG
    LogTrace(LOG_CHANNEL_TEMP, "Forcing Item Set Update");
    #endif

    // remove all flag effects
    effect[] eEffects = GetEffectsByAbilityId(oCreature, ABILITY_ITEM_SET);
    RemoveEffectArray(oCreature, eEffects);

    // get equipped items
    object[] oItems;
    oItems[0] = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oCreature);
    oItems[1] = GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND, oCreature);
    oItems[2] = GetItemInEquipSlot(INVENTORY_SLOT_CHEST, oCreature);
    if (IsObjectValid(GetItemInEquipSlot(INVENTORY_SLOT_CLOAK, oCreature)))
    {
        oItems[3] = GetItemInEquipSlot(INVENTORY_SLOT_CLOAK, oCreature);
    } else
    {
        oItems[3] = GetItemInEquipSlot(INVENTORY_SLOT_HEAD, oCreature);
    }
    oItems[4] = GetItemInEquipSlot(INVENTORY_SLOT_GLOVES, oCreature);
    oItems[5] = GetItemInEquipSlot(INVENTORY_SLOT_BOOTS, oCreature);
    oItems[6] = GetItemInEquipSlot(INVENTORY_SLOT_BELT, oCreature);
    oItems[7] = GetItemInEquipSlot(INVENTORY_SLOT_RING1, oCreature);
    oItems[8] = GetItemInEquipSlot(INVENTORY_SLOT_RING2, oCreature);
    oItems[9] = GetItemInEquipSlot(INVENTORY_SLOT_NECK, oCreature);
    oItems[10] = GetItemInEquipSlot(INVENTORY_SLOT_RANGEDAMMO, oCreature);
    oItems[11] = GetItemInEquipSlot(INVENTORY_SLOT_DOG_COLLAR, oCreature);
    oItems[12] = GetItemInEquipSlot(INVENTORY_SLOT_DOG_WARPAINT, oCreature);
    oItems[13] = GetItemInEquipSlot(INVENTORY_SLOT_SHALE_CHEST, oCreature); // shale armor
    oItems[14] = GetItemInEquipSlot(INVENTORY_SLOT_SHALE_RIGHTARM, oCreature); // shale weapon
    oItems[15] = GetItemInEquipSlot(INVENTORY_SLOT_CLOAK, oCreature);
    oItems[16] = GetItemInEquipSlot(INVENTORY_SLOT_BITE, oCreature);
    oItems[17] = GetItemInEquipSlot(INVENTORY_SLOT_SHALE_SHOULDERS, oCreature);
    oItems[18] = GetItemInEquipSlot(INVENTORY_SLOT_SHALE_LEFTARM, oCreature);

    #ifdef DEBUG
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[0] = " + GetTag(oItems[0]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[1] = " + GetTag(oItems[1]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[2] = " + GetTag(oItems[2]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[3] = " + GetTag(oItems[3]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[4] = " + GetTag(oItems[4]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[5] = " + GetTag(oItems[5]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[6] = " + GetTag(oItems[6]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[7] = " + GetTag(oItems[7]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[8] = " + GetTag(oItems[8]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[9] = " + GetTag(oItems[9]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[10] = " + GetTag(oItems[10]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[11] = " + GetTag(oItems[11]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[12] = " + GetTag(oItems[12]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[13] = " + GetTag(oItems[13]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[14] = " + GetTag(oItems[14]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[15] = " + GetTag(oItems[15]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[16] = " + GetTag(oItems[16]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[17] = " + GetTag(oItems[17]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[18] = " + GetTag(oItems[18]));
    #endif

    // construct slot array
    int nSlotArray;
    int nMax = 19;
    int nCount = 0;
    int nCountValue = 1;
    for (nCount = 0; nCount < nMax; nCount++)
    {
        // if item in this slot is valid
        if (IsObjectValid(oItems[nCount]) == TRUE)
        {
            nSlotArray += nCountValue;
        }

        nCountValue *= 2;
    }
    #ifdef DEBUG
    LogTrace(LOG_CHANNEL_TEMP, "  nSlotArray = " + ToString(nSlotArray));
    #endif

    // if there are items equipped
    if (nSlotArray > 0)
    {
        int nItemSet;
        int nSetArray;
        int bValid;
        int nCount2;
        int nCount2Value;
        int nItemSet2;

        // go through each item
        //nMax = 19;
        nCount = 0;
        nCountValue = 1;
        for (nCount = 0; nCount < nMax; nCount++)
        {
            #ifdef DEBUG
            LogTrace(LOG_CHANNEL_TEMP, "  nCount = " + ToString(nCount));
            LogTrace(LOG_CHANNEL_TEMP, "    nSlotArray = " + ToString(nSlotArray));
            LogTrace(LOG_CHANNEL_TEMP, "    nCountValue = " + ToString(nCountValue));
            #endif

            // if this slot is in the slot array
            if ((nSlotArray & nCountValue) == nCountValue)
            {
                #ifdef DEBUG
                LogTrace(LOG_CHANNEL_TEMP, "    nCountValue valid.");
                #endif

                // get item set
                nItemSet = GetLocalInt(oItems[nCount], ITEM_SET);
                #ifdef DEBUG
                LogTrace(LOG_CHANNEL_TEMP, "    nItemSet = " + ToString(nItemSet));
                #endif
                if (nItemSet > 0)
                {
                    // get set array
                    nSetArray = GetM2DAInt(TABLE_ITEM_SETS, "Slots", nItemSet);
                    #ifdef DEBUG
                    LogTrace(LOG_CHANNEL_TEMP, "    nSetArray = " + ToString(nSetArray));
                    #endif

                    // if contained within slot array
                    if ((nSlotArray & nSetArray) == nSetArray)
                    {
                        #ifdef DEBUG
                        LogTrace(LOG_CHANNEL_TEMP, "      nSetArray valid.");
                        #endif

                        // remove current slot from consideration
                        nSlotArray -= nCountValue;

                        // check each component item
                        bValid = TRUE;
                        nCount2Value = nCountValue * 2;
                        for (nCount2 = nCount + 1; nCount2 < nMax; nCount2++)
                        {
                            #ifdef DEBUG
                            LogTrace(LOG_CHANNEL_TEMP, "      nCount2 = " + ToString(nCount2));
                            LogTrace(LOG_CHANNEL_TEMP, "        nSetArray = " + ToString(nSetArray));
                            LogTrace(LOG_CHANNEL_TEMP, "        nCount2Value = " + ToString(nCount2Value));
                            #endif

                            // if a valid item in the set
                            if ((nSetArray & nCount2Value) == nCount2Value)
                            {
                                // if same set, subtract from slot array
                                if (GetLocalInt(oItems[nCount2], ITEM_SET) == nItemSet)
                                {
                                    #ifdef DEBUG
                                    LogTrace(LOG_CHANNEL_TEMP, "        Item set matches.");
                                    #endif
                                    nSlotArray -= nCount2Value;
                                } else
                                {
                                    bValid = FALSE;
                                }
                            }

                            nCount2Value *= 2;

                            if (nCount2Value > nSetArray)
                            {
                                nCount2 = nMax;
                            }
                        }

                        if (bValid == TRUE)
                        {
                            // if bValid TRUE, apply effect
                            #ifdef DEBUG
                            LogTrace(LOG_CHANNEL_TEMP, "      Set requirements met.");
                            #endif
                            ItemSet_SetEffectArray(oCreature, nItemSet);
                        }
                    } else
                    {
                        // remove this slot
                        nSlotArray -= nCountValue;
                    }
                } else
                {
                    // remove this slot
                    nSlotArray -= nCountValue;
                }
            }

            // if there are no more items to examine
            if (nSlotArray <= 0)
            {
                nCount = nMax;
            }

            nCountValue *= 2;
        }
    }
    #ifdef DEBUG
    LogTrace(LOG_CHANNEL_TEMP, "  Completed");
    #endif
}

//////////////////////////
// Show/hide helmets as appropriate on leaving a GUI screen
//
void NoHelmetLeaveGUI() {
    PrintToLog("---> NoHelmetLeaveGUI");
    // Test if helmets have been swapped
    if (WR_GetPlotFlag( PLT_AF_NOHELMET, HELMET_SLOT_ACTIVE ) == TRUE )
    {
        // hide the helmets if plot flag allows it
        int i;
        object[] oParty;
        object oCloakHelm;
        object oMember;
        string oAreaStr = ObjectToString(GetArea(GetHero()));

        oParty = GetPartyList();
        int nSize = GetArraySize(oParty);
        // Whenever the party size is 1, get from party pool instead
        if (nSize==1)
        {
            oParty = GetPartyPoolList();
            nSize = GetArraySize(oParty);
        }

        int iAllowSwap = 0;
        string sUser;

        for (i = 0; i < nSize; i++)
        {
            oMember = oParty[i];
            oCloakHelm = GetItemInEquipSlot(5,oMember);
            iAllowSwap=0;
            sUser = GetName(oMember);

            // if there is a helmet in the helmet slot, move it to the cloak slot
            if (ObjectToString(oCloakHelm)!="-1")
            {
               // Allow swaps if character flags allow it
               if (IsHero(oMember))
                  {if (WR_GetPlotFlag(PLT_AF_NOHELMET,PLAYER_HELMET)==FALSE) iAllowSwap=1;}
               else if (sUser=="Alistair")
                  {if (WR_GetPlotFlag(PLT_AF_NOHELMET,ALISTAIR_HELMET)==FALSE) iAllowSwap=1;}
               else if (sUser=="Leliana")
                  {if (WR_GetPlotFlag(PLT_AF_NOHELMET,LELIANA_HELMET)==FALSE) iAllowSwap=1;}
               else if (sUser=="Loghain")
                  {if (WR_GetPlotFlag(PLT_AF_NOHELMET,LOGHAIN_HELMET)==FALSE) iAllowSwap=1;}
               else if (sUser=="Morrigan")
                  {if (WR_GetPlotFlag(PLT_AF_NOHELMET,MORRIGAN_HELMET)==FALSE) iAllowSwap=1;}
               else if (sUser=="Oghren")
                  {if (WR_GetPlotFlag(PLT_AF_NOHELMET,OGHREN_HELMET)==FALSE) iAllowSwap=1;}
               else if (sUser=="Sten")
                  {if (WR_GetPlotFlag(PLT_AF_NOHELMET,STEN_HELMET)==FALSE) iAllowSwap=1;}
               else if (sUser=="Wynne")
                  {if (WR_GetPlotFlag(PLT_AF_NOHELMET,WYNNE_HELMET)==FALSE) iAllowSwap=1;}
               else if (sUser=="Zevran")
                  {if (WR_GetPlotFlag(PLT_AF_NOHELMET,ZEVRAN_HELMET)==FALSE) iAllowSwap=1;}
               else if (sUser=="Anders")
                  {if (WR_GetPlotFlag(PLT_AF_NOHELMET,ANDERS_HELMET)==FALSE) iAllowSwap=1;}
               else if (sUser=="Velanna")
                  {if (WR_GetPlotFlag(PLT_AF_NOHELMET,VELANNA_HELMET)==FALSE) iAllowSwap=1;}
               else if (sUser=="Sigrun")
                  {if (WR_GetPlotFlag(PLT_AF_NOHELMET,SIGRUN_HELMET)==FALSE) iAllowSwap=1;}
               else if (sUser=="Mhairi")
                  {if (WR_GetPlotFlag(PLT_AF_NOHELMET,MHAIRI_HELMET)==FALSE) iAllowSwap=1;}
               else if (sUser=="Nathaniel")
                  {if (WR_GetPlotFlag(PLT_AF_NOHELMET,NATHANIEL_HELMET)==FALSE) iAllowSwap=1;}
                else if (sUser=="Justice")
                  {if (WR_GetPlotFlag(PLT_AF_NOHELMET,JUSTICE_HELMET)==FALSE) iAllowSwap=1;}
              // Name is not one of above, so catch all unknown
               else {if (WR_GetPlotFlag(PLT_AF_NOHELMET,UNKNOWN_HELMET)==FALSE) iAllowSwap=1;}

                if (iAllowSwap==1)
                {
                    // Try to kick out any helm in the helm slot
                    UnequipItem(oMember,oCloakHelm);
                    EquipItem(oMember,oCloakHelm,8);
                    // Module check to see if the item actually went into the cloak slot
                    object oCheckCloak = GetItemInEquipSlot(8,oMember);
                    if (ObjectToString(oCheckCloak)=="-1")
                    {
                        // An error occured, the cloak slot is unusable
                        ShowPopup(AF_POPUP_STREF_NOHELMET,3);
                        // Put the helmet back on so as not to freak put the user
                        EquipItem(oMember,oCloakHelm,5);
                    }
                    else
                    {
                        // Item has been placed in the cloak slot, now run the custom item set handler
                        NoHelmetItemSetUpdate(oMember);
                    }
                }
            }
        }
        WR_SetPlotFlag( PLT_AF_NOHELMET, HELMET_SLOT_ACTIVE, FALSE );
    }
}
