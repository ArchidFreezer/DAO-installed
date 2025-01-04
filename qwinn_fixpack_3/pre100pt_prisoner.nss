//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events
*/
//:://////////////////////////////////////////////
//:: Created By: Yaron
//:: Created On: July 21st, 2006
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "pre_objects_h"
#include "campaign_h"

#include "plt_pre100pt_prisoner"

int StartingConditional()
{
    event eParms = GetCurrentEvent();                // Contains all input parameters
    int nType = GetEventType(eParms);               // GET or SET call
    string strPlot = GetEventString(eParms, 0);         // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);          // The bit flag # being affected
    object oParty = GetEventCreator(eParms);      // The owner of the plot table for this script
    int nGetResult = FALSE; // used to return value for DEFINED GET events

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    object oPC = GetHero();
    object oPrisoner = UT_GetNearestCreatureByTag(oPC, PRE_CR_PRISONER);
    object oGuard = UT_GetNearestCreatureByTag(oPC, PRE_CR_PRISONER_GUARD);

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case PRE_PRISONER_PC_GIVEN_FOOD:
            {
                if (nValue == 1)
                {
                    //  add food and water items to player's inventory.
                    UT_AddItemToInventory(PRE_IM_WATER);
                    UT_AddItemToInventory(PRE_IM_FOOD);
                    // Qwinn:  So you can't steal them after he's given them to you
                    UT_RemoveItemFromInventory (PRE_IM_WATER, 1, oGuard);
                    UT_RemoveItemFromInventory (PRE_IM_FOOD, 1, oGuard);
                }
                break;
            }
            case PRE_PRISONER_GUARD_BRIBED:
            {
                if (nValue == 1)
                {
                    UT_MoneyTakeFromObject(oPC, 0, PRE_MONEY_BRIBE_FOR_GUARD_SILVER, 0);
                }
                break;
            }
            case PRE_PRISONER_GOT_FOOD:
            {
                if (nValue == 1)
                {
                    // take food and water items from player
                    UT_RemoveItemFromInventory(PRE_IM_WATER);
                    UT_RemoveItemFromInventory(PRE_IM_FOOD);

                    //ACH_TrackPercentageComplete(ACH_FAKE_OSTAGAR_1);
                }
                break;
            }
            case PRE_PRISONER_GIVE_KEY:
            {
                if (nValue == 1)
                {
                    UT_AddItemToInventory(PRE_IM_KEY_WIZARDS_CHEST);
                    WR_SetPlotFlag(PLT_PRE100PT_PRISONER, PRE_PRISONER_FED, TRUE);
                    UT_RemoveItemFromInventory(PRE_IM_WATER);
                    UT_RemoveItemFromInventory(PRE_IM_FOOD);
                }
                break;
            }

               case PRE_PRISONER_GOT_FOOD_NO_KEY:
            {
                if (nValue == 1)
                {
                    WR_SetPlotFlag(PLT_PRE100PT_PRISONER, PRE_PRISONER_FED, TRUE);
                    UT_RemoveItemFromInventory(PRE_IM_WATER);
                    UT_RemoveItemFromInventory(PRE_IM_FOOD);

                    //ACH_TrackPercentageComplete(ACH_FAKE_OSTAGAR_1);
                }
                break;
            }

            case PRE_PRISONER_KILLED:
            {
                if (nValue == 1)
                {
                    // Alert guard, kill prisoner and give key to PC
                    WR_SetObjectActive(oPrisoner, FALSE);
                    //KillCreature(oPrisoner);
                    SetCreatureGoreLevel(oPrisoner, 0.75);
                    WR_SetPlotFlag(PLT_PRE100PT_PRISONER, PRE_PRISONER_GIVE_KEY, TRUE, TRUE);
                    UT_RemoveItemFromInventory(PRE_IM_WATER);
                    UT_RemoveItemFromInventory(PRE_IM_FOOD);
                    UT_Talk(oGuard, oPC);
                }
                break;
            }
            case PRE_PRISONER_PC_USED_KEY:
            {
                //percentage complete plot tracking -- CUT
                //ACH_TrackPercentageComplete(ACH_FAKE_OSTAGAR_1);

                break;
            }

            case PRE_PRISONER_ASKED_FOR_FOOD:
            {
                SetObjectInteractive(oGuard, TRUE);
                break;
            }
            
            case PRE_PRISONER_ABANDONED:
            {
                UT_RemoveItemFromInventory(PRE_IM_WATER);
                UT_RemoveItemFromInventory(PRE_IM_FOOD);
                break;
            }
            
            case PRE_PRISONER_LEFT_WITH_KEY_DID_NOT_USE:
            {
                UT_RemoveItemFromInventory(PRE_IM_WATER);
                UT_RemoveItemFromInventory(PRE_IM_FOOD);
                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {

            case PRE_PRISONER_PC_HAS_GOLD:
            {
                nGetResult = UT_MoneyCheck(oPC, 0, PRE_MONEY_BRIBE_FOR_GUARD_SILVER, 0);
                break;
            }

        }

    }

    return nGetResult;
}