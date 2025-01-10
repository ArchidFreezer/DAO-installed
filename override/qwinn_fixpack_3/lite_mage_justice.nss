//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for the lite_mage_justice plot
    betray the mages to the templars with lyrium
*/
//:://////////////////////////////////////////////
//:: Created By: Keith W
//:: Created On: Jan 13th, 2009
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "lit_constants_h"

#include "plt_lite_mage_justice"
#include "plt_lite_mage_silence"


void RemoveLyriumPotions();

int StartingConditional()
{
    event eParms = GetCurrentEvent();                // Contains all input parameters
    int nType = GetEventType(eParms);               // GET or SET call
    string strPlot = GetEventString(eParms, 0);         // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);          // The bit flag # being affected
    object oParty = GetEventCreator(eParms);      // The owner of the plot table for this script
    object oConversationOwner = GetEventObject(eParms, 0); // Owner on the conversation, if any
    int nResult = FALSE; // used to return value for DEFINED GET events
    object oPC = GetHero();

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            /*
              Remove 10 Lyrium Potions form the player’s inventory when complete.
            */
            case JUSTICE_QUEST_COMPLETE:
            {
                RemoveLyriumPotions();
                //This shuts down the Silence quest
                WR_SetPlotFlag(PLT_LITE_MAGE_SILENCE, SILENCE_BRIBE_NOT_DELIVERED, TRUE, TRUE);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_COLLECTIVE_7);
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case JUSTICE_QUEST_READY_TO_TURNIN:
            {
                //if the quest has been given - not turned in yet and the pc has 10 lyrium potions
                if (WR_GetPlotFlag(PLT_LITE_MAGE_JUSTICE, JUSTICE_QUEST_GIVEN) == TRUE && 
                    WR_GetPlotFlag(PLT_LITE_MAGE_JUSTICE, JUSTICE_QUEST_COMPLETE) == FALSE &&
                // Qwinn added this condition
                    WR_GetPlotFlag(PLT_LITE_MAGE_JUSTICE, JUSTICE_NOT_DONE) == FALSE)
                {
                    int nPotionCount = 0;
                    //get all of the stacks of lyrium potions
                    object [] arrPotion1 = GetItemsInInventory(oPC, GET_ITEMS_OPTION_BACKPACK, 0, LITE_IM_LESSER_LYRIUM_POTION);
                    object [] arrPotion2 = GetItemsInInventory(oPC, GET_ITEMS_OPTION_BACKPACK, 0, LITE_IM_LYRIUM_POTION);
                    object [] arrPotion3 = GetItemsInInventory(oPC, GET_ITEMS_OPTION_BACKPACK, 0, LITE_IM_GREATER_LYRIUM_POTION);
                    object [] arrPotion4 = GetItemsInInventory(oPC, GET_ITEMS_OPTION_BACKPACK, 0, LITE_IM_POTENT_LYRIUM_POTION);

                    //if there is a valid stack - add to the total potions
                    if (IsObjectValid(arrPotion1[0]) == TRUE)
                    {
                        nPotionCount = GetItemStackSize(arrPotion1[0]);
                    }
                    if (IsObjectValid(arrPotion2[0]) == TRUE)
                    {
                        //if you have at least 20 in your stack, you can turn them in.
                        nPotionCount = nPotionCount + GetItemStackSize(arrPotion2[0]);
                    }
                    if (IsObjectValid(arrPotion3[0]) == TRUE)
                    {
                        //if you have at least 20 in your stack, you can turn them in.
                        nPotionCount = nPotionCount + GetItemStackSize(arrPotion3[0]);
                    }
                    if (IsObjectValid(arrPotion4[0]) == TRUE)
                    {
                        //if you have at least 20 in your stack, you can turn them in.
                        nPotionCount = nPotionCount + GetItemStackSize(arrPotion4[0]);
                    }

                    if (nPotionCount >= 10)
                    {
                        nResult = TRUE;
                    }
                }
                break;
            }

        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}

void RemoveLyriumPotions()
{
    object oPC = GetHero();
    //remove the 10 lyriums (Check which kind the player has and remove them
    //from the crappy ones to the best ones, in order
    int nPotionsRemoved = 0;
    int nStackSize = 0;
    //get all of the stacks of lyrium potions
    object [] arrPotion1 = GetItemsInInventory(oPC, GET_ITEMS_OPTION_BACKPACK, 0, LITE_IM_LESSER_LYRIUM_POTION);
    object [] arrPotion2 = GetItemsInInventory(oPC, GET_ITEMS_OPTION_BACKPACK, 0, LITE_IM_LYRIUM_POTION);
    object [] arrPotion3 = GetItemsInInventory(oPC, GET_ITEMS_OPTION_BACKPACK, 0, LITE_IM_GREATER_LYRIUM_POTION);
    object [] arrPotion4 = GetItemsInInventory(oPC, GET_ITEMS_OPTION_BACKPACK, 0, LITE_IM_POTENT_LYRIUM_POTION);

    //if there is a valid stack - add to the total potions
    if (IsObjectValid(arrPotion1[0]) == TRUE)
    {
        nStackSize = GetItemStackSize(arrPotion1[0]);
        if (nStackSize >= 10)
        {
            UT_RemoveItemFromInventory(rLITE_IM_LESSER_LYRIUM_POTION, 10);
            nPotionsRemoved = 10;
        }
        else
        {
            UT_RemoveItemFromInventory(rLITE_IM_LESSER_LYRIUM_POTION, nStackSize);
            nPotionsRemoved = nStackSize;
        }
    }
    if (nPotionsRemoved < 10)
    {
        if (IsObjectValid(arrPotion2[0]) == TRUE)
        {
            nStackSize = GetItemStackSize(arrPotion2[0]);
            //if you have enough to cover the rest of the potions then remove them
            if (nStackSize >= 10 - nPotionsRemoved)
            {
                UT_RemoveItemFromInventory(rLITE_IM_LYRIUM_POTION, 10 - nPotionsRemoved);
                nPotionsRemoved = 10;
            }
            else
            {
                UT_RemoveItemFromInventory(rLITE_IM_LYRIUM_POTION, nStackSize);
                nPotionsRemoved = nPotionsRemoved - nStackSize;
            }
        }
        //check if we've removed enough yet - if not - go to the third stack
        if (nPotionsRemoved < 10)
        {
            if (IsObjectValid(arrPotion3[0]) == TRUE)
            {
                nStackSize = GetItemStackSize(arrPotion3[0]);
                //if you have enough to cover the rest of the potions then remove them
                if (nStackSize >= 10 - nPotionsRemoved)
                {
                    UT_RemoveItemFromInventory(rLITE_IM_GREATER_LYRIUM_POTION, 10 - nPotionsRemoved);
                    nPotionsRemoved = 10;
                }
                else
                {
                    UT_RemoveItemFromInventory(rLITE_IM_GREATER_LYRIUM_POTION, nStackSize);
                    nPotionsRemoved = nPotionsRemoved - nStackSize;
                }
            }
            //check if we've removed enough yet - if not - go to the fourth stack
            if (nPotionsRemoved < 10)
            {
                if (IsObjectValid(arrPotion4[0]) == TRUE)
                {
                    nStackSize = GetItemStackSize(arrPotion4[0]);
                    //THIS "HAS" to be enough to cover the rest of the potions then remove them
                    if (nStackSize >= 10 - nPotionsRemoved)
                    {
                        UT_RemoveItemFromInventory(rLITE_IM_GREATER_LYRIUM_POTION, 10 - nPotionsRemoved);
                        nPotionsRemoved = 10;
                    }
                }
            }
        }
    }
}