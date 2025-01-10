//==============================================================================
/*

    Paragon of Her Kind
     -> Alimar Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: February 21, 2007
//==============================================================================

#include "plt_orz420pt_alimar"
#include "orz_constants_h"
#include "orz_functions_h"
#include "wrappers_h"
#include "utility_h"
#include "plot_h"
#include "plt_gen00pt_generic_actions"

int StartingConditional()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evParms = GetCurrentEvent();            // Contains input parameters
    int     nType   = GetEventType(evParms);        // GET or SET call
    string  sPlot   = GetEventString(evParms, 0);   // Plot GUID
    int     nFlag   = GetEventInteger(evParms, 1);  // The bit flag # affected
    object  oOwner  = GetEventCreator(evParms);     // Script plot table owner

    // Grab Player, Set Default return to FALSE
    object  oPC     = GetHero();
    int     bResult = FALSE;

    // Plot Debug / Global Operations
    plot_GlobalPlotHandler(evParms);

    //--------------------------------------------------------------------------
    // Actions -> normal flags only (SET)
    //--------------------------------------------------------------------------

    if( nType == EVENT_TYPE_SET_PLOT )
    {

        int nOldValue   = GetEventInteger(evParms, 3);  // Old flag value
        int nNewValue   = GetEventInteger(evParms, 2);  // New flag value

        // Check for which flag was set
        switch(nFlag)
        {


            case ORZ_ALIMAR_ACTION_OPEN_STORE:
            {
                //--------------------------------------------------------------
                // ACTION:  Alimar opens his store to the PC
                //--------------------------------------------------------------

                WR_SetPlotFlag( PLT_GEN00PT_GENERIC_ACTIONS, GEN_OPEN_STORE, TRUE , TRUE );

                break;

            }


            case ORZ_ALIMAR_ACTION_PC_GIVES_ALIMAR_CASH_HIGH:
            {
                //--------------------------------------------------------------
                // ACTION:  PC gives Alimar money
                //--------------------------------------------------------------

                // Qwinn
                // UT_MoneyTakeFromObject(oPC,ORZ_ALIMAR_CASH_REQ_HIGH);
                UT_MoneyTakeFromObject(oPC,0,ORZ_ALIMAR_CASH_REQ_HIGH);
                object oAlimar = UT_GetNearestCreatureByTag(oPC,ORZ_CR_ALIMAR);
                AddCreatureMoney(ORZ_ALIMAR_CASH_REQ_HIGH * 100, oAlimar, FALSE);
                break;

            }


            case ORZ_ALIMAR_ACTION_PC_GIVES_ALIMAR_CASH_LOW:
            {
                //--------------------------------------------------------------
                // ACTION:  PC gives Alimar money
                //--------------------------------------------------------------

                // Qwinn
                // UT_MoneyTakeFromObject(oPC,ORZ_ALIMAR_CASH_REQ_LOW);
                UT_MoneyTakeFromObject(oPC,0,ORZ_ALIMAR_CASH_REQ_LOW);
                object oAlimar = UT_GetNearestCreatureByTag(oPC,ORZ_CR_ALIMAR);
                AddCreatureMoney(ORZ_ALIMAR_CASH_REQ_LOW * 100, oAlimar, FALSE);

                break;

            }


            case ORZ_ALIMAR_ACTION_PC_GIVES_ALIMAR_CASH_MED:
            {
                //--------------------------------------------------------------
                // ACTION:  PC gives Alimar money
                //--------------------------------------------------------------

                UT_MoneyTakeFromObject(oPC,ORZ_ALIMAR_CASH_REQ_MED);

                break;

            }


            case ORZ_ALIMAR_ACTION_PC_GIVES_ALIMAR_CASH_VERY_HIGH:
            {
                //--------------------------------------------------------------
                // ACTION:  PC gives Alimar money
                //--------------------------------------------------------------

                UT_MoneyTakeFromObject(oPC,ORZ_ALIMAR_CASH_REQ_V_HIGH);

                break;

            }


            case ORZ_ALIMAR_PC_KILLS_ALIMAR:
            {
                //--------------------------------------------------------------
                // PLOT:    Alimar will not appear again after being killed
                // ACTION:  Alimar attacks the PC
                //--------------------------------------------------------------

                object      oAlimar;

                //--------------------------------------------------------------

                oAlimar = UT_GetNearestCreatureByTag(oPC,ORZ_CR_ALIMAR);

                //--------------------------------------------------------------

                UT_CombatStart(oAlimar,oPC);

                break;

            }


        }
    }

    //--------------------------------------------------------------------------
    // Conditions -> defined flags only (GET DEFINED)
    //--------------------------------------------------------------------------

    else
    {

        // Check for which flag was checked
        switch(nFlag)
        {

            case ORZ_ALIMAR_PC_HAS_ALIMAR_CASH_HIGH:
            {

                //--------------------------------------------------------------
                // COND:    PC has enough money
                //--------------------------------------------------------------
                // Qwinn
                // bResult = UT_MoneyCheck(oPC,ORZ_ALIMAR_CASH_REQ_HIGH);
                bResult = UT_MoneyCheck(oPC,0,ORZ_ALIMAR_CASH_REQ_HIGH);

                break;

            }

            case ORZ_ALIMAR_PC_HAS_ALIMAR_CASH_LOW:
            {

                //--------------------------------------------------------------
                // COND:    PC has enough money
                //--------------------------------------------------------------

                // Qwinn
                // bResult = UT_MoneyCheck(oPC,ORZ_ALIMAR_CASH_REQ_LOW);
                bResult = UT_MoneyCheck(oPC,0,ORZ_ALIMAR_CASH_REQ_LOW);

                break;

            }

            case ORZ_ALIMAR_PC_HAS_ALIMAR_CASH_MED:
            {

                //--------------------------------------------------------------
                // COND:    PC has enough money
                //--------------------------------------------------------------

                bResult = UT_MoneyCheck(oPC,ORZ_ALIMAR_CASH_REQ_MED);

                break;

            }

            case ORZ_ALIMAR_PC_HAS_ALIMAR_CASH_VERY_HIGH:
            {

                //--------------------------------------------------------------
                // COND:    PC has enough money
                //--------------------------------------------------------------

                bResult = UT_MoneyCheck(oPC,ORZ_ALIMAR_CASH_REQ_V_HIGH);

                break;

            }

        }
    }

    return bResult;

}