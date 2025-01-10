// ---- SCRIPT STARTS HERE ----

// Later on in this script, we will use the UT_AddItemToInventory()
// function to add an item to the player's inventory.
// But before we could use it, we have to tell the toolset where
// to look for it. The function is in the "utility_h" script file
// under _Core Includes, we will include this file at the top of
// our script file, above the main function.

#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "plt_no_helmet_plot"
#include "no_helmet_item_set_handler"

void main()
{
    // If our plot flag is set to TRUE, that means we have already
    // given the items to the player, there is no need to continue
    // running this script.
//    if ( WR_GetPlotFlag( PLT_NO_HELMET_PLOT, NO_HELMET_ADDED_FLAG ) == TRUE )
//        return;

    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

//    DisplayStatusMessage("Module Event Called",16777215);


    // We will watch for every event type and if the one we need
    // appears we will handle it as a special case. We will ignore the rest
    // of the events
    switch ( nEventType )
    {
        // This event happenes every time the module loads
        // This usually happenes when creating a new game
        // or loading a savegame
        case EVENT_TYPE_MODULE_LOAD:
        {
            // The UT_AddItemToInventory function adds various resources to a
            // creature's inventory. Here we add one weapon and one shield.

            // Using continuous scan to see if object needs loading this time
            object oBook = GetObjectByTag("no_helmet_book");
            if (!IsObjectValid(oBook))
                UT_AddItemToInventory(R"no_helmet_book.uti",1);
            // backup check and add
            int iCount = CountItemsByTag(GetHero(),"no_helmet_book");
            if (iCount<1)
                UT_AddItemToInventory(R"no_helmet_book.uti",1);

            // Set our plot flag to TRUE, so the next time this script tries
            // to run it will not add extra items to the player's inventory
//            WR_SetPlotFlag( PLT_NO_HELMET_PLOT, NO_HELMET_ADDED_FLAG, TRUE );

            // We have dealt with the event we were waiting for.
            // At this point we can stop looking for other events
            break;
        }
        case EVENT_TYPE_GUI_OPENED:
        {

             int nGUIID = GetEventInteger(ev, 0); // ID number of the GUI that was opened
             // Insert event-handling code here.
             if (nGUIID == GUI_INVENTORY)
             {
                if (WR_GetPlotFlag( PLT_NO_HELMET_PLOT, HELMET_SLOT_ACTIVE ) == FALSE )
                {
                    // Swap helmets to make visible
                    int i;
                    object[] oParty;
                    object oCloakHelm;
                    object oMember;
                    string oAreaStr = ObjectToString(GetArea(GetHero()));

   //                 if (oAreaStr=="14901")
   //                 {
                        // Party Camp
   //                     oParty = GetPartyPoolList();
   //                 }
   //                 else
   //                {
   //                     oParty = GetPartyList();
   //                 }

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
                    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, HELMET_SLOT_ACTIVE, TRUE );
                }
             }
             break;
        }
        case EVENT_TYPE_GAMEMODE_CHANGE:
        {

            int nNewGameMode = GetEventInteger(ev, 0); // New Game Mode (GM_* constant)
            int nOldGameMode = GetEventInteger(ev, 1); // Old Game Mode (GM_* constant)
            // Insert event-handling code here.
//            DisplayStatusMessage( "New Gamemode: "+IntToString(nNewGameMode) );

            // Test gamemodes COMBAT && EXPLORE
//            if ((nNewGameMode == GM_COMBAT) || (nNewGameMode == GM_COMBAT))
            // Test when exiting any GUI
            if (nOldGameMode == GM_GUI)
//            {
                // Test if helmets have been swapped
//            }
//            else
            {
                // Test if helmets have been swapped
                if (WR_GetPlotFlag( PLT_NO_HELMET_PLOT, HELMET_SLOT_ACTIVE ) == TRUE )
                {
                    // hide the helmets if plot flag allows it
                    int i;
                    object[] oParty;
                    object oCloakHelm;
                    object oMember;
                    string oAreaStr = ObjectToString(GetArea(GetHero()));

//                    DisplayStatusMessage( "Area: "+oAreaStr);

//                    if (oAreaStr=="14901")
//                    {
//                        oParty = GetPartyPoolList();
//                    }
//                    else
//                    {
//                        oParty = GetPartyList();
//                    }
//                    int nSize = GetArraySize(oParty);
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
                              {if (WR_GetPlotFlag(PLT_NO_HELMET_PLOT,PLAYER_HELMET)==FALSE) iAllowSwap=1;}
                           else if (sUser=="Alistair")
                              {if (WR_GetPlotFlag(PLT_NO_HELMET_PLOT,ALISTAIR_HELMET)==FALSE) iAllowSwap=1;}
                           else if (sUser=="Leliana")
                              {if (WR_GetPlotFlag(PLT_NO_HELMET_PLOT,LELIANA_HELMET)==FALSE) iAllowSwap=1;}
                           else if (sUser=="Loghain")
                              {if (WR_GetPlotFlag(PLT_NO_HELMET_PLOT,LOGHAIN_HELMET)==FALSE) iAllowSwap=1;}
                           else if (sUser=="Morrigan")
                              {if (WR_GetPlotFlag(PLT_NO_HELMET_PLOT,MORRIGAN_HELMET)==FALSE) iAllowSwap=1;}
                           else if (sUser=="Oghren")
                              {if (WR_GetPlotFlag(PLT_NO_HELMET_PLOT,OGHREN_HELMET)==FALSE) iAllowSwap=1;}
                           else if (sUser=="Sten")
                              {if (WR_GetPlotFlag(PLT_NO_HELMET_PLOT,STEN_HELMET)==FALSE) iAllowSwap=1;}
                           else if (sUser=="Wynne")
                              {if (WR_GetPlotFlag(PLT_NO_HELMET_PLOT,WYNNE_HELMET)==FALSE) iAllowSwap=1;}
                           else if (sUser=="Zevran")
                              {if (WR_GetPlotFlag(PLT_NO_HELMET_PLOT,ZEVRAN_HELMET)==FALSE) iAllowSwap=1;}
                           else if (sUser=="Anders")
                              {if (WR_GetPlotFlag(PLT_NO_HELMET_PLOT,ANDERS_HELMET)==FALSE) iAllowSwap=1;}
                           else if (sUser=="Velanna")
                              {if (WR_GetPlotFlag(PLT_NO_HELMET_PLOT,VELANNA_HELMET)==FALSE) iAllowSwap=1;}
                           else if (sUser=="Sigrun")
                              {if (WR_GetPlotFlag(PLT_NO_HELMET_PLOT,SIGRUN_HELMET)==FALSE) iAllowSwap=1;}
                           else if (sUser=="Mhairi")
                              {if (WR_GetPlotFlag(PLT_NO_HELMET_PLOT,MHAIRI_HELMET)==FALSE) iAllowSwap=1;}
                           else if (sUser=="Nathaniel")
                              {if (WR_GetPlotFlag(PLT_NO_HELMET_PLOT,NATHANIEL_HELMET)==FALSE) iAllowSwap=1;}
                            else if (sUser=="Justice")
                              {if (WR_GetPlotFlag(PLT_NO_HELMET_PLOT,JUSTICE_HELMET)==FALSE) iAllowSwap=1;}
                          // Name is not one of above, so catch all unknown
                           else {if (WR_GetPlotFlag(PLT_NO_HELMET_PLOT,UNKNOWN_HELMET)==FALSE) iAllowSwap=1;}

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
                                    ShowPopup(1152473465,3);
                                    // Put the helmet back on so as not to freak put the user
                                    EquipItem(oMember,oCloakHelm,5);
                                }
                                else
                                {
                                    // Item has been placed in the cloak slot, now run the custom item set handler
                                    ItemSet_Update_No_Helmet(oMember);
                                }
                            }
                        }
                    }
                    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, HELMET_SLOT_ACTIVE, FALSE );
                }
            }
            break;
        }
        default:
            break;
    }
//    HandleEvent(ev);

}
// ---- SCRIPT ENDS HERE ----