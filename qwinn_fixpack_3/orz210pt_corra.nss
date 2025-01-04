//==============================================================================
/*

    Paragon of Her Kind
     -> Corra Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: February 8, 2007
//==============================================================================

#include "plt_genpt_oghren_defined"
#include "plt_gen00pt_class_race_gend"
#include "plt_gen00pt_party"

#include "plt_orz210pt_corra"
#include "plt_orz330pt_dulin"
#include "plt_orz340pt_talk_to_helmi"
#include "plt_orz400pt_zerlinda"

#include "plt_orzpt_talked_to"

#include "orz_constants_h"
#include "orz_functions_h"

#include "wrappers_h"
#include "utility_h"
#include "plot_h"


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

            case ORZ_CORRA_PC_BUYS_BEST:
            {

                //--------------------------------------------------------------
                // ACTION:  PC buys a pint off of Corra
                //--------------------------------------------------------------

                // Remove money from PC cash
                // Qwinn
                // UT_MoneyTakeFromObject( oPC, 120 );
                UT_MoneyTakeFromObject( oPC, 12000 );

                // Play drinking animation / insert pint into inventory

                break;

            }

            case ORZ_CORRA_PC_BUYS_PINT:
            {

                //--------------------------------------------------------------
                // ACTION:  PC buys a pint off of Corra
                //--------------------------------------------------------------

                // Remove money from PC cash
                // Qwinn
                // UT_MoneyTakeFromObject( oPC, 2 );
                UT_MoneyTakeFromObject( oPC, 300 );

                break;

            }

            case ORZ_CORRA_PC_BUYS_MEAD:
            {

                //--------------------------------------------------------------
                // ACTION:  PC buys a mead off of Corra
                //--------------------------------------------------------------

                // Remove money from cash
                // Qwinn
                // UT_MoneyTakeFromObject( oPC, 3 );
                UT_MoneyTakeFromObject( oPC, 150 );

                // Play drinking animation / insert pint into inventory

                break;

            }

            case ORZ_CORRA_PC_BUYS_WINE:
            {

                //--------------------------------------------------------------
                // ACTION:  PC buys a wine bottle off of Corra
                //--------------------------------------------------------------

                // Remove money from cash
                UT_MoneyTakeFromObject( oPC, 15);

                // Play drinking animation / insert pint into inventory

                break;

            }

            case ORZ_CORRA_PC_BUYS_DALISH_WINE_GLASS:
            {

                //--------------------------------------------------------------
                // ACTION:  PC buys a wine glass off of Corra
                //--------------------------------------------------------------

                // Remove money from cash
                UT_MoneyTakeFromObject( oPC, 21 );

                // Play drinking animation / insert pint into inventory

                break;

            }

            case ORZ_CORRA_MAIN_PC_BOUGHT_DALISH_WINE_BOTTLE:
            {

                //--------------------------------------------------------------
                // PLOT:    PC can no longer buy dalish wine from Corra after
                // ACTION:  PC buys a Dalish Wine Bottle off of Corra
                //--------------------------------------------------------------

                // Remove money from cash
                UT_MoneyTakeFromObject( oPC, 105 );

                // Play drinking animation / insert pint into inventory

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


            case ORZ_CORRA_PC_CAN_BUY_DALISH_WINE:
            {

                //--------------------------------------------------------------
                // COND:    If the player is an elf and has not yet bought
                //          Dalish Wine Bottle (Glass = ok!)
                //--------------------------------------------------------------

                int         bPCIsElf;
                int         bBoughtWineBottle;

                //--------------------------------------------------------------

                bPCIsElf          = WR_GetPlotFlag( PLT_GEN00PT_CLASS_RACE_GEND, GEN_RACE_ELF );
                bBoughtWineBottle = WR_GetPlotFlag( PLT_ORZ210PT_CORRA, ORZ_CORRA_MAIN_PC_BOUGHT_DALISH_WINE_BOTTLE );

                //--------------------------------------------------------------

                if ( bPCIsElf && !bBoughtWineBottle )
                    bResult = TRUE;

                break;

            }


            case ORZ_CORRA_PC_HAS_MONEY_FOR_BEST:
            {

                //--------------------------------------------------------------
                // COND:    Does PC have enough silver to buy mead?
                //--------------------------------------------------------------

                bResult = UT_MoneyCheck( oPC, 12000 );

                break;

            }


            case ORZ_CORRA_PC_HAS_MONEY_FOR_PINT:
            {

                //--------------------------------------------------------------
                // COND:    Does PC have enough silver to buy a pint?
                //--------------------------------------------------------------

                // Qwinn
                // bResult = UT_MoneyCheck( oPC, 2 );
                bResult = UT_MoneyCheck( oPC, 300 );

                break;

            }


            case ORZ_CORRA_PC_HAS_MONEY_FOR_MEAD:
            {

                //--------------------------------------------------------------
                // COND:    Does PC have enough silver to buy mead?
                //--------------------------------------------------------------

                // Qwinn
                // bResult = UT_MoneyCheck( oPC, 3 );
                bResult = UT_MoneyCheck( oPC, 150 );

                break;

            }


            case ORZ_CORRA_PC_HAS_MONEY_FOR_WINE:
            {

                //--------------------------------------------------------------
                // COND:    Does PC have enough silver to buy wine?
                //--------------------------------------------------------------

                bResult = UT_MoneyCheck( oPC, 15 );

                break;

            }


            case ORZ_CORRA_PC_HAS_MONEY_FOR_DALISH_WINE_GLASS:
            {

                //--------------------------------------------------------------
                // COND:    Does PC have enough silver to buy Dalish Wine Glass?
                //--------------------------------------------------------------

                bResult = UT_MoneyCheck( oPC, 21 );

                break;

            }


            case ORZ_CORRA_PC_HAS_MONEY_FOR_DALISH_WINE_BOTTLE:
            {

                //--------------------------------------------------------------
                // COND:    Does PC have enough silver to buy Dalish Wine Bottle?
                //--------------------------------------------------------------

                bResult = UT_MoneyCheck( oPC, 105 );

                break;

            }


            case ORZ_CORRA_CAN_ASK_ABOUT_DULIN:
            {

                //--------------------------------------------------------------
                // COND:    Dulin is in tapsters and the player has not yet
                //          talked to him.
                //--------------------------------------------------------------

                int         bDulinIsInTapsters;
                int         bDulinMetInTapsters;

                //--------------------------------------------------------------

                bDulinIsInTapsters  = WR_GetPlotFlag( PLT_ORZ330PT_DULIN, ORZ_DULIN_IS_IN_TAPSTERS );
                bDulinMetInTapsters = WR_GetPlotFlag( PLT_ORZ330PT_DULIN, ORZ_DULIN_MET_IN_TAPSTERS );

                //--------------------------------------------------------------

                if ( bDulinIsInTapsters && !bDulinMetInTapsters )
                    bResult = TRUE;

                break;

            }


            case ORZ_CORRA_CAN_ASK_ABOUT_LORD_HELMI:
            {

                //--------------------------------------------------------------
                // COND:    Lord Helmi is in tapsters and the player has
                //          not yet talked to him.
                //--------------------------------------------------------------

                // Qwinn:  This is wrong, Helmi is in Tapsters UNTIL plot 2 is completed
                // Will check if you've been given quest to find Helmi instead
                // The TT flag doesn't seem to always get set and Lord Helmi's dialogue is unviewable
                // Will also check if quest hasn't been completed.
                int bHelmiIsInTapsters;
                int bTTHelmi;

                //--------------------------------------------------------------

                // bHelmiIsInTapsters = WR_GetPlotFlag( PLT_ORZ340PT_TALK_TO_HELMI, ORZ_HELMI___PLOT_02_COMPLETED );
                bHelmiIsInTapsters = WR_GetPlotFlag( PLT_ORZ340PT_TALK_TO_HELMI, ORZ_HELMI___PLOT_01_ACCEPTED );
                bTTHelmi           = WR_GetPlotFlag( PLT_ORZ340PT_TALK_TO_HELMI, ORZ_HELMI___PLOT_02_COMPLETED ) ;

                //--------------------------------------------------------------

                if ( bHelmiIsInTapsters && !bTTHelmi )
                    bResult = TRUE;

                break;

            }


            case ORZ_CORRA_CAN_ASK_ABOUT_OGHREN:
            {

                //--------------------------------------------------------------
                // COND:    Oghren is in tapsters and the player has not yet
                //          talked to him.
                //--------------------------------------------------------------

                int         bOghrenIsInTapsters;
                int         bOghrenIsInDeepRoads;
                int         bOghrenRecruited;

                //--------------------------------------------------------------

                bOghrenIsInTapsters  = WR_GetPlotFlag( PLT_GENPT_OGHREN_DEFINED, OGHREN_DEFINED_PARAGON_OGHREN_IS_IN_TAPSTERS );
                // Qwinn:  Obvious fix is obvious
                // bOghrenIsInDeepRoads = WR_GetPlotFlag( PLT_GENPT_OGHREN_DEFINED, OGHREN_DEFINED_PARAGON_OGHREN_IS_IN_TAPSTERS );
                bOghrenIsInDeepRoads = WR_GetPlotFlag( PLT_GENPT_OGHREN_DEFINED, OGHREN_DEFINED_PARAGON_OGHREN_IS_IN_DEEPROADS );
                bOghrenRecruited     = WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_OGHREN_RECRUITED );

                //--------------------------------------------------------------

                if ( (bOghrenIsInTapsters || bOghrenIsInDeepRoads) && !bOghrenRecruited )
                    bResult = TRUE;

                break;

            }


            case ORZ_CORRA_CAN_ASK_ABOUT_ORDEL:
            {

                //--------------------------------------------------------------
                // COND:    Ordel is in tapsters and the player has not yet
                //          talked to him.
                //--------------------------------------------------------------

                int         bZerlindaAccepted;
                int         bTTOrdel;

                //--------------------------------------------------------------

                bZerlindaAccepted = WR_GetPlotFlag( PLT_ORZ400PT_ZERLINDA, ORZ_ZERLINDA___PLOT_01_ACCEPTED_FATHER );
                bTTOrdel          = WR_GetPlotFlag( PLT_ORZPT_TALKED_TO, ORZ_TT_ORDEL );

                //--------------------------------------------------------------

                if ( bZerlindaAccepted && !bTTOrdel )
                    bResult = TRUE;

                break;

            }


            case ORZ_CORRA_CAN_ASK_ABOUT_SOMEONE:
            {

                //--------------------------------------------------------------
                // COND:    One of the checks for "looking for someone" is true
                //--------------------------------------------------------------

                int         bLFOghren;
                int         bLFOrdel;
                int         bLFDulin;
                int         bLFHelmi;

                //--------------------------------------------------------------

                bLFOghren = WR_GetPlotFlag( sPlot, ORZ_CORRA_CAN_ASK_ABOUT_OGHREN);
                bLFOrdel  = WR_GetPlotFlag( sPlot, ORZ_CORRA_CAN_ASK_ABOUT_ORDEL);
                bLFDulin  = WR_GetPlotFlag( sPlot, ORZ_CORRA_CAN_ASK_ABOUT_DULIN);
                bLFHelmi  = WR_GetPlotFlag( sPlot, ORZ_CORRA_CAN_ASK_ABOUT_LORD_HELMI);

                //--------------------------------------------------------------

                if ( bLFOghren || bLFOrdel || bLFDulin || bLFHelmi )
                    bResult = TRUE;

                break;

            }


            case ORZ_CORRA_IS_UPSET_WITH_PC:
            {

                int bNoble;
                int bTTCorra;

                bNoble      = WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_DWARF_NOBLE );
                bTTCorra    = WR_GetPlotFlag( PLT_ORZPT_TALKED_TO, ORZ_TT_CORRA );

                if ( bNoble && bTTCorra )
                    bResult = TRUE;

                break;

            }
        }
    }

    // Plot Debug / Global Operations
    plot_OutputDefinedFlag( evEvent, bResult );

    return bResult;

}