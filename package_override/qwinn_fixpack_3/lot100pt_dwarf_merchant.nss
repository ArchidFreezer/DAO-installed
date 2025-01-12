//==============================================================================
/*
    lot100pt_dwarf_merchant.nss
    The encounter with the greedy merchant, who is actually NOT a dwarf.
*/
//==============================================================================
//  Created By:
//  Created On:
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "lot_constants_h"

#include "plt_lot100pt_dwarf_merchant"   

// Qwinn added for the discount variable
#include "campaign_h"

//------------------------------------------------------------------------------

int StartingConditional()
{
    event   eParms              =   GetCurrentEvent();                  // Contains all input parameters

    int     nType               =   GetEventType(eParms);               // GET or SET call
    int     nFlag               =   GetEventInteger(eParms, 1);         // The bit flag # being affected
    int     nResult             =   FALSE;                              // used to return value for DEFINED GET events

    string  strPlot             =   GetEventString(eParms, 0);          // Plot GUID

    object  oParty              =   GetEventCreator(eParms);            // The owner of the plot table for this script
    object  oConversationOwner  =   GetEventObject(eParms, 0);          // Owner on the conversation, if any

    object  oPC                 =   GetHero();

    object  oMerchant           =   UT_GetNearestObjectByTag(oPC, LOT_CR_DWARF_MERCHANT);
    object  oPriest             =   UT_GetNearestObjectByTag(oPC, LOT_CR_PRIEST);
    object  oFarmer1            =   UT_GetNearestObjectByTag(oPC, LOT_CR_DWARF_MERCHANT_FARMER1);
    object  oFarmer2            =   UT_GetNearestObjectByTag(oPC, LOT_CR_DWARF_MERCHANT_FARMER2);
    object  oStore              =   UT_GetNearestObjectByTag(oPC, "store_lot100cr_dwarfmerch");

    plot_GlobalPlotHandler(eParms);                                     // any global plot operations, including debug info


    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue      =   GetEventInteger(eParms, 2);                 // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue   =   GetEventInteger(eParms, 3);                 // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case DWARF_MERCHANT_CROWD_LEAVE:
            {

                // Priest and angry farmers leave
                WR_SetObjectActive(oPriest, FALSE);
                WR_SetObjectActive(oFarmer1, FALSE);
                WR_SetObjectActive(oFarmer2, FALSE);

                break;

            }

            case DWARF_MERCHANT_DISCOUNT:
            {

                break;

            }

            case DWARF_MERCHANT_OPEN_STORE:
            {
                int bDiscount = WR_GetPlotFlag(PLT_LOT100PT_DWARF_MERCHANT, DWARF_MERCHANT_DISCOUNT);

                // Qwinn:  Added this as the discount didn't work.  The 100 markup comes from the variable in campaign_h.
                if (bDiscount)
                   SetStoreMarkUp(oStore, LOT_DWARF_MERCHANT_DISCOUNT_EXTRA);

                   ScaleStoreItems(oStore);

                OpenStore(oStore);

                break;

            }

            case DWARF_MERCHANT_LEAVE:
            {

                object oPin =   UT_GetNearestObjectByTag(oPC, LOT_WP_DWARF_MERCH);

                SetMapPinState(oPin, FALSE);

                WR_SetObjectActive(oMerchant, FALSE);

                break;

            }

            case DWARF_MERCHANT_KILLED:
            {

                object oPin =   UT_GetNearestObjectByTag(oPC, LOT_WP_DWARF_MERCH);

                SetMapPinState(oPin, FALSE);

                // Deactivate the crowd.
                WR_SetObjectActive(oMerchant, FALSE);
                WR_SetObjectActive(oPriest, FALSE);
                WR_SetObjectActive(oFarmer1, FALSE);
                WR_SetObjectActive(oFarmer2, FALSE);

                break;

            }

        }

     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case DWARF_MERCHANT_DEAD_OR_LEAVE:
            {

                int bCondition1 =   WR_GetPlotFlag(PLT_LOT100PT_DWARF_MERCHANT,DWARF_MERCHANT_KILLED);
                int bCondition2 =   WR_GetPlotFlag(PLT_LOT100PT_DWARF_MERCHANT,DWARF_MERCHANT_LEAVE);

                nResult         =   bCondition1 || bCondition2;

                break;

            }

            case DWARF_MERCHANT_RESOLVED:
            {

                int bCondition1 = WR_GetPlotFlag(PLT_LOT100PT_DWARF_MERCHANT, DWARF_MARCHANT_NORMAL_PRICES);
                int bCondition2 = WR_GetPlotFlag(PLT_LOT100PT_DWARF_MERCHANT, DWARF_MERCHANT_DOUBLE_PRICES);
                int bCondition3 = WR_GetPlotFlag(PLT_LOT100PT_DWARF_MERCHANT, DWARF_MERCHANT_KILLED);
                int bCondition4 = WR_GetPlotFlag(PLT_LOT100PT_DWARF_MERCHANT, DWARF_MERCHANT_LEAVE);
                int bCondition5 = WR_GetPlotFlag(PLT_LOT100PT_DWARF_MERCHANT, DWARF_MERCHANT_DISCOUNT);
                int bCondition6 = WR_GetPlotFlag(PLT_LOT100PT_DWARF_MERCHANT, DWARF_MERCHANT_TOLD_BARLIN_HANDLED);

                nResult = ((bCondition1 || bCondition2 || bCondition3 || bCondition4 || bCondition5) && !(bCondition6));

                break;

            }

            case DWARF_MERCHANT_DEAD_OR_LEAVE_AND_BARLIN_TOLD:
            {

                int bCondition1 =   WR_GetPlotFlag(PLT_LOT100PT_DWARF_MERCHANT, DWARF_MERCHANT_DEAD_OR_LEAVE);
                int bCondition2 =   WR_GetPlotFlag(PLT_LOT100PT_DWARF_MERCHANT, DWARF_MERCHANT_TOLD_BARLIN_HANDLED);

                nResult =   bCondition1 && !bCondition2;


                break;

            }

        }

    }

    return nResult;
}