//==============================================================================
/*

    Item Acquired Event Script
     -> Denerim

*/
//------------------------------------------------------------------------------
// Created By:
// Created On: July 30, 2008
//==============================================================================

#include "utility_h"
#include "events_h"

#include "plt_denpt_rescue_the_queen"
#include "plt_denpt_captured"
#include "plt_denpt_slave_trade"
#include "plt_denpt_main"
#include "plt_den200pt_assassin_nrd"
#include "plt_den200pt_assassin_orz"
#include "plt_den200pt_assassin_end"
#include "plt_den200pt_fazzil_request"
#include "plt_den300pt_some_wicked"
#include "plt_den300pt_last_request"
#include "plt_den200pt_thief_pick1"
#include "plt_den200pt_thief_pick2"
#include "plt_den200pt_thief_pick3"
#include "plt_den200pt_thief_pick4"
#include "plt_den200pt_thief_sneak4"
#include "plt_den300pt_insane_beggar"
#include "plt_den300pt_some_wicked"
#include "plt_mnp00pt_ssf_landsmeet"
#include "plt_cod_lite_multi_vials"
#include "plt_lite_landry_slander"
#include "den_constants_h"
#include "den_lc_constants_h"

#include "plt_qwinn"

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

            ///---Rescue----///
            if (sItemTag == DEN_IT_RESCUE_RIORDAN_PAPERS)
            {
                WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_RIORDAN_PC_HAS_PAPERS, TRUE, TRUE);
            }
            else if (sItemTag == ResourceToTag(DEN_IM_RESCUE_HOWE_KEY))
            {
                WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_HOWE_KEY_ACQUIRED, TRUE, TRUE);
            }
            ///---Slave Trade----///
            else if (sItemTag == DEN_IT_APARTMENT_KEY)
            {
                WR_SetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_APARTMENT_KEY_AND_NOTE_FOUND, TRUE, TRUE);
            }
            else if (sItemTag == DEN_IT_SLAVER_DOCUMENTS)
            {
                // Qwinn:  This is to set journal entries and plot assist flags in correct order
                // WR_SetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_ACQUIRED_EVIDENCE, TRUE, TRUE);
                if (WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_ATTACKED_CALADRIUS_AGAIN) &&
                    !WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_KILLED_CALADRIUS))
                   WR_SetPlotFlag(PLT_QWINN, DEN_LOOTED_EVIDENCE_DURING_CALADRIUS_FIGHT,TRUE);
                else
                   WR_SetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_ACQUIRED_EVIDENCE, TRUE, TRUE);
            }
            ///---Captured----///
            else if (sItemTag == DEN_IT_CAPTURED_PASSWORD_LIST)
            {
                WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PASSWORD_ACQUIRED, TRUE, TRUE);
            }
            ///---Light Content----///
            else if (sItemTag == DEN_IT_FAZZIL_SEXTANT)
            {
                WR_SetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, FAZZIL_SEXTANT_RECOVERED, TRUE, TRUE);
            }
            else if (sItemTag == DEN_IT_BEGGAR_AMULET)
            {
                if(WR_GetPlotFlag(PLT_DEN300PT_SOME_WICKED, WICKED_CLUE_BEGGAR))
                {
                    WR_SetPlotFlag(PLT_DEN300PT_INSANE_BEGGAR, PC_FOUND_BEGGARS_AMULET, TRUE, TRUE);
                }

                else
                {
                    WR_SetPlotFlag(PLT_DEN300PT_INSANE_BEGGAR, PC_FOUND_AMULET_NEVER_TALKED, TRUE, TRUE);
                }
            }
            else if (sItemTag == DEN_IT_OTTO_JOURNAL)
            {
                WR_SetPlotFlag(PLT_DEN300PT_LAST_REQUEST, LAST_QUEST_ACTIVE, TRUE, TRUE);
            }
            /*else if (sItemTag == DEN_IT_ASSASSIN_NRD)
            {
                WR_SetPlotFlag(PLT_DEN200PT_ASSASSIN_NRD, ASSASSIN_NRD_QUEST_DONE, TRUE, TRUE);
            }
            else if (sItemTag == DEN_IT_ASSASSIN_ORZ)
            {
                WR_SetPlotFlag(PLT_DEN200PT_ASSASSIN_ORZ, ASSASSIN_ORZ_QUEST_DONE, TRUE, TRUE);
            }
            else if (sItemTag == DEN_IT_ASSASSIN_END)
            {
                WR_SetPlotFlag(PLT_DEN200PT_ASSASSIN_END, ASSASSIN_END_PAYMENT_TAKEN, TRUE, TRUE);
            }*/
            else if (sItemTag == DEN_IT_ASSASSIN_CONTRACT_NRD)
            {
                WR_SetPlotFlag(PLT_DEN200PT_ASSASSIN_NRD, ASSASSIN_NRD_QUEST_ACCEPTED, TRUE, TRUE);
            }
            else if (sItemTag == DEN_IT_ASSASSIN_CONTRACT_ORZ)
            {
                WR_SetPlotFlag(PLT_DEN200PT_ASSASSIN_ORZ, ASSASSIN_ORZ_QUEST_ACCEPTED, TRUE, TRUE);
            }
            else if (sItemTag == DEN_IT_TEARS_OF_ANDRASTE)
            {
                WR_SetPlotFlag(PLT_DEN200PT_THIEF_SNEAK4, THIEF_SNEAK4_SUCCESSFUL, TRUE, TRUE);
            }
            else if (sItemTag == DEN_IT_PICK1_PURSE)
            {
                WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK1, THIEF_PICK1_SUCCESSFUL, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);  // CW3422
            }
            else if (sItemTag == DEN_IT_PICK2_SWORD)
            {
                WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK2, THIEF_PICK2_SUCCESSFUL, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);  // CW3422
            }
            else if (sItemTag == DEN_IT_PICK3_KEY)
            {
                WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK3, THIEF_PICK3_KEY_STOLEN, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);  // CW3422
            }
            else if (sItemTag == DEN_IT_PICK4_CROWN)
            {
                WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK4, THIEF_PICK4_SUCCESSFUL, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);  // CW3422
            }
            else if (sItemTag == DEN_IM_VIALS_REVNOTE6)
            {
                WR_SetPlotFlag(PLT_COD_LITE_MULTI_VIALS, MULTI_BLACK_6, TRUE);
                RemoveItemsByTag(oPC, DEN_IM_VIALS_REVNOTE6);
            }
            else if (sItemTag == DEN_IT_LANDRY_NOTE)
            {
                WR_SetPlotFlag(PLT_LITE_LANDRY_SLANDER, LANDRY_SLANDER_PLOT_RECEIVED, TRUE, TRUE);
                UT_RemoveItemFromInventory(DEN_IM_LANDRY_NOTE);
            }


            bEventHandled = TRUE;
            break;

        }


        case EVENT_TYPE_UNIQUE_POWER:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_UNIQUE_POWER
            //------------------------------------------------------------------
            // Sent by: Scripting
            // When:    A unique power for an item is used
            //------------------------------------------------------------------

            int         nAbility;
            string      sItemTag;
            object      oItem;
            object      oCaster;
            object      oTarget;

            //------------------------------------------------------------------

            nAbility = GetEventInteger(evEvent,0);
            oItem    = GetEventObject(evEvent, 0);
            oCaster  = GetEventObject(evEvent, 1);
            oTarget  = GetEventObject(evEvent, 2);
            sItemTag = GetTag(oItem);

            //------------------------------------------------------------------

            bEventHandled = TRUE;
            break;

        }


    }

    if (!bEventHandled)
        HandleEvent(evEvent, RESOURCE_SCRIPT_MODULE_CORE);

}