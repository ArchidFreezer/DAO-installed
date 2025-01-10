//==============================================================================
/*

    Dwarf Noble
     -> Betrayal Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: November 9, 2007
//==============================================================================

#include "plt_bdn300pt_betrayal"
#include "plt_bdnpt_main"
#include "plt_bdnpt_generic"
#include "plt_bdn120pt_gorim"
#include "plt_bdn100pt_trian"
#include "plt_bdn120pt_dace"
#include "plt_bdn100pt_scholar"
#include "plt_bdn110pt_provings"

#include "bdn_constants_h"

#include "plt_mnp00pt_ssf_dwarf_noble"
#include "plt_cod_cha_duncan"
#include "plt_cod_mgc_dwarf_blight"
#include "plt_cod_hst_wardens"
#include "plt_cod_cha_bhelen"

#include "sys_achievements_h"
#include "cutscenes_h"
#include "wrappers_h"
#include "utility_h"
#include "plot_h"

#include "achievement_core_h"

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


            case BDN_BETRAYAL___PLOT_01_ACCEPTED_IN_PRISON:
            {

                //--------------------------------------------------------------
                // PLOT:    PC is in Prison
                //--------------------------------------------------------------

                // Update Story-So-Far
                WR_SetPlotFlag( PLT_MNP00PT_SSF_DWARF_NOBLE, SSF_BDN_03_PRISON, TRUE );
                //update code

                WR_SetPlotFlag(PLT_COD_CHA_BHELEN, COD_CHA_BHELEN_QUOTE_NOBLE, TRUE);
                WR_SetPlotFlag(PLT_COD_CHA_BHELEN, COD_CHA_BHELEN_MAIN_NOBLE, TRUE);

                if (WR_GetPlotFlag(PLT_BDNPT_MAIN, BDN_MAIN_PC_PLOTTED_TO_KILL_TRIAN) == FALSE)
                {
                    WR_SetPlotFlag(PLT_COD_CHA_BHELEN, COD_CHA_BHELEN_NOBLE_FRAMED, TRUE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_COD_CHA_BHELEN, COD_CHA_BHELEN_NOBLE_TRICKED, TRUE);
                }



                break;

            }


            case BDN_BETRAYAL___PLOT_02_EXILED:
            {

                //--------------------------------------------------------------
                // PLOT:    Player has been sent to exile from the Orzammar
                //          Prison.
                //--------------------------------------------------------------

                // Update Story-So-Far
                WR_SetPlotFlag( PLT_MNP00PT_SSF_DWARF_NOBLE, SSF_BDN_04_EXILE, TRUE );

                UT_DoAreaTransition( BDN_AR_DEEP_ROADS, BDN_WP_DEEP_ROADS_START );

                //DoAutoSave();

                break;
            }


            case BDN_BETRAYAL___PLOT_03_COMPLETED_MOVE_TO_PRELUDE:
            {

                //--------------------------------------------------------------
                // PLOT:    Player completed the Dwarven Noble Plot, move him
                //          to the Prelude.
                // ACTION:  If requirements met, grant Achievement
                //          (A History Of Violence::22)
                //--------------------------------------------------------------

                int         bPCPlotted;         // PC plotted to kill Trian (second dialog with Trian/Bhelen)
                int         bKilledScholar;     // Lord Vollney killed the Scholar in the Noble's Quarter
                int         bProvingsWon;       // PC defeated all opponents in the Proving
                int         bMerchantKilled;    // PC killed the weapon merchant in the Noble's Quarter
                int         bMandarKilled;      // PC challenged Ronus Dace to honor proving, killed Mandar
                int         bCodexEntries;       // Check if the PC has received any of the Duncan codex entries

                //--------------------------------------------------------------

                bPCPlotted      = WR_GetPlotFlag( PLT_BDNPT_MAIN, BDN_MAIN_PC_PLOTTED_TO_KILL_TRIAN );
                bKilledScholar  = WR_GetPlotFlag( PLT_BDN100PT_SCHOLAR, BDN_SCHOLAR_KILLED );
                bProvingsWon    = WR_GetPlotFlag( PLT_BDN110PT_PROVINGS, BDN_PROVINGS_PC_IS_CHAMPION );
                bMerchantKilled = WR_GetPlotFlag( PLT_BDNPT_GENERIC, BDN_GEN_WEAPON_MERCHANT_KILLED );
                bMandarKilled   = WR_GetPlotFlag( PLT_BDN110PT_PROVINGS, BDN_PROVINGS_HONOR_PC_KILLED_MANDAR );
                bCodexEntries   = WR_GetPlotFlag( PLT_COD_CHA_DUNCAN, COD_CHA_DUNCAN_MAIN );

                //--------------------------------------------------------------

                if ( bPCPlotted && bKilledScholar && bProvingsWon && bMerchantKilled && bMandarKilled )
                {
                    // Grant Achievement: A History Of Violence
                    Acv_Grant(22);
                }

                // Grant achievement: dwarf noble completed
                WR_UnlockAchievement(ACH_ADVANCE_KINSLAYER);
                // If the Player hasn't died, grant achievement: Bloodied
                ACH_CheckForSurvivalAchievement(ACH_FEAT_BLOODIED);


                //Add Grey wardens codex entries if not received yet
                if ( !bCodexEntries )
                {
                    WR_SetPlotFlag(PLT_COD_CHA_DUNCAN, COD_CHA_DUNCAN_MAIN, TRUE);
                    WR_SetPlotFlag(PLT_COD_MGC_DWARF_BLIGHT, COD_MGC_DWARF_BLIGHT, TRUE);
                    WR_SetPlotFlag(PLT_COD_HST_WARDENS, COD_HST_WARDENS, TRUE);
                }


                UT_DoAreaTransition( PRE_AR_KINGS_CAMP, PRE_WP_START );

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BDN_3);

                break;
            }


            case BDN_BETRAYAL__CUTSCENE_EXILE:
            {

                //--------------------------------------------------------------
                // CUTSCENE:    Player is exiled
                //--------------------------------------------------------------

                int         nIndex;
                int         nArraySize;
                object      oCurrent;
                object []   arInventoryList;

                //--------------------------------------------------------------

                arInventoryList = GetItemsInInventory(oPC,GET_ITEMS_OPTION_BACKPACK);

                //--------------------------------------------------------------

                // Equip all items in inventory
                nArraySize = GetArraySize(arInventoryList);
                for ( nIndex = 0; nIndex < nArraySize; nIndex++ )
                {
                    oCurrent = arInventoryList[nIndex];
                    string sItem = GetTag(oCurrent);
                    string sItemPre = StringLeft(sItem, 3);

                    if(sItemPre != "prc" &&
                       sItemPre != "prm" &&
                       sItem != "gen_im_acc_rng_exp" &&
                       sItem != "gen_im_qck_book_skill" &&
                       sItem != "gen_im_qck_book_attribute3")                    
                      EquipItem(oPC,oCurrent);
                }

                // Load cutscene
                CS_LoadCutscene(CUTSCENE_BDN_EXILED,sPlot,BDN_BETRAYAL__CUTSCENE_EXILE_END);

                break;

            }


            case BDN_BETRAYAL__CUTSCENE_EXILE_END:
            {

                //--------------------------------------------------------------
                // CUTSCENE:    Player is exiled
                // ACTION:      Move player to other side of exile door
                //--------------------------------------------------------------

                object      oHarrowmont;
                object      oGuard;
                object      oDoor;

                //--------------------------------------------------------------

                oHarrowmont     = UT_GetNearestCreatureByTag(oPC, BDN_CR_HARROWMONT);
                oGuard          = UT_GetNearestCreatureByTag(oPC, BDN_CR_GUARD_DEEP_ROADS);
                oDoor           = UT_GetNearestObjectByTag(oPC, BDN_IP_EXILE_DOORS);
                //--------------------------------------------------------------


                //Make sure the doors are shut after the cutscene
                SetPlaceableState(oDoor, PLC_STATE_DOOR_LOCKED);

                // Remove Harrowmont and Guard
                WR_DestroyObject(oHarrowmont);
                WR_DestroyObject(oGuard);

                // Jump PC to other side of wall with cutscene ending
                UT_LocalJump(oPC,BDN_WP_AFTER_EXILE);
                DoAutoSave();

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