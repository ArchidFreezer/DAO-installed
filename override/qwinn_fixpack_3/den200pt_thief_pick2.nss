//==============================================================================
/*
    den200pt_thief_pick2.nss
    The second quest in the Crime Wave series of plots from "Slim" Couldry.
*/
//==============================================================================
//  Created By: Ferret
//  Created On: June 24th, 2008
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "campaign_h"
#include "den_constants_h"

#include "plt_den200pt_thief"
#include "plt_den200pt_thief_pick2"

#include "plt_qwinn"

//------------------------------------------------------------------------------

int StartingConditional()
{
    event   eParms              = GetCurrentEvent();                // Contains all input parameters

    int     nType               = GetEventType(eParms);             // GET or SET call
    int     nFlag               = GetEventInteger(eParms, 1);       // The bit flag # being affected
    int     nResult             = FALSE;                            // used to return value for DEFINED GET events

    string  strPlot             = GetEventString(eParms, 0);        // Plot GUID

    object  oParty              = GetEventCreator(eParms);          // The owner of the plot table for this script
    object  oConversationOwner  = GetEventObject(eParms, 0);        // Owner on the conversation, if any

    object  oPC                 = GetHero();
    object  oTarg;

    plot_GlobalPlotHandler(eParms);                                 // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT)    // actions -> normal flags only
    {
        int nValue      =   GetEventInteger(eParms, 2);             // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue   =   GetEventInteger(eParms, 3);             // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {

            case THIEF_PICK2_ASSIGNED:              // DEN200_COULDRY
                                                    // You're given the mission
            {
                WR_SetPlotFlag(PLT_DEN200PT_THIEF, THIEF_PICKPOCKET_ACTIVE, TRUE, TRUE);

                // See if you should toggle quest giver notification
                if ( !WR_GetPlotFlag(PLT_DEN200PT_THIEF, THIEF_CHECK_IF_SNEAK_AVAILABLE) )
                {
                    object oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_COULDRY);
                    SetPlotGiver(oTarg, FALSE);
                }
                break;
            }

            case THIEF_PICK2_TAKE_FEE:              // DEN200_COULDRY
                                                    // He takes your money
            {
                // Remove the require fee of 1 gold from the PC
                UT_MoneyTakeFromObject(oPC, 0, 0, 1);

                break;
            }

            case NANCINE_CAUGHT_PC_STEALING:        // The PC failed at a pick pocket attempt of Ser Nancine
            {
                // Ser Nancine complains
                WR_SetPlotFlag(PLT_QWINN,DEN_NANCINE_CAUGHT_PC_STEALING,TRUE,TRUE);
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_PICK2_NANCINE);
                UT_Talk(oTarg, oPC);
                break;
            }

            case NANCINE_REMOVES_ARMOR_2:
            case NANCINE_REMOVES_ARMOR:             // DEN230_PICK2_NANCINE
                                                    // PC convinces her to remove her armor
            {
                object oItem;
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_PICK2_NANCINE);

                // Unequip everything
                oItem = GetItemInEquipSlot(INVENTORY_SLOT_CHEST, oTarg);
                UnequipItem(oTarg, oItem);
                oItem = GetItemInEquipSlot(INVENTORY_SLOT_GLOVES, oTarg);
                UnequipItem(oTarg, oItem);
                oItem = GetItemInEquipSlot(INVENTORY_SLOT_BOOTS, oTarg);
                UnequipItem(oTarg, oItem);
                oItem = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oTarg);
                UnequipItem(oTarg, oItem);

                // Restart dialog
                UT_Talk(oTarg, oPC);
                break;
            }

            case NANCINE_TRIES_ON_DRESS:
            case NANCINE_TRIES_ON_GOWN:             // DEN230_PICK2_NANCINE
                                                    // PC convinces her to try on a gown
            {
                object oItem;
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_PICK2_NANCINE);

                // Unequip everything
                oItem = GetItemInEquipSlot(INVENTORY_SLOT_CHEST, oTarg);
                UnequipItem(oTarg, oItem);
                oItem = GetItemInEquipSlot(INVENTORY_SLOT_GLOVES, oTarg);
                UnequipItem(oTarg, oItem);
                oItem = GetItemInEquipSlot(INVENTORY_SLOT_BOOTS, oTarg);
                UnequipItem(oTarg, oItem);
                oItem = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oTarg);
                UnequipItem(oTarg, oItem);

                // Equip the gown
                object [] oGown = GetItemsInInventory(oTarg, GET_ITEMS_OPTION_ALL, 0, DEN_IT_NANCINE_GOWN);
                EquipItem(oTarg, oGown[0]);

                // Restart dialog
                UT_Talk(oTarg, oPC);
                break;
            }

            case NANCINE_FALLS_UNCONSCIOUS:         // DEN230_PICK2_NANCINE
                                                    // She's tricked into drinking a sleep poison
            {
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_PICK2_NANCINE);
                command cUnconscious = CommandPlayAnimation(943);
                WR_AddCommand(oTarg, cUnconscious);
                break;
            }

            case NANCINE_KILLED:                    // DEN230_PICK2_NANCINE
                                                    // She's tricked into drinking a deadly poison
            {
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_PICK2_NANCINE);
                KillCreature(oTarg);
                break;
            }

            case THIEF_PICK2_SUCCESSFUL:
            {
                // Unequip Nancine's sword
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_PICK2_NANCINE);
                object oItem = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oTarg);
                UnequipItem(oItem, oTarg);

                // Qwinn: Removing sword so it can't be pickpocketed afterwards
                UT_RemoveItemFromInventory (DEN_IM_PICK2_SWORD, 1, oTarg);

                int bSword  =   UT_CountItemInInventory(DEN_IM_PICK2_SWORD, oPC);

                // This check is so that you don't endlessly loop getting the key
                if ( !bSword/*!WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK2, THIEF_PICK2_SUCCESSFUL)*/ )
                {
                    UT_AddItemToInventory(DEN_IM_PICK2_SWORD);
                }

                // You always get the next quest available
                WR_SetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_QUEUE_UP_PLOT_GIVER, TRUE, TRUE);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_DENERIM_4b);
            }

        }
     }
     else   // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {

            case THIEF_PICK2_PC_HAS_MONEY:      // Check to see if the PC has enough money
            {
                // Does the PC have the required fee of 1 gold.
                int bCondition = UT_MoneyCheck(oPC, 0, 0, 1);

                if(bCondition)
                {
                    nResult = TRUE;
                }

                break;
            }

        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}