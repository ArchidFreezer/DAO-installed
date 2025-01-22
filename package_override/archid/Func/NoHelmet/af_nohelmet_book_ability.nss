#include "utility_h"
#include "events_h"
#include "wrappers_h"
#include "af_nohelmet_h"
#include "plt_af_nohelmet"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    switch(nEventType) {
        // ---------------------------------------------------------------------
        // EVENT_TYPE_ABILITY_CAST_CAST
        // ---------------------------------------------------------------------
        // Fires for the moment of impact for every ability. This is where damage
        // should be applied, fireballs explode, enemies get poisoned etc'.
        // ---------------------------------------------------------------------
        case EVENT_TYPE_SPELLSCRIPT_CAST: {
            // Retrieve the character who used the item
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);
            object oUser = stEvent.oCaster;

            string sUser = GetName(oUser);
            int iUniqueAction = 0;

            // Make sure using the potion or book
            // Cycle through all posible users
            if (IsHero(oUser)) {
                if (WR_GetPlotFlag( PLT_AF_NOHELMET, PLAYER_HELMET)) {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, PLAYER_HELMET,FALSE );
                    iUniqueAction=1;
                } else {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, PLAYER_HELMET,TRUE );
                    iUniqueAction=2;
                }
            } else if (sUser=="Alistair") {      
                if (WR_GetPlotFlag( PLT_AF_NOHELMET, ALISTAIR_HELMET)) {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, ALISTAIR_HELMET,FALSE );
                    iUniqueAction=1;
                } else {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, ALISTAIR_HELMET,TRUE );
                    iUniqueAction=2;
                }
            } else if (sUser=="Leliana") {
                if (WR_GetPlotFlag( PLT_AF_NOHELMET, LELIANA_HELMET)) {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, LELIANA_HELMET,FALSE );
                    iUniqueAction=1;
                } else {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, LELIANA_HELMET,TRUE );
                    iUniqueAction=2;
                }
            } else if (sUser=="Loghain") {
                if (WR_GetPlotFlag( PLT_AF_NOHELMET, LOGHAIN_HELMET)) {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, LOGHAIN_HELMET,FALSE );
                    iUniqueAction=1;
                } else {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, LOGHAIN_HELMET,TRUE );
                    iUniqueAction=2;
                }
            } else if (sUser=="Morrigan") {
                if (WR_GetPlotFlag( PLT_AF_NOHELMET, MORRIGAN_HELMET)) {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, MORRIGAN_HELMET,FALSE );
                    iUniqueAction=1;
                } else {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, MORRIGAN_HELMET,TRUE );
                    iUniqueAction=2;
                }
            } else if (sUser=="Oghren") {
                if (WR_GetPlotFlag( PLT_AF_NOHELMET, OGHREN_HELMET)) {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, OGHREN_HELMET,FALSE );
                    iUniqueAction=1;
                } else {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, OGHREN_HELMET,TRUE );
                    iUniqueAction=2;
                }
            } else if (sUser=="Sten") {
                if (WR_GetPlotFlag( PLT_AF_NOHELMET, STEN_HELMET)) {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, STEN_HELMET,FALSE );
                    iUniqueAction=1;
                } else {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, STEN_HELMET,TRUE );
                    iUniqueAction=2;
                }
            } else if (sUser=="Wynne") {
                if (WR_GetPlotFlag( PLT_AF_NOHELMET, WYNNE_HELMET)) {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, WYNNE_HELMET,FALSE );
                    iUniqueAction=1;
                } else{
                    WR_SetPlotFlag( PLT_AF_NOHELMET, WYNNE_HELMET,TRUE );
                    iUniqueAction=2;
                }
            } else if (sUser=="Zevran") {
                if (WR_GetPlotFlag( PLT_AF_NOHELMET, ZEVRAN_HELMET)) {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, ZEVRAN_HELMET,FALSE );
                    iUniqueAction=1;
                } else {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, ZEVRAN_HELMET,TRUE );
                    iUniqueAction=2;
                }
            } else if (sUser=="Anders") {
                if (WR_GetPlotFlag( PLT_AF_NOHELMET, ANDERS_HELMET)) {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, ANDERS_HELMET,FALSE );
                    iUniqueAction=1;
                } else {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, ANDERS_HELMET,TRUE );
                    iUniqueAction=2;
                }
            } else if (sUser=="Velanna") {
                if (WR_GetPlotFlag( PLT_AF_NOHELMET, VELANNA_HELMET)) {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, VELANNA_HELMET,FALSE );
                    iUniqueAction=1;
                } else {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, VELANNA_HELMET,TRUE );
                    iUniqueAction=2;
                }
            } else if (sUser=="Sigrun") {
                if (WR_GetPlotFlag( PLT_AF_NOHELMET, SIGRUN_HELMET)) {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, SIGRUN_HELMET,FALSE );
                    iUniqueAction=1;
                } else {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, SIGRUN_HELMET,TRUE );
                    iUniqueAction=2;
                }
            } else if (sUser=="Mhairi") {
                if (WR_GetPlotFlag( PLT_AF_NOHELMET, MHAIRI_HELMET)) {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, MHAIRI_HELMET,FALSE );
                    iUniqueAction=1;
                } else {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, MHAIRI_HELMET,TRUE );
                    iUniqueAction=2;
                }
            } else if (sUser=="Nathaniel") {
                if (WR_GetPlotFlag( PLT_AF_NOHELMET, NATHANIEL_HELMET)) {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, NATHANIEL_HELMET,FALSE );
                    iUniqueAction=1;
                } else{
                    WR_SetPlotFlag( PLT_AF_NOHELMET, NATHANIEL_HELMET,TRUE );
                    iUniqueAction=2;
                }
            } else if (sUser=="Justice") {
                if (WR_GetPlotFlag( PLT_AF_NOHELMET, JUSTICE_HELMET)) {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, JUSTICE_HELMET,FALSE );
                    iUniqueAction=1;
                } else {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, JUSTICE_HELMET,TRUE );
                    iUniqueAction=2;
                }
            } else { // Catch all other followers
                if (WR_GetPlotFlag( PLT_AF_NOHELMET, UNKNOWN_HELMET)) {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, UNKNOWN_HELMET,FALSE );
                    iUniqueAction=1;
                } else {
                    WR_SetPlotFlag( PLT_AF_NOHELMET, UNKNOWN_HELMET,TRUE );
                    iUniqueAction=2;
                }
                sUser = "Unregistered Followers";
            }

            // Do the actions based on the flags
            // 1 is hide the helmet
            if (iUniqueAction == 1) {
                DisplayFloatyMessage(oUser,"Hiding Helmets on "+sUser,FLOATY_MESSAGE,0xffffff,5.0);
                object oCloakHelm = GetItemInEquipSlot(5,oUser);
                if (ObjectToString(oCloakHelm)!="-1") {
                    // Try to kick out any helm in the cloak slot
                    UnequipItem(oUser,oCloakHelm);
                    EquipItem(oUser,oCloakHelm,8);
                    NoHelmetItemSetUpdate(oUser);
                }
            } else if (iUniqueAction == 2) {
                DisplayFloatyMessage(oUser,"Showing Helmets on "+sUser,FLOATY_MESSAGE,0xffffff,5.0);
                object oCloakHelm = GetItemInEquipSlot(8,oUser);
                if (ObjectToString(oCloakHelm)!="-1") {
                    // Try to kick out any helm in the helm slot
                    UnequipItem(oUser,oCloakHelm);
                    EquipItem(oUser,oCloakHelm,5);
                }
            }
            
            UT_RemoveItemFromInventory(AF_ITR_MISC_BOOK_NOHELMET, 1, GetHero());
            UT_AddItemToInventory(AF_ITR_MISC_BOOK_NOHELMET, 1);

            break;
        } // ! EVENT_TYPE_SPELLSCRIPT_CAST

    } // ! switch

} // ! main