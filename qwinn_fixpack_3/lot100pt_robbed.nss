// Robbed villager plot

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "campaign_h"
#include "lot_constants_h"

#include "plt_lot100pt_robbed"

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

    object oRobbedMan = UT_GetNearestCreatureByTag(oPC, LOT_CR_ROBBED_MAN);
    object oRobbedWoman = UT_GetNearestCreatureByTag(oPC, LOT_CR_ROBBED_WOMAN);
    object oRobbedChild = UT_GetNearestCreatureByTag(oPC, LOT_CR_ROBBED_CHILD);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            // Qwinn:  The option to give the elves 50 silver is BADLY bugged.
            // Bug 1:  The value of LOT_ROBBED_VILLAGER_HELP_MONEY is 10 instead of 50
            // Bug 2:  In the check AND the Take, the value is in the gold column, not the silver column.
            // Bug 3:  If giving money, the dialogue sets "PC_GIVE_FOOD", not "PC_GIVE_HELP_MONEY".  There was no
            // case PC_GIVE_FOOD in this script, so nothing happens.
            // Effect: you don't even see the option without 10 gold, and if you try to give it, nothing is deducted.
            // I will hardcode the 50 silver here and add PC_GIVE_FOOD so we don't have to also modify the dialogue.


            case ROBBED_PC_GIVE_FOOD:
            {
                UT_MoneyTakeFromObject(oPC, 0, 50, 0);
                break;
            }

            case ROBBED_PC_GIVE_HELP_MONEY:
            {
                UT_MoneyTakeFromObject(oPC, 0, 0, LOT_ROBBED_VILLAGER_HELP_MONEY);
                break;
            }
            case ROBBED_LEAVE:
            {
                // family should leave area
                UT_TeamExit(LOT_TEAM_ROBBED_FAMILY);
                break;
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case ROBBED_PC_HAS_HELP_MONEY:
            {
                // Qwinn:  if(UT_MoneyCheck(oPC, 0, 0, LOT_ROBBED_VILLAGER_HELP_MONEY))
                    if(UT_MoneyCheck(oPC, 0, 50, 0))
                    nResult = TRUE;
                break;
            }
            case ROBBED_PC_HAS_FOOD_PACKAGE:
            {
                // TBD
                break;
            }

        }

    }

    return nResult;
}