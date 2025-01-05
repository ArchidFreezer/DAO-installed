#include "utility_h"
#include "events_h"
#include "wrappers_h"              
#include "no_helmet_item_set_handler"
#include "plt_no_helmet_plot"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    switch(nEventType)
    {
        // ---------------------------------------------------------------------
        // EVENT_TYPE_ABILITY_CAST_CAST
        // ---------------------------------------------------------------------
        // Fires for the moment of impact for every ability. This is where damage
        // should be applied, fireballs explode, enemies get poisoned etc'.
        // ---------------------------------------------------------------------
        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {
            // Retrieve the character who used the item
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);
            object oUser = stEvent.oCaster;

            string sUser = GetName(oUser);
            int iUniqueAction = 0;

            // Make sure using the potion or book
                    // Cycle through all posible users
                   if (IsHero(oUser))
                   {  if (WR_GetPlotFlag( PLT_NO_HELMET_PLOT, PLAYER_HELMET) == TRUE )
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, PLAYER_HELMET,FALSE );
                         iUniqueAction=1;
                    }    else
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, PLAYER_HELMET,TRUE );
                         iUniqueAction=2;
                    }
                   }
                   else
                   if (sUser=="Alistair")
                   {  if (WR_GetPlotFlag( PLT_NO_HELMET_PLOT, ALISTAIR_HELMET) == TRUE )
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, ALISTAIR_HELMET,FALSE );
                         iUniqueAction=1;
                    }    else
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, ALISTAIR_HELMET,TRUE );
                         iUniqueAction=2;
                    }
                   }
                   else
                   if (sUser=="Leliana")
                   {  if (WR_GetPlotFlag( PLT_NO_HELMET_PLOT, LELIANA_HELMET) == TRUE )
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, LELIANA_HELMET,FALSE );
                         iUniqueAction=1;
                    }    else
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, LELIANA_HELMET,TRUE );
                         iUniqueAction=2;
                    }
                   }
                   else
                   if (sUser=="Loghain")
                   {  if (WR_GetPlotFlag( PLT_NO_HELMET_PLOT, LOGHAIN_HELMET) == TRUE )
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, LOGHAIN_HELMET,FALSE );
                         iUniqueAction=1;
                    }    else
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, LOGHAIN_HELMET,TRUE );
                         iUniqueAction=2;
                    }
                   }
                   else
                   if (sUser=="Morrigan")
                   {  if (WR_GetPlotFlag( PLT_NO_HELMET_PLOT, MORRIGAN_HELMET) == TRUE )
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, MORRIGAN_HELMET,FALSE );
                         iUniqueAction=1;
                    }    else
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, MORRIGAN_HELMET,TRUE );
                         iUniqueAction=2;
                    }
                   }
                   else
                   if (sUser=="Oghren")
                   {  if (WR_GetPlotFlag( PLT_NO_HELMET_PLOT, OGHREN_HELMET) == TRUE )
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, OGHREN_HELMET,FALSE );
                         iUniqueAction=1;
                    }    else
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, OGHREN_HELMET,TRUE );
                         iUniqueAction=2;
                    }
                   }
                   else
                   if (sUser=="Sten")
                   {  if (WR_GetPlotFlag( PLT_NO_HELMET_PLOT, STEN_HELMET) == TRUE )
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, STEN_HELMET,FALSE );
                         iUniqueAction=1;
                    }    else
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, STEN_HELMET,TRUE );
                         iUniqueAction=2;
                    }
                   }
                   else
                   if (sUser=="Wynne")
                   {  if (WR_GetPlotFlag( PLT_NO_HELMET_PLOT, WYNNE_HELMET) == TRUE )
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, WYNNE_HELMET,FALSE );
                         iUniqueAction=1;
                    }    else
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, WYNNE_HELMET,TRUE );
                         iUniqueAction=2;
                    }
                   }
                   else
                   if (sUser=="Zevran")
                   {  if (WR_GetPlotFlag( PLT_NO_HELMET_PLOT, ZEVRAN_HELMET) == TRUE )
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, ZEVRAN_HELMET,FALSE );
                         iUniqueAction=1;
                    }    else
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, ZEVRAN_HELMET,TRUE );
                         iUniqueAction=2;
                    }
                   }
                   else
                   if (sUser=="Anders")
                   {  if (WR_GetPlotFlag( PLT_NO_HELMET_PLOT, ANDERS_HELMET) == TRUE )
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, ANDERS_HELMET,FALSE );
                         iUniqueAction=1;
                    }    else
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, ANDERS_HELMET,TRUE );
                         iUniqueAction=2;
                    }
                   }
                   else
                   if (sUser=="Velanna")
                   {  if (WR_GetPlotFlag( PLT_NO_HELMET_PLOT, VELANNA_HELMET) == TRUE )
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, VELANNA_HELMET,FALSE );
                         iUniqueAction=1;
                    }    else
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, VELANNA_HELMET,TRUE );
                         iUniqueAction=2;
                    }
                   }
                   else
                   if (sUser=="Sigrun")
                   {  if (WR_GetPlotFlag( PLT_NO_HELMET_PLOT, SIGRUN_HELMET) == TRUE )
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, SIGRUN_HELMET,FALSE );
                         iUniqueAction=1;
                    }    else
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, SIGRUN_HELMET,TRUE );
                         iUniqueAction=2;
                    }
                   }
                   else
                   if (sUser=="Mhairi")
                   {  if (WR_GetPlotFlag( PLT_NO_HELMET_PLOT, MHAIRI_HELMET) == TRUE )
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, MHAIRI_HELMET,FALSE );
                         iUniqueAction=1;
                    }    else
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, MHAIRI_HELMET,TRUE );
                         iUniqueAction=2;
                    }
                   }
                   else
                   if (sUser=="Nathaniel")
                   {  if (WR_GetPlotFlag( PLT_NO_HELMET_PLOT, NATHANIEL_HELMET) == TRUE )
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, NATHANIEL_HELMET,FALSE );
                         iUniqueAction=1;
                    }    else
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, NATHANIEL_HELMET,TRUE );
                         iUniqueAction=2;
                    }
                   }
                   else
                   if (sUser=="Justice")
                   {  if (WR_GetPlotFlag( PLT_NO_HELMET_PLOT, JUSTICE_HELMET) == TRUE )
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, JUSTICE_HELMET,FALSE );
                         iUniqueAction=1;
                    }    else
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, JUSTICE_HELMET,TRUE );
                         iUniqueAction=2;
                    }
                   }
                   else
                   // Catchs all other followers
                   {  if (WR_GetPlotFlag( PLT_NO_HELMET_PLOT, UNKNOWN_HELMET) == TRUE )
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, UNKNOWN_HELMET,FALSE );
                         iUniqueAction=1;
                    }    else
                    {    WR_SetPlotFlag( PLT_NO_HELMET_PLOT, UNKNOWN_HELMET,TRUE );
                         iUniqueAction=2;
                    }
                      sUser = "Unregistered Followers";
                   }
                   // Do the actions based on the flags
                   // 1 is hide the helmet
                   if (iUniqueAction==1)
                   {
                       DisplayFloatyMessage(oUser,"Hiding Helmets on "+sUser,FLOATY_MESSAGE,0xffffff,5.0);
                       object oCloakHelm = GetItemInEquipSlot(5,oUser);
                       if (ObjectToString(oCloakHelm)!="-1")
                        {
                            // Try to kick out any helm in the cloak slot
                            UnequipItem(oUser,oCloakHelm);
                            EquipItem(oUser,oCloakHelm,8); 
                            ItemSet_Update_No_Helmet(oUser);
                        }
                   }
                   else if (iUniqueAction==2)
                   {
                       DisplayFloatyMessage(oUser,"Showing Helmets on "+sUser,FLOATY_MESSAGE,0xffffff,5.0);
                       object oCloakHelm = GetItemInEquipSlot(8,oUser);
                       if (ObjectToString(oCloakHelm)!="-1")
                        {
                            // Try to kick out any helm in the helm slot
                            UnequipItem(oUser,oCloakHelm);
                            EquipItem(oUser,oCloakHelm,5);
                        }
                   }

            UT_RemoveItemFromInventory(R"no_helmet_book.uti", 1, GetHero());
            UT_AddItemToInventory(R"no_helmet_book.uti", 1);

            break;
        } // ! EVENT_TYPE_SPELLSCRIPT_CAST

    } // ! switch

} // ! main