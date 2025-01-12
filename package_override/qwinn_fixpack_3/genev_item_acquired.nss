//==============================================================================
/*

    Item Acquired Event Script
     -> Generic

*/
//------------------------------------------------------------------------------
// Created By:
// Created On: July 30, 2008
//==============================================================================

#include "utility_h"
#include "events_h"

#include "plt_lot100pt_herbalism101"
#include "plt_lot100pt_poison101"
#include "plt_lot100pt_traps101"
#include "zz_crafting_h"
#include "ntb_constants_h"
#include "lit_constants_h"
#include "plt_ntb210pt_revenant"
#include "plt_orzpt_city"
#include "plt_lite_chant_red_zombie"
#include "orz_dead_caste_h"


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

            //  Poison101 poisons
            if(sItemTag == ResourceToTag(GEN_IM_CRAFT_POISON_RAT) &&
                        WR_GetPlotFlag(PLT_LOT100PT_POISON101,POISON101_QUEST_ACCEPTED) &&
                            !WR_GetPlotFlag(PLT_LOT100PT_POISON101,POISON101_HAVE_POISONS))
            {
                    int nCount = UT_CountItemInInventory(GEN_IM_CRAFT_POISON_RAT);
                    if (nCount == 5)
                        WR_SetPlotFlag(PLT_LOT100PT_POISON101,POISON101_HAVE_POISONS,TRUE,TRUE);
            }

            //  Traps101 traps
            else if(sItemTag == ResourceToTag(GEN_IM_CRAFT_TRAP_WOODEN_CLAW) &&
                        WR_GetPlotFlag(PLT_LOT100PT_TRAPS101,TRAPS101_QUEST_ACCEPTED) &&
                            !WR_GetPlotFlag(PLT_LOT100PT_TRAPS101,TRAPS101_HAVE_TRAPS))
            {
                    int nCount = UT_CountItemInInventory(GEN_IM_CRAFT_TRAP_WOODEN_CLAW);
                    if (nCount == 5)
                        WR_SetPlotFlag(PLT_LOT100PT_TRAPS101,TRAPS101_HAVE_TRAPS,TRUE,TRUE);
            }

            //  Herbalism101 Poulstices
            else if(sItemTag == ResourceToTag(GEN_IM_CRAFT_HERB_POULTICE_OF_HEALTH) &&
                        WR_GetPlotFlag(PLT_LOT100PT_HERBALISM101,HERBALISM101_QUEST_ACCEPTED) &&
                            !WR_GetPlotFlag(PLT_LOT100PT_HERBALISM101,HERBALISM101_HAVE_POULTICES))
            {
                    int nCount = UT_CountItemInInventory(GEN_IM_CRAFT_HERB_POULTICE_OF_HEALTH);
                    if (nCount == 5)
                        WR_SetPlotFlag(PLT_LOT100PT_HERBALISM101,HERBALISM101_HAVE_POULTICES,TRUE,TRUE);
            }

            // Any part of the Juggernaut Armor for the Revenant Quest
            else if(sItemTag == NTB_IM_JUGGERNAUT_HELM || sItemTag == NTB_IM_JUGGERNAUT_GLOVES || sItemTag == NTB_IM_JUGGERNAUT_CHEST || sItemTag == NTB_IM_JUGGERNAUT_BOOTS)
            {
                //track which piece is recovered
                //Helm
                if (sItemTag == NTB_IM_JUGGERNAUT_HELM)
                {
                    WR_SetPlotFlag(PLT_NTB210PT_REVENANT, NTB_RECOVERED_HELM, TRUE, TRUE);
                    SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);   // GL3410

                }
                //Gloves
                else if (sItemTag == NTB_IM_JUGGERNAUT_GLOVES)
                {
                    WR_SetPlotFlag(PLT_NTB210PT_REVENANT, NTB_RECOVERED_GLOVES, TRUE, TRUE);
                    SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);   // GL3410

                }
                //Chest
                else if (sItemTag == NTB_IM_JUGGERNAUT_CHEST)
                {
                    WR_SetPlotFlag(PLT_NTB210PT_REVENANT, NTB_RECOVERED_CHEST, TRUE, TRUE);
                    SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);   // GL3410

                }
                //Boots
                else if (sItemTag == NTB_IM_JUGGERNAUT_BOOTS)
                {
                    WR_SetPlotFlag(PLT_NTB210PT_REVENANT, NTB_RECOVERED_BOOTS, TRUE, TRUE);
                    SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);   // GL3410
                    //LogTrace(LOG_CHANNEL_TEMP, "BOOTS RECOVERED");
                }

                //Track the recovered count
                int bHelm   = WR_GetPlotFlag(PLT_NTB210PT_REVENANT, NTB_RECOVERED_HELM);
                int bGloves = WR_GetPlotFlag(PLT_NTB210PT_REVENANT, NTB_RECOVERED_GLOVES);
                int bChest  = WR_GetPlotFlag(PLT_NTB210PT_REVENANT, NTB_RECOVERED_CHEST);
                int bBoots  = WR_GetPlotFlag(PLT_NTB210PT_REVENANT, NTB_RECOVERED_BOOTS);
                int nPlotStarted = WR_GetPlotFlag(PLT_NTB210PT_REVENANT, NTB_REVENANT_PLOT_STARTED);
                int nRecovered = bHelm + bGloves + bChest + bBoots;

                //if this is the first recovered piece - update journal entry
                if (nRecovered == 1)
                {
                    //if the helm is the first item, and the plot hasn't been started - give a
                    //different journal entry
                    if (nPlotStarted == FALSE)
                    {
                        WR_SetPlotFlag(PLT_NTB210PT_REVENANT, NTB_REVENANT_PLOT_STARTED, TRUE, TRUE);
                        WR_SetPlotFlag(PLT_NTB210PT_REVENANT, NTB_DISCOVERED_HELM_FIRST, TRUE, TRUE);
                    }
                    else
                    {
                        WR_SetPlotFlag(PLT_NTB210PT_REVENANT, NTB_RECOVERED_FIRST_ITEM, TRUE, TRUE);
                    }
                    //LogTrace(LOG_CHANNEL_TEMP, "THIS WAS ITEM # 1");
                }
                else if (nRecovered == 2)
                {
                    WR_SetPlotFlag(PLT_NTB210PT_REVENANT, NTB_RECOVERED_SECOND_ITEM, TRUE, TRUE);
                    //LogTrace(LOG_CHANNEL_TEMP, "THIS WAS ITEM # 2");
                }
                else if (nRecovered == 3)
                {
                    WR_SetPlotFlag(PLT_NTB210PT_REVENANT, NTB_RECOVERED_THIRD_ITEM, TRUE, TRUE);
                    //LogTrace(LOG_CHANNEL_TEMP, "THIS WAS ITEM # 3");
                }
                else if (nRecovered == 4)
                {
                    WR_SetPlotFlag(PLT_NTB210PT_REVENANT, NTB_RECOVERED_ALL, TRUE, TRUE);
                    //LogTrace(LOG_CHANNEL_TEMP, "THIS WAS ITEM # 4");
                }
                else
                {
                    //LogTrace(LOG_CHANNEL_TEMP, "This WAS ITEM# :" + IntToString(nRecovered));
                }
            }
            // Light Content - red zombie plot
            else if (sItemTag == "gen_it_corpse_gall")
            {
                //if we are on the plot and it's not done yet
                if (WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_ACCEPTED) == TRUE && WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_CLOSED_WITH_9) == FALSE &&
                    WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_CLOSED_WITH_18) == FALSE)
                {
                    int nStackSize = UT_CountItemInInventory(rLITE_IM_CORPSE_GALL);
                    //check the item count - update if 9 or 18
                    if (nStackSize >= 18)
                    {
                        if (WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_COMPLETE_WITH_18) == FALSE)
                        {
                            WR_SetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_COMPLETE_WITH_18, TRUE, TRUE);
                        }
                    }
                    else if (nStackSize >= 9)
                    {
                        if (WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_COMPLETE_WITH_9) == FALSE)
                        {
                            WR_SetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_COMPLETE_WITH_9, TRUE, TRUE);
                        }
                    }
                }
            }


            // Paragon plot -- Legion of the dead armor.
            //------------------------------------------------------------------
            // LEGION ARMOR
            //------------------------------------------------------------------
            else if ( sItemTag == ORZ_IM_LEGION_ARMOR )
            {
                WR_SetPlotFlag( PLT_COD_HST_ORZ_DEAD_CASTE, COD_HST_ORZ_DEAD_CASTE_2, TRUE, TRUE );
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);   // GL3410
            }

            //------------------------------------------------------------------
            // LEGION BOOTS
            //------------------------------------------------------------------
            else if ( sItemTag == ORZ_IM_LEGION_BOOTS )
            {
                WR_SetPlotFlag( PLT_COD_HST_ORZ_DEAD_CASTE, COD_HST_ORZ_DEAD_CASTE_0, TRUE, TRUE );
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);   // GL3410
            }

            //------------------------------------------------------------------
            // LEGION GLOVES
            //------------------------------------------------------------------
            else if ( sItemTag == ORZ_IM_LEGION_GLOVES )
            {
                WR_SetPlotFlag( PLT_COD_HST_ORZ_DEAD_CASTE, COD_HST_ORZ_DEAD_CASTE_1, TRUE, TRUE );
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);   // GL3410
            }

            //------------------------------------------------------------------
            // LEGION HELMET
            //------------------------------------------------------------------
            else if ( sItemTag == ORZ_IM_LEGION_HELMET )
            {
                WR_SetPlotFlag( PLT_COD_HST_ORZ_DEAD_CASTE, COD_HST_ORZ_DEAD_CASTE_3, TRUE, TRUE );
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);   // GL3410
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