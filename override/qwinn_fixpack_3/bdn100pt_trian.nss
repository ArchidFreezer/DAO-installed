//==============================================================================
/*

    Dwarf Noble
     -> Trian Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: July 24, 2007
//==============================================================================

#include "plt_bdnpt_main"

#include "plt_bdn100pt_trian"
#include "plt_bdn120pt_gorim"
#include "plt_bdn200pt_expedition"

#include "bdn_constants_h"

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
    //plot_GlobalPlotHandler(evParms);

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


            case BDN_TRIAN__EVENT_BETRAYAL__SETUP:
            {

                //--------------------------------------------------------------
                // EVENT:   Set up the Betrayal event.
                //          Either Trians body or Trian and his guards will
                //          appear at the Deep Roads waiting for the player.
                //--------------------------------------------------------------
                // SENT BY: Trigger
                //--------------------------------------------------------------

                int         bPlayerPlotted;
                int         nIndex;
                int         nArraySize;
                object      oTrian;
                object      oCurrent;
                object []   arTrianTeam;

                //--------------------------------------------------------------

                bPlayerPlotted  = WR_GetPlotFlag( PLT_BDNPT_MAIN, BDN_MAIN_PC_PLOTTED_TO_KILL_TRIAN );
                oTrian          = UT_GetNearestCreatureByTag( oPC, BDN_CR_TRIAN );
                arTrianTeam     = UT_GetTeam( BDN_TEAM_TRIAN );
                nArraySize      = GetArraySize( arTrianTeam );

                //--------------------------------------------------------------

                // Move Trian
                UT_LocalJump( oTrian, BDN_WP_RUINED_TAIG_TRIAN );

                if ( bPlayerPlotted )
                {

                    //----------------------------------------------------------
                    // Trian is alive, him and guards appear
                    //----------------------------------------------------------

                    for ( nIndex = 0; nIndex < nArraySize; nIndex++ )
                    {
                        oCurrent = arTrianTeam[nIndex];
                        WR_SetObjectActive( oCurrent, TRUE );
                    }

                }

                else
                {

                    //----------------------------------------------------------
                    // Trian is dead, dead bodies of him and guards appear
                    //----------------------------------------------------------

                    for ( nIndex = 0; nIndex < nArraySize; nIndex++ )
                    {
                        oCurrent = arTrianTeam[nIndex];
                        SetLocalInt(oCurrent,CREATURE_SPAWN_DEAD,TRUE);
                        WR_SetObjectActive(oCurrent,TRUE);
                        KillCreature(oCurrent);
                    }

                }

                DoAutoSave();
                break;

            }


            case BDN_TRIAN__EVENT_BETRAYAL__TRIGGERED:
            {
                //--------------------------------------------------------------
                // EVENT:   Trian and Bhelen speak to the player on his way
                //          to the proving.
                //--------------------------------------------------------------
                // SENT BY: Trigger
                //--------------------------------------------------------------

                int bPlayerPlotted = WR_GetPlotFlag( PLT_BDNPT_MAIN, BDN_MAIN_PC_PLOTTED_TO_KILL_TRIAN );

                object oTrian = UT_GetNearestCreatureByTag( oPC, BDN_CR_TRIAN );
                object oGorim = UT_GetNearestCreatureByTag( oPC, BDN_CR_GORIM );

                WR_ClearAllCommands(oPC);

                if ( bPlayerPlotted )
                {

                    //----------------------------------------------------------
                    // Trian is alive, trigger dialog from him
                    //----------------------------------------------------------
                    UT_Talk( oTrian, oPC );

                }

                else
                {

                    //----------------------------------------------------------
                    // Trian is dead, Gorim initiates dialog
                    //----------------------------------------------------------
                    WR_SetPlotFlag( PLT_BDN120PT_GORIM, BDN_GORIM__EVENT_TRIAN_FOUND_BODY, TRUE, TRUE );

                    UT_Talk( oGorim, oPC );

                }

                break;

            }


            case BDN_TRIAN__EVENT_BETRAYAL_TRIAN_ATTACKS_PLAYER:
            {

                //--------------------------------------------------------------
                // EVENT:   Trian and his guards attack the PC
                //--------------------------------------------------------------

                UT_TeamGoesHostile( BDN_TEAM_TRIAN );

                break;

            }


            case BDN_TRIAN__EVENT_BROTHERS_HALL__SETUP:
            {

                //--------------------------------------------------------------
                // EVENT:   Set up Trian and Bhelen in the Noble's Quarter
                //          if the event is active.
                //--------------------------------------------------------------
                // SENT BY: Area Script
                //--------------------------------------------------------------

                int         bEventActive;
                object      oTrian;
                object      oBhelen;

                //--------------------------------------------------------------

                bEventActive    = WR_GetPlotFlag( PLT_BDN100PT_TRIAN, BDN_TRIAN__EVENT_BROTHERS_HALL__ACTIVE );
                oTrian          = UT_GetNearestCreatureByTag( oPC, BDN_CR_TRIAN );
                oBhelen         = UT_GetNearestCreatureByTag( oPC, BDN_CR_BHELEN );

                //--------------------------------------------------------------

                WR_SetObjectActive( oTrian,  bEventActive );
                WR_SetObjectActive( oBhelen, bEventActive );

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

            case BDN_TRIAN__EVENT_BETRAYAL__ACTIVE:
            {

                //--------------------------------------------------------------
                // COND:    The player has gotten the shield from the Thaig
                //          in the Deep Roads.
                //--------------------------------------------------------------

                int bHasShield = WR_GetPlotFlag( PLT_BDN200PT_EXPEDITION, BDN_EXPEDITION___PLOT_02_SHIELD_FOUND );
                int bHasShield2 = WR_GetPlotFlag( PLT_BDN200PT_EXPEDITION, BDN_EXPEDITION___PLOT_02_SHIELD_FOUND_2 );
                if ( bHasShield == TRUE || bHasShield2 == TRUE )
                    bResult = TRUE;

                break;

            }

            case BDN_TRIAN__EVENT_BROTHERS_HALL__ACTIVE:
            {

                //--------------------------------------------------------------
                // COND:    Brother's Hall event has not yet triggered.
                //          and the player has not been given the task to
                //          find Trian yet.
                //--------------------------------------------------------------

                int bTriggered = WR_GetPlotFlag( PLT_BDN100PT_TRIAN, BDN_TRIAN__EVENT_BROTHERS_HALL__TRIGGERED );
                int bFindTrian = WR_GetPlotFlag( PLT_BDNPT_MAIN, BDN_MAIN___PLOT_02_GET_TRIAN );

                if ( !bTriggered && !bFindTrian )
                    bResult = TRUE;

                break;

            }

            case BDN_TRIAN_PC_HAS_FANCY_DAGGER:
            {

                //--------------------------------------------------------------
                // COND:    Player has equipped the dagger that was given to
                //          him by the weapon merchant.
                //--------------------------------------------------------------

                // Qwinn
                /*
                */

                string sNobleDag = "gen_im_wep_mel_dag_nob";

                object oMainHandWeapon = GetItemInEquipSlot( INVENTORY_SLOT_MAIN, oPC );
                object oOffHandWeapon  = GetItemInEquipSlot( INVENTORY_SLOT_OFFHAND, oPC );

/*                if ( GetTag(oMainHandWeapon) == ResourceToTag(BDN_IM_FANCY_DAGGER_R) ||
                     GetTag(oOffHandWeapon) == ResourceToTag(BDN_IM_FANCY_DAGGER_R) )
                    bResult = TRUE;
*/
                if ( GetTag(oMainHandWeapon) == sNobleDag ||
                     GetTag(oOffHandWeapon) == sNobleDag )
                    bResult = TRUE;

                break;

            }


        }
    }

    return bResult;

}