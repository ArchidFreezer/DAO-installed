//==============================================================================
/*

    Dwarf Noble
     -> Main Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: July 27, 2007
//==============================================================================

#include "plt_bdnpt_main"
#include "plt_bdnpt_generic"
#include "plt_bdn120pt_gorim"
#include "plt_bdn100pt_trian"
#include "plt_bdn120pt_dace"
#include "plt_bdn100pt_scholar"
#include "plt_bdn110pt_provings"
#include "plt_cod_cha_endrin"
#include "plt_cod_mgc_darkspawn"
#include "plt_cod_cha_bhelen"



#include "bdn_constants_h"


#include "sys_achievements_h"
#include "wrappers_h"
#include "utility_h"
#include "plot_h"
#include "tutorials_h"
#include "sys_ambient_h"

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
            case BDN_MAIN_PLOT__START_TUTORIALS:
            {
                int         nIndex;
                int         nArraySize;
                object      oCurrent;
                object      oChest;
                object []   arInventory;

                oChest      = UT_GetNearestObjectByTag( oPC, BDN_IP_PC_CHEST );

                //Add any equipment that the player might have been given by Gorim
                //if the player didn't take his shield - it's in the chest
                WR_SetPlotFlag(PLT_BDN120PT_GORIM, BDN_GORIM__GIVE_SWORD, TRUE, TRUE);
                if ( WR_GetPlotFlag(PLT_BDN120PT_GORIM, BDN_GORIM__ENDCONV_GIVE_SHIELD) )
                {
                     WR_SetPlotFlag(PLT_BDN120PT_GORIM, BDN_GORIM__REWARD_SHIELD, TRUE, TRUE);
                }
                else
                {
                    UT_AddItemToInventory(BDN_IM_STARTING_SHIELD_R, 1, oChest);
                }

                // Equip all possible items in backpack (shield if we got it)
                arInventory = GetItemsInInventory(oPC,GET_ITEMS_OPTION_BACKPACK);
                nArraySize = GetArraySize(arInventory);
                for ( nIndex = 0; nIndex < nArraySize; nIndex++ )
                {
                    // Qwinn:  Don't equip DLC
                    // Copied exclusion code from bdn300ar_orzammar_prison.nss
                    oCurrent = arInventory[nIndex];
                    string sItem = GetTag(oCurrent);
                    string sItemPre = StringLeft(sItem, 3);

                    if(sItemPre != "prc" &&
                       sItemPre != "prm" &&
                       sItem != "gen_im_acc_rng_exp" &&
                       sItem != "gen_im_qck_book_skill" &&
                       sItem != "gen_im_qck_book_attribute3")
                      EquipItem(oPC,oCurrent);
                }

                //TUTORIAL STUFF
                //tactical view tutorial
                BeginTrainingMode(TRAINING_SESSION_TACTICAL_VIEW);

                break;
            }

            case BDN_MAIN___PLOT_01_ACCEPTED_GORIM_HIRED:
            {

                //--------------------------------------------------------------
                // PLOT:    Gorim is added to the Player's party.
                //--------------------------------------------------------------

                object      oGorim;


                //--------------------------------------------------------------

                oGorim      = UT_GetNearestCreatureByTag( oPC, BDN_CR_GORIM );


                //--------------------------------------------------------------

                if (WR_GetPlotFlag(PLT_BDNPT_MAIN, BDN_MAIN_PLOT__START_TUTORIALS) == TRUE)
                {
                    // Hire Gorim
                    UT_HireFollower(oGorim);
                }


                break;

            }


            case BDN_MAIN___PLOT_02_GET_TRIAN:
            {

                //--------------------------------------------------------------
                // PLOT:    If the player has been to the Proving, Trian will
                //          appear in the royal estate. If the player has not
                //          been to the Proving, Trian will be there instead.
                //--------------------------------------------------------------

                int bBeenToProving = WR_GetPlotFlag( PLT_BDNPT_GENERIC, BDN_GEN_ENTERED_AREA_PROVING );

                object oBhelen = UT_GetNearestCreatureByTag( oPC, BDN_CR_BHELEN );
                object oTrian  = UT_GetNearestCreatureByTag( oPC, BDN_CR_TRIAN );
                object oEndrin = UT_GetNearestCreatureByTag( oPC, BDN_CR_KING );

                if ( bBeenToProving )
                {
                    WR_SetPlotFlag( PLT_BDNPT_GENERIC, BDN_GEN_TRIAN_IS_IN_ROYAL_ESTATE, TRUE );
                    WR_SetObjectActive( oBhelen, TRUE );
                    WR_SetObjectActive( oTrian, TRUE );
                    //open Trian's door
                    object oDoor = GetObjectByTag("bdn120ip_door_trian");
                    SetPlaceableState(oDoor, PLC_STATE_DOOR_UNLOCKED);
                }

                // The presentation to the Nobles is now over.
                WR_SetPlotFlag( PLT_BDNPT_GENERIC, BDN_GEN_PRESENTATION_TO_NOBLES_OVER, TRUE, TRUE );

                //Add codex entries
                WR_SetPlotFlag(PLT_COD_CHA_ENDRIN, COD_CHA_ENDRIN_MAIN, TRUE);
                WR_SetPlotFlag(PLT_COD_MGC_DARKSPAWN, COD_MGC_DARKSPAWN_DWARF, TRUE);

                //if the PC never accepted Dace's quest - he despawns - otherwise move him back to his spot
                int bDacePlot = WR_GetPlotFlag( PLT_BDN120PT_DACE, BDN_DACE___PLOT_01_ACCEPTED );
                object oDace = UT_GetNearestCreatureByTag( oPC, BDN_CR_RONUS_DACE );
                //Dace moves back to his post
                if ( bDacePlot )
                {
                    UT_QuickMoveObject(oDace, BDN_WP_FEAST_DACE_AFTER_HONOR_POST);
                }
                //or he should be gone
                else
                {
                    WR_SetObjectActive(oDace, FALSE);
                }
                //do an autosave
                
                // Qwinn added, so the King isn't sitting on air after the feast
                Ambient_Stop(oEndrin);

                DoAutoSave();
                break;

            }


            case BDN_MAIN___PLOT_03_COMPLETED_DAY_OVER:
            {

                //--------------------------------------------------------------
                // PLOT:    End of Day, start in Deep Roads Expedition
                //--------------------------------------------------------------

                int         bPCPlotted;
                int         bPlotSet;
                //--------------------------------------------------------------

                bPCPlotted = WR_GetPlotFlag( sPlot, BDN_MAIN_PC_PLOTTED_TO_KILL_TRIAN );
                //Codex entry for Bhelen
                bPlotSet = WR_GetPlotFlag(PLT_COD_CHA_BHELEN, COD_CHA_BHELEN_MAIN_NOBLE);

                //--------------------------------------------------------------


                if ( !bPCPlotted )
                    WR_SetPlotFlag( sPlot, BDN_MAIN_PC_DID_NOT_PLOT_TO_KILL_TRIAN, TRUE );

                UT_DoAreaTransition( BDN_AR_RUINED_TAIG, BDN_WP_RUINED_TAIG_ENTER );

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BDN_1);

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

        }
    }

    return bResult;

}