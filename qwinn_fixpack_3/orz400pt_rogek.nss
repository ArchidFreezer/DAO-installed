//==============================================================================
/*

    Paragon of Her Kind
     -> Rogek Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: February 22, 2007
//==============================================================================

#include "plt_orz400pt_rogek"
#include "plt_orzpt_carta"

#include "cir_constants_h"
#include "orz_constants_h"
#include "orz_functions_h"

#include "wrappers_h"
#include "utility_h"
#include "plot_h"  

// Qwinn:  Bribe constants are set up incorrectly in orz_constants_h
// Will set up and use my own here.  The ACCEPTS are correct and in copper,
// so will do the same for these.
const int       ORZ_ROGEK_CASH_REQ_BRIBE_LOW_CORRECTED = 500;
const int       ORZ_ROGEK_CASH_REQ_BRIBE_HIGH_CORRECTED = 150000;

int StartingConditional()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evEvent = GetCurrentEvent();            // Contains input parameters
    int     nType   = GetEventType(evEvent);        // GET or SET call
    string  sPlot   = GetEventString(evEvent, 0);   // Plot GUID
    int     nFlag   = GetEventInteger(evEvent, 1);  // The bit flag # affected
    object  oOwner  = GetEventCreator(evEvent);     // Script plot table owner

    // Grab Player, Set Default return to FALSE
    object  oPC     = GetHero();
    object  oParty  = GetParty( oPC );
    int     bResult = FALSE;

    // Plot Debug / Global Operations
    plot_GlobalPlotHandler(evEvent);

    //--------------------------------------------------------------------------
    // Actions -> normal flags only (SET)
    // IMPORTANT:   The flag value on a SET event is set only AFTER this script
    //              finishes running!
    //--------------------------------------------------------------------------

    if( nType == EVENT_TYPE_SET_PLOT )
    {

        int nOldValue   = GetEventInteger(evEvent, 3);  // Old flag value
        int nNewValue   = GetEventInteger(evEvent, 2);  // New flag value

        // Check for which flag was set
        switch(nFlag)
        {

            case ORZ_ROGEK_GODWIN_LYRIUM_DONATED:
            {
                //Given the lyrium away, remove from plot items.
                UT_RemoveItemFromInventory( ORZ_IM_ROGEK_LYRIUM_R );
                break;
            }

            case ORZ_ROGEK___PLOT_01_ACCEPTED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC has accepted Rogeks' plot
                // ACTION:  PC recieves item [Smuggled Lyrium Shipment]
                //          PC loses money depending on whether he haggled
                //          with Rogek for a cheaper price successfuly or not.
                //--------------------------------------------------------------

                int         bHaggledPrice;
                object      oRogek;

                //--------------------------------------------------------------

                bHaggledPrice = WR_GetPlotFlag( sPlot, ORZ_ROGEK_PC_HAGGLES_TO_GET_LYRIUM_CHEAPER );
                oRogek        = UT_GetNearestCreatureByTag( oPC, ORZ_CR_ROGEK );

                //--------------------------------------------------------------

                SetPlotGiver( oRogek, FALSE );

                if ( nOldValue == FALSE )
                {
                    UT_AddItemToInventory( ORZ_IM_ROGEK_LYRIUM_R );
                    if ( bHaggledPrice == TRUE )
                    {
                        // Qwinn
                        // UT_MoneyTakeFromObject( oPC, 0, 0, ORZ_ROGEK_CASH_REQ_BRIBE_LOW );
                        UT_MoneyTakeFromObject( oPC, ORZ_ROGEK_CASH_REQ_ACCEPT_LOW );
                    }
                    else
                    {
                        // Qwinn
                        // UT_MoneyTakeFromObject( oPC, 0, 0, ORZ_ROGEK_CASH_REQ_BRIBE_HIGH );
                        UT_MoneyTakeFromObject( oPC, ORZ_ROGEK_CASH_REQ_ACCEPT_HIGH );
                    }
                }

                break;

            }


            case ORZ_ROGEK___PLOT_03_COMPLETED:
            {

                if ( WR_GetPlotFlag(sPlot, ORZ_ROGEK__REWARD_HIGH) )
                    RewardMoney( 0, 0, 25 );
                else if ( WR_GetPlotFlag(sPlot, ORZ_ROGEK__REWARD_MED) )
                    RewardMoney( 0, 0, 20 );
                else
                    RewardMoney( 0, 0, 10 );

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_ORZAMMAR_24);

                break;

            }

            case ORZ_ROGEK___PLOT_02_DELIVERY_MADE:
            {

                //--------------------------------------------------------------
                // PLOT:    PC has finished Rogeks' plot
                // ACTION:  PC loses item [Smuggled Lyrium Shipment]
                //--------------------------------------------------------------

                UT_RemoveItemFromInventory( ORZ_IM_ROGEK_LYRIUM_R );
                // Qwinn:  Added this because duh.
                WR_SetPlotFlag( sPlot, ORZ_ROGEK_GODWIN_DENIED_LYRIUM, FALSE );
                break;

            }

            case ORZ_ROGEK___PLOT_FAILED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC has FAILED Rogeks' plot
                //--------------------------------------------------------------

                object      oRogek;

                //--------------------------------------------------------------

                oRogek = UT_GetNearestCreatureByTag( oPC, ORZ_CR_ROGEK );

                //--------------------------------------------------------------

                SetPlotGiver( oRogek, FALSE );

                break;

            }


            case ORZ_ROGEK_ATTACKS:
            {

                //--------------------------------------------------------------
                // PLOT:    Rogek Plot is lost to the player
                // ACTION:  Rogek and his thugs attack the PC
                //--------------------------------------------------------------

                int         bPlotActive;
                object      oRogek;

                //--------------------------------------------------------------

                bPlotActive = WR_GetPlotFlag( sPlot, ORZ_ROGEK___PLOT_ACTIVE );
                oRogek        = UT_GetNearestCreatureByTag( oPC, ORZ_CR_ROGEK );

                //--------------------------------------------------------------

                SetPlotGiver( oRogek, FALSE );

                // If we had the Rogek quest, we just failed
                if ( bPlotActive )
                // Qwinn:  Changed to our new FAILED_FINAL closing state
                //  WR_SetPlotFlag( sPlot, ORZ_ROGEK___PLOT_FAILED, TRUE );
                WR_SetPlotFlag( sPlot, ORZ_ROGEK___PLOT_FAILED_FINAL, TRUE );

                UT_TeamAppears( ORZ_TEAM_ROGEK );
                UT_TeamGoesHostile( ORZ_TEAM_ROGEK );

                break;

            }


            case ORZ_ROGEK_DOES_NOT_TRUST_PC:
            {

                //--------------------------------------------------------------
                // PLOT:    Rogek plot is no longer available and Rogek does not
                //          trust the PC anymore. If talked to again, Rogek will
                //          attack the PC.
                // ACTION:  Rogek walks away.
                //--------------------------------------------------------------

                object      oRogek;

                //--------------------------------------------------------------

                oRogek = UT_GetNearestCreatureByTag( oPC, ORZ_CR_ROGEK );

                //--------------------------------------------------------------

                SetPlotGiver( oRogek, FALSE );

                UT_TeamExit( ORZ_TEAM_ROGEK, FALSE, ORZ_WP_ROGEK_MOVETO );

                break;

            }


            case ORZ_ROGEK_KILLED:
            {

                //--------------------------------------------------------------
                // PLOT:    Rogek was killed by the PC
                //--------------------------------------------------------------

                int         bPlotActive;

                //--------------------------------------------------------------

                bPlotActive = WR_GetPlotFlag( sPlot, ORZ_ROGEK___PLOT_ACTIVE );

                //--------------------------------------------------------------

                // If we had the Rogek quest, we just failed
                if ( bPlotActive )
                // Qwinn:  Changed this to our new final failed flag
                //  WR_SetPlotFlag( sPlot, ORZ_ROGEK___PLOT_FAILED, TRUE );
                    WR_SetPlotFlag( sPlot, ORZ_ROGEK___PLOT_FAILED_FINAL, TRUE );
                break;

            }


            case ORZ_ROGEK_PC_BRIBES_LOW:
            {

                //--------------------------------------------------------------
                // PLOT:    PC bribed Rogek for information on the Carta
                // ACTION:  PC loses money
                //--------------------------------------------------------------
                // Qwinn
                // UT_MoneyTakeFromObject( oPC, ORZ_ROGEK_CASH_REQ_BRIBE_LOW );
                UT_MoneyTakeFromObject( oPC, ORZ_ROGEK_CASH_REQ_BRIBE_LOW_CORRECTED );
                break;

            }


            case ORZ_ROGEK_PC_BRIBES_HIGH:
            {

                //--------------------------------------------------------------
                // PLOT:    PC bribed Rogek for information on the Carta
                // ACTION:  PC loses money
                //--------------------------------------------------------------
                // Qwinn
                // UT_MoneyTakeFromObject( oPC, ORZ_ROGEK_CASH_REQ_BRIBE_HIGH );
                UT_MoneyTakeFromObject( oPC, ORZ_ROGEK_CASH_REQ_BRIBE_HIGH_CORRECTED );
                break;

            }

            case ORZ_ROGEK_GODWIN_CONFRONTED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC talked to Greagoir, he is off to confront Gowdin
                //          about the Lyrium Smuggling
                // ACTION:  Fade out, start new dialog with Greagoir
                //          Godwin should now be gone
                //--------------------------------------------------------------

                object      oGreagoir;
                object      oGodwin;

                //--------------------------------------------------------------

                oGreagoir = UT_GetNearestObjectByTag( oPC, CIR_CR_GREAGOIR );
                oGodwin   = UT_GetNearestObjectByTag( oPC, CIR_CR_GODWIN );

                //--------------------------------------------------------------
                // Qwinn:  Adding this condition because conversation would trigger
                // yet again when the flag was cleared.  Godwin is not in the area
                // and won't be deactivated by this, had to add check to cir210ar_tower_level_2.nss
                // to make sure he doesn't get respawned.
                if (nNewValue)
                {
                    UT_Talk( oGreagoir, oPC );
                    WR_SetObjectActive( oGodwin, FALSE );
                }
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
            case ORZ_ROGEK___PLOT_ACTIVE:
            {

                //--------------------------------------------------------------
                // COND:    Quest accepted, but not completed
                //--------------------------------------------------------------

                //--------------------------------------------------------------

                // Qwinn:  Adding check against having failed.  This should've been
                // done with the previous flag anyway.

                int bPlotAccepted  = WR_GetPlotFlag( sPlot, ORZ_ROGEK___PLOT_01_ACCEPTED );
                int bPlotCompleted = WR_GetPlotFlag( sPlot, ORZ_ROGEK___PLOT_03_COMPLETED );
                int bPlotFailed    = WR_GetPlotFlag( sPlot, ORZ_ROGEK___PLOT_FAILED_FINAL );

                //--------------------------------------------------------------

                if ( bPlotAccepted && !bPlotCompleted && !bPlotFailed)
                    bResult = TRUE;

                break;

            }


            case ORZ_ROGEK_PC_CAN_ASK_ABOUT_JARVIA:
            {

                //--------------------------------------------------------------
                // COND:    PC has not yet killed Jarvia and has talked to
                //          Rogek about her
                //--------------------------------------------------------------

                int         bCartaPlotActive;
                int         bTalkedAboutJarvia;

                //--------------------------------------------------------------

                bCartaPlotActive   = WR_GetPlotFlag( PLT_ORZPT_CARTA, ORZ_CARTA___PLOT_ACTIVE );
                bTalkedAboutJarvia = WR_GetPlotFlag( sPlot, ORZ_ROGEK_TALKED_ABOUT_JARVIA );

                //--------------------------------------------------------------

                // Qwinn:  The dialogue allows you to get the info about Jarvia for free
                // if you've accepted his quest, but bTalkedAboutJarvia prevents you from doing
                // so.  That check makes no sense.  That he has NOT yet talked about Jarvia makes
                // sense, so that you can't repeatedly get the conversation.
                // if ( bCartaPlotActive && bTalkedAboutJarvia )
                if ( bCartaPlotActive && !bTalkedAboutJarvia )
                    bResult = TRUE;

                break;

            }


            case ORZ_ROGEK_PC_HAS_CASH_TO_ACCEPT_LOW:
            {

                //--------------------------------------------------------------
                // COND:    PC has enough cash
                //--------------------------------------------------------------
                // Qwinn
                // if ( UT_MoneyCheck(oPC, 0, 0, ORZ_ROGEK_CASH_REQ_BRIBE_LOW) == TRUE )
                if (UT_MoneyCheck(oPC, ORZ_ROGEK_CASH_REQ_ACCEPT_LOW) == TRUE )
                {
                    bResult = TRUE;
                }
                break;

            }


            case ORZ_ROGEK_PC_HAS_CASH_TO_ACCEPT_HIGH:
            {

                //--------------------------------------------------------------
                // COND:    PC has enough cash
                //--------------------------------------------------------------
                // Qwinn
                // if ( UT_MoneyCheck(oPC, 0, 0, ORZ_ROGEK_CASH_REQ_BRIBE_HIGH) == TRUE )
                if ( UT_MoneyCheck(oPC, ORZ_ROGEK_CASH_REQ_ACCEPT_HIGH) == TRUE )
                {
                    bResult = TRUE;
                }
                break;

            }


            case ORZ_ROGEK_PC_HAS_CASH_TO_BRIBE_LOW:
            {

                //--------------------------------------------------------------
                // COND:    PC has enough cash
                //--------------------------------------------------------------
                // Qwinn
                // if ( UT_MoneyCheck(oPC,ORZ_ROGEK_CASH_REQ_BRIBE_LOW) )
                if ( UT_MoneyCheck(oPC,ORZ_ROGEK_CASH_REQ_BRIBE_LOW_CORRECTED) )
                    bResult = TRUE;

                break;

            }


            case ORZ_ROGEK_PC_HAS_CASH_TO_BRIBE_HIGH:
            {

                //--------------------------------------------------------------
                // COND:    PC has enough cash
                //--------------------------------------------------------------
                // Qwinn
                // if ( UT_MoneyCheck(oPC,ORZ_ROGEK_CASH_REQ_BRIBE_HIGH) )
                if ( UT_MoneyCheck(oPC,ORZ_ROGEK_CASH_REQ_BRIBE_HIGH_CORRECTED) )
                    bResult = TRUE;

                break;

            }


        }
    }

    // Plot Debug / Global Operations
    plot_OutputDefinedFlag( evEvent, bResult );

    return bResult;

}