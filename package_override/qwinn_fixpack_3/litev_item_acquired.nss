//==============================================================================
/*

    Item Acquired Event Script
     -> Light Content anywhere in the game

*/
//------------------------------------------------------------------------------
// Created By:  Keith W
// Created On: July 30, 2008
//==============================================================================

#include "utility_h"
#include "events_h"
#include "lit_constants_h"
#include "campaign_h"
#include "sys_injury"

#include "plt_cod_lite_multi_gax"
#include "plt_lite_multi_gax"
#include "plt_lite_fite_deserters"
#include "plt_cod_lite_tow_banastor"
#include "plt_cod_lite_rogue_letters"
#include "plt_lite_mage_banastor"
#include "plt_lite_rogue_terms"
#include "plt_cod_lite_rogue_note"
#include "plt_lite_rogue_letters"
#include "plt_cod_lite_tow_renold"
#include "plt_lite_mage_renold"
#include "plt_cod_lite_kor_jogby"
#include "plt_cod_lite_kor_jogby2"
#include "plt_lite_kor_jogby"
#include "plt_lite_kor_lastwill"
#include "plt_cod_lite_kor_lastwill"
#include "plt_cod_lite_kor_trailsigns"
#include "plt_cod_lite_kor_ash"
#include "plt_lite_kor_ash"
#include "plt_cod_lite_carta_stash"
#include "plt_lite_carta_stash"
#include "plt_lite_rogue_decisions"
#include "plt_lite_rogue_new_ground"

void CartaTrapTriggered(object oAcquirer);

void main()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evEvent     = GetCurrentEvent();
    int     nEventType  = GetEventType(evEvent);

    // Grab Player, set default event handled to false
    object  oPC           = GetHero();
    int     bEventHandled = FALSE;

    Log_Events(GetCurrentScriptName(),evEvent);

    //--------------------------------------------------------------------------

    switch(nEventType)
    {
        case EVENT_TYPE_CAMPAIGN_ITEM_ACQUIRED:
        {
            //------------------------------------------------------------------
            // EVENT_TYPE_CAMPAIGN_ITEM_ACQUIRED
            //------------------------------------------------------------------
            // Sent by: Scripting
            // When:    Item is added to inventory that has
            //          ITEM_SEND_ACQUIRED_EVENT set to TRUE
            //------------------------------------------------------------------

            string      sItemTag;
            object      oItem;
            object      oAcquirer;

            //------------------------------------------------------------------

            oAcquirer = GetEventCreator(evEvent);
            oItem     = GetEventObject(evEvent, 0);
            sItemTag  = GetTag(oItem);
            //------------------------------------------------------------------


            //Unbound Adventurer's journal
            if (sItemTag == LITE_IM_UNBOUND_JOURNAL)
            {
                WR_SetPlotFlag(PLT_COD_LITE_MULTI_GAX, MULTI_GAX_ONE, TRUE, TRUE);
                RemoveItemsByTag(oPC, LITE_IM_UNBOUND_JOURNAL);
                //if all codexes found - activate journal
                if (WR_GetPlotFlag(PLT_COD_LITE_MULTI_GAX, MULTI_GAX_TWO) == TRUE && WR_GetPlotFlag(PLT_COD_LITE_MULTI_GAX, MULTI_GAX_THREE) == TRUE)
                {
                    WR_SetPlotFlag(PLT_LITE_MULTI_GAX, MULTI_GAX_MAIN, TRUE, TRUE);
                    //the alley becomes visible when in the city
                    object oTarg = GetObjectByTag(WML_LC_DEN_ALLEY_2);
                    WR_SetWorldMapLocationStatus(oTarg, WM_LOCATION_ACTIVE);
                }
            }
            //Unbound Adventurer's letter
            else if (sItemTag == LITE_IM_UNBOUND_LETTER)
            {
                WR_SetPlotFlag(PLT_COD_LITE_MULTI_GAX, MULTI_GAX_TWO, TRUE, TRUE);
                RemoveItemsByTag(oPC, LITE_IM_UNBOUND_LETTER);
                //if all codexes found - activate journal
                if (WR_GetPlotFlag(PLT_COD_LITE_MULTI_GAX, MULTI_GAX_ONE) == TRUE && WR_GetPlotFlag(PLT_COD_LITE_MULTI_GAX, MULTI_GAX_THREE) == TRUE)
                {
                    WR_SetPlotFlag(PLT_LITE_MULTI_GAX, MULTI_GAX_MAIN, TRUE, TRUE);
                    //the alley becomes visible when in the city
                    object oTarg = GetObjectByTag(WML_LC_DEN_ALLEY_2);
                    WR_SetWorldMapLocationStatus(oTarg, WM_LOCATION_ACTIVE);
                }
            }
            //fite_deserters_supplies
            else if (sItemTag == LITE_IM_DESERTERS_SUPPLIES)
            {
                //set the next deserter variable - if all are done - mark plot done
                if (WR_GetPlotFlag(PLT_LITE_FITE_DESERTERS, DESERTERS_KILLED_ONE) == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_FITE_DESERTERS, DESERTERS_KILLED_ONE, TRUE, TRUE);
                }
                else if (WR_GetPlotFlag(PLT_LITE_FITE_DESERTERS, DESERTERS_KILLED_TWO) == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_FITE_DESERTERS, DESERTERS_KILLED_TWO, TRUE, TRUE);
                }
                else if (WR_GetPlotFlag(PLT_LITE_FITE_DESERTERS, DESERTERS_KILLED_THREE) == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_FITE_DESERTERS, DESERTERS_KILLED_THREE, TRUE, TRUE);
                    WR_SetPlotFlag(PLT_LITE_FITE_DESERTERS, DESERTERS_FOUND, TRUE, TRUE);
                }
                break;
            }
            //Mage - Banastor scroll
            else if (sItemTag == LITE_IM_MAGE_BANASTOR)
            {
                object [] arrScrollCount = GetItemsInInventory(oPC, GET_ITEMS_OPTION_ALL, 0, LITE_IM_MAGE_BANASTOR);
                if (IsObjectValid(arrScrollCount[0]) == TRUE)
                {
                    //if the stack is valid - set the correct codex entry
                    int nScrollCount = GetItemStackSize(arrScrollCount[0]);
                    if (nScrollCount == 1)
                    {
                        WR_SetPlotFlag(PLT_COD_LITE_TOW_BANASTOR, TOW_BANASTOR_1, TRUE, TRUE);
                    }
                    else if (nScrollCount == 2)
                    {
                        WR_SetPlotFlag(PLT_COD_LITE_TOW_BANASTOR, TOW_BANASTOR_2, TRUE, TRUE);
                    }
                    else if (nScrollCount == 3)
                    {
                        WR_SetPlotFlag(PLT_COD_LITE_TOW_BANASTOR, TOW_BANASTOR_3, TRUE, TRUE);
                    }
                    else if (nScrollCount == 4)
                    {
                        WR_SetPlotFlag(PLT_COD_LITE_TOW_BANASTOR, TOW_BANASTOR_4, TRUE, TRUE);
                    }
                    else if (nScrollCount == 5)
                    {
                        WR_SetPlotFlag(PLT_COD_LITE_TOW_BANASTOR, TOW_BANASTOR_5, TRUE, TRUE);
                        //set that the plot is done (if it has been started) //other wise it gets marked when the quest is taken
                        if (WR_GetPlotFlag(PLT_LITE_MAGE_BANASTOR, BANASTOR_QUEST_GIVEN) == TRUE)
                        {
                            WR_SetPlotFlag(PLT_LITE_MAGE_BANASTOR, BANASTOR_SCROLLS_FOUND, TRUE, TRUE);

                        }
                    }
                }
            }

            // Light Content: Box of Certain Interests (lite_rogue_letters)
            else if (sItemTag == LITE_IM_ROGUE_LETTER )
            {
                // give the generic codex entry for the love letters bundle
                if (!WR_GetPlotFlag(PLT_COD_LITE_ROGUE_LETTERS,ROGUE_LETTERS_ZERO))
                    WR_SetPlotFlag(PLT_COD_LITE_ROGUE_LETTERS,ROGUE_LETTERS_ZERO,TRUE,TRUE);
                /*
                LOVE LETTER LOCATIONS
                1)  arl210ar_castle_dungeon (inside arl210ip_basement_chest [-16.9337,4.50931,0.1])
                2)  orz230ar_gangsters_hideout (inside liteip_rogue_letterchest [194.49,-111.963,3])
                3)  cir210ar_tower_level_2 (inside liteip_rogue_letterchest [44.4457,8.43738,-0.0084954])
                4)  ntb310ar_top_level (inside liteip_rogue_letterchest [-40.9287,-11.8586,4.55644])
                5)  urn120ar_village_house (inside liteip_rogue_letterchest [-9.6052,-23.0957,0.0161686])
                6)  ntb100ar_dalish_camp (inside liteip_rogue_letterchest [258.836,262.662,5.57407])
                7)  den211ar_arl_eamon_estate_1 (inside liteip_rogue_letterchest [99.2274,-14.4633,5.02284])
                8)  arl190ar_windmill (inside liteip_rogue_lettercrate [9.90993,-4.47868,0.158443])
                9)  cir110ar_inn (inside liteip_rogue_letterchest [-5.3188,9.37734,0.0161686])
                10) orz320ar_royal_palace (inside liteip_rogue_letterchest [1.527,-7.23189,0.949137])
                11) den280ar_smithy (inside liteip_rogue_letterchest [])
                12) den100ar_brothel (inside liteip_rogue_letterchest [-25.2389,-14.3158,0.0402046])
                */
                // Activate proper codex based on the love letter
                int nLoveLetterId = GetLocalInt(oItem,ITEM_COUNTER_1);
                WR_SetPlotFlag(PLT_COD_LITE_ROGUE_LETTERS,nLoveLetterId,TRUE);
                // remove this numbered letter and add a generic one.
                RemoveItem(oItem);
                UT_AddItemToInventory(rLITE_IM_ROGUE_LETTER);
                // check if we have enough letters to finish the plot
                if (UT_CountItemInInventory(rLITE_IM_ROGUE_LETTER) >= LITE_ROGUE_LETTERS_REQ &&
                    WR_GetPlotFlag(PLT_LITE_ROGUE_LETTERS,LETTERS_PLOT_ACCEPTED))
                {
                    WR_SetPlotFlag(PLT_LITE_ROGUE_LETTERS,LETTERS_PLOT_COMPLETED,TRUE,TRUE);
                }
            }

            // Light Content: Box of Certain Interests (lite_rogue_terms)
            else if (sItemTag == LITE_IM_ROGUE_TERMS_NOTE)
            {
                WR_SetPlotFlag(PLT_COD_LITE_ROGUE_NOTE,ROGUE_NOTE_MAIN,TRUE);
                WR_SetPlotFlag(PLT_LITE_ROGUE_TERMS,TERMS_PLOT_COMPLETED,TRUE,TRUE);
                RemoveItemsByTag(oPC, LITE_IM_ROGUE_TERMS_NOTE);
            }

            //Light Content: lite_mage_renold
            else if (sItemTag == LITE_IM_MAGE_RENOLDJOURNAL)
            {
                //add the renold journal codex
                WR_SetPlotFlag(PLT_COD_LITE_TOW_RENOLD, RENOLD_COD_MAIN, TRUE, TRUE);
                RemoveItemsByTag(oPC, LITE_IM_MAGE_RENOLDJOURNAL);
                //mark renold plot done
                WR_SetPlotFlag(PLT_LITE_MAGE_RENOLD, RENOLD_NOTE_FOUND, TRUE, TRUE);
            }

            //Light Content - Korcari Wilds - Missionary
            else if (sItemTag == LITE_IM_KOR_MISS_LETTER)
            {
                //codex
                WR_SetPlotFlag(PLT_COD_LITE_KOR_JOGBY, JOGBY_MAIN, TRUE, TRUE);

                //if the player already had the 2nd part - no journal
                if (WR_GetPlotFlag(PLT_COD_LITE_KOR_JOGBY2, JOGBY2_MAIN) == FALSE)
                {
                    //journal
                    WR_SetPlotFlag(PLT_LITE_KOR_JOGBY, JOGBY_QUEST_GIVEN, TRUE, TRUE);
                }
                //remove the letter
                RemoveItemsByTag(oPC, LITE_IM_KOR_MISS_LETTER);
            }
            else if (sItemTag == LITE_IM_KOR_MISS_LETTER2)
            {
                //codex
                WR_SetPlotFlag(PLT_COD_LITE_KOR_JOGBY2, JOGBY2_MAIN, TRUE, TRUE);

                //if the player doesn't have the plot yet - no journal
                if (WR_GetPlotFlag(PLT_LITE_KOR_JOGBY, JOGBY_QUEST_GIVEN) == TRUE)
                {
                    //journal
                    WR_SetPlotFlag(PLT_LITE_KOR_JOGBY, JOGBY_QUEST_COMPLETE, TRUE, TRUE);
                }
                //remove the letter
                RemoveItemsByTag(oPC, LITE_IM_KOR_MISS_LETTER2);
            }

            //Light Content - Korcari Wilds - Last Will and Testament
            else if (sItemTag == LITE_IM_KOR_LASTWILL_WILL)
            {
                //Start journal
                WR_SetPlotFlag(PLT_LITE_KOR_LASTWILL, LASTWILL_GIVEN, TRUE, TRUE);

                //give codex
                WR_SetPlotFlag(PLT_COD_LITE_KOR_LASTWILL, LASTWILL_MAIN, TRUE, TRUE);

                //Activate the cache
                object oCache = UT_GetNearestObjectByTag(oPC, LITE_IP_LASTWILL_CACHE);
                SetObjectInteractive(oCache, TRUE);

            }

            //Light Content - Korcari Wilds - trail signs
            else if (sItemTag == LITE_IM_KOR_SIGNS_NOTE)
            {
                //activate the first trail sign
                object oSign = UT_GetNearestObjectByTag(oPC, LITE_IP_KOR_TRAILSIGN_1);
                SetObjectInteractive(oSign, TRUE);

                //activate the map note for sign 1
                object oPin = UT_GetNearestObjectByTag(oPC, LITE_WP_KOR_TRAILSIGN_1);
                SetMapPinState(oPin, TRUE);

                //give the codex
                WR_SetPlotFlag(PLT_COD_LITE_KOR_TRAILSIGNS, TRAILSIGNS_MAIN, TRUE, TRUE);

                //remove the field journal
                UT_RemoveItemFromInventory(rLITE_IM_KOR_SIGNS_NOTE);

            }

            //LIght Content - Korcari Wilds - Ashes
            else if (sItemTag == LITE_IM_KOR_ASHES_BOOK)
            {
                WR_SetPlotFlag(PLT_COD_LITE_KOR_ASH, ASH_MAIN, TRUE, TRUE);
                //remove the letter
                RemoveItemsByTag(oPC, LITE_IM_KOR_ASHES_BOOK);
            }
            else if (sItemTag == LITE_IM_KOR_ASH_POUCH)
            {
                WR_SetPlotFlag(PLT_LITE_KOR_ASH, ASHES_FOUND, TRUE, TRUE);

            }

            //Light Content - Carta stash (in orzammar's carta hq
            else if (sItemTag == LITE_IM_CARTA_OPEN_RED)
            {
                //failure - trigger trap
                WR_SetPlotFlag(PLT_LITE_CARTA_STASH, CARTA_STASH_TRIGGERED_A_TRAP, TRUE, TRUE);
                CartaTrapTriggered(oAcquirer);
                RemoveItemsByTag(oAcquirer, LITE_IM_CARTA_OPEN_RED);
            }
            else if (sItemTag == LITE_IM_CARTA_OPEN_STEEL)
            {
                //failure - trigger trap
                WR_SetPlotFlag(PLT_LITE_CARTA_STASH, CARTA_STASH_TRIGGERED_A_TRAP, TRUE, TRUE);
                CartaTrapTriggered(oAcquirer);
                RemoveItemsByTag(oAcquirer, LITE_IM_CARTA_OPEN_STEEL);
            }
            else if (sItemTag == LITE_IM_CARTA_OPEN_IRON)
            {
                //have the openner
                WR_SetPlotFlag(PLT_LITE_CARTA_STASH, CARTA_STASH_HAVE_OPENNER, TRUE, TRUE);
                //if you have all three items - you get the key
                if( WR_GetPlotFlag(PLT_LITE_CARTA_STASH, CARTA_STASH_HAVE_RING) == TRUE &&
                    WR_GetPlotFlag(PLT_LITE_CARTA_STASH, CARTA_STASH_HAVE_TRINKET) == TRUE)
                {
                    //remove the 3 pieces and give the key
                    UT_AddItemToInventory(rLITE_IM_CARTA_JAMMER_KEY);
                    UT_RemoveItemFromInventory(rLITE_IM_CARTA_OPEN_IRON);
                    UT_RemoveItemFromInventory(rLITE_IM_CARTA_RING_SILVER);
                    UT_RemoveItemFromInventory(rLITE_IM_CARTA_TRINKET_GAR);
                }
            }
            else if (sItemTag == LITE_IM_CARTA_RING_EMERALD)
            {
                //failure - trigger trap
                WR_SetPlotFlag(PLT_LITE_CARTA_STASH, CARTA_STASH_TRIGGERED_A_TRAP, TRUE, TRUE);
                CartaTrapTriggered(oAcquirer);
                RemoveItemsByTag(oAcquirer, LITE_IM_CARTA_RING_EMERALD);
            }
            else if (sItemTag == LITE_IM_CARTA_RING_GOLD)
            {
                //failure - trigger trap
                WR_SetPlotFlag(PLT_LITE_CARTA_STASH, CARTA_STASH_TRIGGERED_A_TRAP, TRUE, TRUE);
                CartaTrapTriggered(oAcquirer);
                RemoveItemsByTag(oAcquirer, LITE_IM_CARTA_RING_GOLD);
            }
            else if (sItemTag == LITE_IM_CARTA_RING_SILVER)
            {
                //have the ring
                WR_SetPlotFlag(PLT_LITE_CARTA_STASH, CARTA_STASH_HAVE_RING, TRUE, TRUE);
                //if you have all three items - you get the key
                if( WR_GetPlotFlag(PLT_LITE_CARTA_STASH, CARTA_STASH_HAVE_OPENNER) == TRUE &&
                    WR_GetPlotFlag(PLT_LITE_CARTA_STASH, CARTA_STASH_HAVE_TRINKET) == TRUE)
                {
                    //remove the 3 pieces and give the key
                    UT_AddItemToInventory(rLITE_IM_CARTA_JAMMER_KEY);
                    UT_RemoveItemFromInventory(rLITE_IM_CARTA_OPEN_IRON);
                    UT_RemoveItemFromInventory(rLITE_IM_CARTA_RING_SILVER);
                    UT_RemoveItemFromInventory(rLITE_IM_CARTA_TRINKET_GAR);
                }
            }
            else if (sItemTag == LITE_IM_CARTA_TRINKET_FLO)
            {
                //failure - trigger trap
                WR_SetPlotFlag(PLT_LITE_CARTA_STASH, CARTA_STASH_TRIGGERED_A_TRAP, TRUE, TRUE);
                CartaTrapTriggered(oAcquirer);
                RemoveItemsByTag(oAcquirer, LITE_IM_CARTA_TRINKET_FLO);
            }
            else if (sItemTag == LITE_IM_CARTA_TRINKET_MAL)
            {
                //failure - trigger trap
                WR_SetPlotFlag(PLT_LITE_CARTA_STASH, CARTA_STASH_TRIGGERED_A_TRAP, TRUE, TRUE);
                CartaTrapTriggered(oAcquirer);
                RemoveItemsByTag(oAcquirer, LITE_IM_CARTA_TRINKET_MAL);
            }
            else if (sItemTag == LITE_IM_CARTA_TRINKET_GAR)
            {
                //have the trinket
                WR_SetPlotFlag(PLT_LITE_CARTA_STASH, CARTA_STASH_HAVE_TRINKET, TRUE, TRUE);
                //if you have all three items - you get the key
                if( WR_GetPlotFlag(PLT_LITE_CARTA_STASH, CARTA_STASH_HAVE_RING) == TRUE &&
                    // Qwinn fix
                    // WR_GetPlotFlag(PLT_LITE_CARTA_STASH, CARTA_STASH_HAVE_TRINKET) == TRUE)
                    WR_GetPlotFlag(PLT_LITE_CARTA_STASH, CARTA_STASH_HAVE_OPENNER) == TRUE)
                {
                    //remove the 3 pieces and give the key
                    UT_AddItemToInventory(rLITE_IM_CARTA_JAMMER_KEY);
                    UT_RemoveItemFromInventory(rLITE_IM_CARTA_OPEN_IRON);
                    UT_RemoveItemFromInventory(rLITE_IM_CARTA_RING_SILVER);
                    UT_RemoveItemFromInventory(rLITE_IM_CARTA_TRINKET_GAR);
                }
            }
            // Rogue Light Content
            else if (sItemTag == LITE_IM_ROGUE_DIRECTIONS)
            {
                if (WR_GetPlotFlag(PLT_LITE_ROGUE_DECISIONS,DECISIONS_RANDOM_ENCOUNTER))
                    WR_SetPlotFlag(PLT_LITE_ROGUE_DECISIONS,DECISIONS_LIEUT_DEAD,TRUE,TRUE);
                else
                    WR_SetPlotFlag(PLT_LITE_ROGUE_NEW_GROUND,NEW_GROUND_LIEUT_DEAD,TRUE,TRUE);
            }


            bEventHandled = TRUE;
            break;

        }
    }

    if (!bEventHandled)
        HandleEvent(evEvent, RESOURCE_SCRIPT_MODULE_CORE);

}

void CartaTrapTriggered(object oAcquirer)
{
    //cause damage
    DamageCreature(oAcquirer, GetArea(oAcquirer), 20.0, DAMAGE_TYPE_PHYSICAL);

    //cause injury
    Injury_DetermineInjury(oAcquirer);
}