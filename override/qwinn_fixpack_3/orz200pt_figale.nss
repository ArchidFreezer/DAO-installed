//==============================================================================
/*

    Paragon of Her Kind
     -> Figale Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: February 7, 2007
//==============================================================================

#include "plt_orzpt_generic"
#include "plt_orzpt_defined"
#include "plt_orzpt_carta"
#include "plt_gen00pt_generic_actions"

#include "plt_orz200pt_figale"

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



            case ORZ_FIGALE__EVENT_COMMONS_ROGGAR_1__TRIGGERED:
            {

                //--------------------------------------------------------------
                // ORZ_FIGALE__EVENT_COMMONS_ROGGAR_1__TRIGGERED:
                //--------------------------------------------------------------

                object oRoggar = UT_GetNearestObjectByTag(oPC, ORZ_CR_ROGGAR);

                UT_Talk(oRoggar, oPC);

                break;

            }

            case ORZ_FIGALE__EVENT_COMMONS_ROGGAR_1__SETUP:
            {

                //--------------------------------------------------------------
                // ORZ_FIGALE__EVENT_COMMONS_ROGGAR_1__SETUP:
                //--------------------------------------------------------------

                int bFigaleEventActive    = WR_GetPlotFlag(PLT_ORZ200PT_FIGALE,ORZ_FIGALE__EVENT_COMMONS_ROGGAR_1__ACTIVE);
                int bFigaleEventTriggered = WR_GetPlotFlag(PLT_ORZ200PT_FIGALE,ORZ_FIGALE__EVENT_COMMONS_ROGGAR_1__TRIGGERED);

                object oFigale          = UT_GetNearestObjectByTag(oPC, ORZ_CR_FIGALE);
                object oRoggar          = UT_GetNearestObjectByTag(oPC, ORZ_CR_ROGGAR);
                object [] arRoggarThugs = UT_GetAllObjectsInAreaByTag(ORZ_CR_ROGGAR_THUG);

                int nNumRogThugs = GetArraySize(arRoggarThugs);
                int i;

                // Activate/Deactivate Thugs
                WR_SetObjectActive( oFigale, bFigaleEventActive );
                WR_SetObjectActive( oRoggar, bFigaleEventActive );
                for (i=0; i<nNumRogThugs; i++)
                    WR_SetObjectActive( arRoggarThugs[i], bFigaleEventActive );

                // If the event has already been triggered, the door to figale's
                // shop should be open.
                object oShopDoor = UT_GetNearestObjectByTag(oPC,ORZ_IP_COMMONS_SHOP_DOOR);

                if ( bFigaleEventTriggered &&
                     PLC_STATE_DOOR_LOCKED == GetPlaceableState( oShopDoor ) )
                    SetPlaceableActionResult( oShopDoor, PLACEABLE_ACTION_UNLOCK, TRUE );

                break;

            }


            case ORZ_FIGALE__EVENT_FIGALES_SHOP_ROGGAR_2__TRIGGERED:
            {

                //--------------------------------------------------------------
                // ORZ_FIGALE__EVENT_FIGALES_SHOP_ROGGAR_2__TRIGGERED:
                //--------------------------------------------------------------

                object oRoggar = UT_GetNearestObjectByTag(oPC, ORZ_CR_ROGGAR);

                UT_Talk(oRoggar, oPC);

                break;

            }

            case ORZ_FIGALE__EVENT_FIGALES_SHOP_ROGGAR_2__SETUP:
            {

                //--------------------------------------------------------------
                // ORZ_FIGALE__EVENT_FIGALES_SHOP_ROGGAR_2__SETUP:
                //--------------------------------------------------------------

                int bFigaleEvent2Active = WR_GetPlotFlag(PLT_ORZ200PT_FIGALE,ORZ_FIGALE__EVENT_FIGALES_SHOP_ROGGAR_2__ACTIVE);

                object oFigale          = UT_GetNearestObjectByTag(oPC, ORZ_CR_FIGALE);
                object oRoggar          = UT_GetNearestObjectByTag(oPC, ORZ_CR_ROGGAR);
                object [] arRoggarThugs = UT_GetAllObjectsInAreaByTag(ORZ_CR_ROGGAR_THUG);
                object oThug;

                int nNumRogThugs = GetArraySize(arRoggarThugs);
                int i;

                // Grant - Aug 14, 08: Figor and friends set to interactive.
                // Activate/Deactivate Thugs
                WR_SetObjectActive( oFigale, bFigaleEvent2Active );
                SetObjectInteractive( oFigale, TRUE );

                WR_SetObjectActive( oRoggar, bFigaleEvent2Active );
                SetObjectInteractive( oRoggar, TRUE );

                for (i = 0; i < nNumRogThugs; ++i)
                {

                    oThug = arRoggarThugs[i];

                    WR_SetObjectActive( oThug, bFigaleEvent2Active );
                    SetObjectInteractive( oThug, TRUE );

                }

                break;

            }

            case ORZ_FIGALE_ACTION_REPEAT_OPEN_STORE_CHEAP:
            {

                //--------------------------------------------------------------
                // ACTION:  Figale allows the PC to look at his wares
                //--------------------------------------------------------------

                WR_SetPlotFlag( PLT_GEN00PT_GENERIC_ACTIONS, GEN_OPEN_STORE, TRUE, TRUE );

                break;

            }

            case ORZ_FIGALE_RUNS_AWAY_SCARED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC is inconsiderate of Figale's situation. His body
                //          should be found in the slums the next time the
                //          player goes there.
                // ACTION:  Figale flees the store.
                //--------------------------------------------------------------

                // Grab Figale object
                object oFigale  = UT_GetNearestObjectByTag(oPC, ORZ_CR_FIGALE);

                UT_ExitDestroy( oFigale, TRUE );

                object oWaypoint = UT_GetNearestObjectByTag(oPC, ORZ_WP_FIGOR_MERCH);

                DestroyObject( oWaypoint );

                break;

            }

            case ORZ_FIGALE_THUGS_GO_TO_SHOP:
            {

                //--------------------------------------------------------------
                // GO_TO_SHOP:
                // Roggar, Figale, and thugs go into Figale's shop
                //--------------------------------------------------------------

                object oFigale          = UT_GetNearestObjectByTag(oPC, ORZ_CR_FIGALE);
                object oRoggar          = UT_GetNearestObjectByTag(oPC, ORZ_CR_ROGGAR);
                object [] arRoggarThugs = UT_GetAllObjectsInAreaByTag(ORZ_CR_ROGGAR_THUG);

                int nNumRogThugs = GetArraySize(arRoggarThugs);

                int i;

                // Activate/Deactivate Thugs
                UT_ExitDestroy( oFigale, FALSE, "mn_exit_figale_shop" );
                UT_ExitDestroy( oRoggar, FALSE, "mn_exit_figale_shop" );
                for (i=0; i<nNumRogThugs; i++)
                    UT_ExitDestroy( arRoggarThugs[i], FALSE, "mn_exit_figale_shop" );

                // Open the door to Figales Shop
                object oShopDoor = UT_GetNearestObjectByTag(oPC,ORZ_IP_COMMONS_SHOP_DOOR);
                SetPlaceableActionResult( oShopDoor, PLACEABLE_ACTION_UNLOCK, TRUE );

                break;

            }

            case ORZ_FIGALE_ROGGAR_ATTACKS:
            {

                //--------------------------------------------------------------
                // PLOT:    To get him to leave Figale alone, the PC decides
                //          to initiate combat with Roggar
                // ACTION:  Roggar and his thugs go hostile
                //--------------------------------------------------------------

                UT_TeamGoesHostile( ORZ_TEAM_CARTA_ROGGAR );

                break;

            }

            case ORZ_FIGALE_ROGGAR_SCARED:
            {

                //--------------------------------------------------------------
                // PLOT:    To get him to leave Figale alone, the PC intimidates
                //          Roggar, who then flees. his means that Roggar should
                //          show up in the Gangster's Hideout later.
                // ACTION:  Roggar and his thugs run out of Figale's store
                //--------------------------------------------------------------

                UT_TeamExit( ORZ_TEAM_CARTA_ROGGAR, TRUE );

                break;

            }

            case ORZ_FIGALE_ROGGAR_PAID_OFF:
            {

                //--------------------------------------------------------------
                // PLOT:    To get him to leave Figale alone, the PC offers to
                //          give him gold. This means that Roggar should show
                //          up in the Gangster's Hideout later.
                // ACTION:  PC gives Roggar gold.
                //--------------------------------------------------------------
                                              
                // Qwinn:  No money was taken, though you couldn't actually get here
                UT_MoneyTakeFromObject( oPC, 0, 0, ORZ_ROGGAR_CASH_REQ );
                
                UT_TeamExit( ORZ_TEAM_CARTA_ROGGAR );

                break;

            }

            case ORZ_FIGALE_ROGGAR_KILLED:
            {

                //--------------------------------------------------------------
                // PLOT:    The PC kills Roggar and his thugs, scaring Figale
                //          and opening new dialogues with him. This means that
                //          Roggar should NOT show up in the Gangster's Hideout
                //          later.
                //--------------------------------------------------------------

                object oFigale  = UT_GetNearestObjectByTag(oPC, ORZ_CR_FIGALE);

                UT_Talk( oFigale, oPC );

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

            case ORZ_FIGALE__EVENT_COMMONS_ROGGAR_1__ACTIVE:
            {

                //--------------------------------------------------------------
                // ACTIVE: if either first task accepted
                //--------------------------------------------------------------

                int bTriggered     = WR_GetPlotFlag(sPlot,ORZ_FIGALE__EVENT_COMMONS_ROGGAR_1__TRIGGERED);
                int bEitherT1      = WR_GetPlotFlag(PLT_ORZPT_DEFINED,ORZ_DEFINED_EITHER_TASK_1_ACCEPTED);
                int bCartaComplete = WR_GetPlotFlag(PLT_ORZPT_CARTA,ORZ_CARTA_JARVIA_DEAD);

                if (!bTriggered && bEitherT1 && !bCartaComplete)
                    bResult = TRUE;

                break;

            }

            case ORZ_FIGALE__EVENT_FIGALES_SHOP_ROGGAR_2__ACTIVE:
            {

                //--------------------------------------------------------------
                // ACTIVE: if Roggar has already been seen Harrassing Figale
                //--------------------------------------------------------------

                int bTriggered     = WR_GetPlotFlag(sPlot,ORZ_FIGALE__EVENT_FIGALES_SHOP_ROGGAR_2__TRIGGERED);
                int bHarrased      = WR_GetPlotFlag(sPlot,ORZ_FIGALE__EVENT_COMMONS_ROGGAR_1__TRIGGERED);
                int bCartaComplete = WR_GetPlotFlag(PLT_ORZPT_CARTA,ORZ_CARTA_JARVIA_DEAD);

                if (!bTriggered && bHarrased && !bCartaComplete)
                    bResult = TRUE;

                break;

            }

            case ORZ_FIGALE_JARVIA_NOT_DEAD_PLAYER_IS_DWARF:
            {

                //--------------------------------------------------------------
                // ACTIVE: if Jarvia is a dead and the player is dwarven.
                //--------------------------------------------------------------

                int nRace = GetCreatureRacialType(oPC);

                int bRace   = nRace == RACE_DWARF;
                int bJarvia = !WR_GetPlotFlag(PLT_ORZPT_CARTA, ORZ_CARTA_JARVIA_DEAD);

                if (bRace && bJarvia)
                    bResult = TRUE;

                break;

            }

            case ORZ_FIGALE_JARVIA_NOT_DEAD_PLAYER_IS_NOT_DWARF:
            {

                //--------------------------------------------------------------
                // ACTIVE: if Jarvia is a dead and the player is NOT dwarven.
                //--------------------------------------------------------------

                int nRace = GetCreatureRacialType(oPC);

                int bRace = nRace != RACE_DWARF;
                int bJarvia = !WR_GetPlotFlag(PLT_ORZPT_CARTA, ORZ_CARTA_JARVIA_DEAD);

                if (bRace && bJarvia)
                    bResult = TRUE;

                break;

            }
            
            // Qwinn:  This case was completely missing, disabling the bribe option
            case ORZ_FIGALE_PC_HAS_ROGGAR_GOLD:
            {
                if (UT_MoneyCheck(oPC, 0, 0, ORZ_ROGGAR_CASH_REQ) == TRUE )
                    bResult = TRUE;
                break;
            }
        }

    }

    return bResult;

}