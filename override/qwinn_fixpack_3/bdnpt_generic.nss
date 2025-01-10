//==============================================================================
/*

    Dwarf Noble
     -> Generic Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: July 27, 2007
//==============================================================================

#include "plt_bdnpt_generic"

#include "plt_bdn120pt_dace"
#include "plt_cod_cha_bhelen"

#include "bdn_constants_h"

#include "wrappers_h"
#include "utility_h"
#include "plot_h"

// Qwinn added
#include "plt_bdn110pt_provings"

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

            case BDN_GEN_ADD_FRANDLIN_TO_PARTY:
            {

                //--------------------------------------------------------------
                // PLOT: Frandlin joins party
                //--------------------------------------------------------------

                object oFrandlin = UT_GetNearestCreatureByTag(oPC, BDN_CR_FRANDLIN_SCOUT);

                UT_HireFollower(oFrandlin);

                break;

            }

            case BDN_GEN_ADD_SCOUT_TO_PARTY:
            {

                //--------------------------------------------------------------
                // PLOT: Scout joins party
                //--------------------------------------------------------------

                object oScout = UT_GetNearestCreatureByTag(oPC, BDN_CR_SCOUT);

                UT_HireFollower(oScout);

                break;

            }


            case BDN_GEN_ACTIVATE_FRANDLIN_IVO:
            {

                //--------------------------------------------------------------
                // PLOT: Duncan and his men along with Trian and his men leave.
                //--------------------------------------------------------------

                object      oFrandlin;

                //--------------------------------------------------------------

                oFrandlin = UT_GetNearestCreatureByTag( oPC, BDN_CR_FRANDLIN_IVO );

                //--------------------------------------------------------------

                WR_SetObjectActive( oFrandlin, TRUE );

                break;

            }

            case BDN_GEN_DEACTIVATE_BHELEN_AND_TRIAN:
            {

                //--------------------------------------------------------------
                // PLOT: Bhelen and his men leave.
                //--------------------------------------------------------------

                object oBhelen  = UT_GetNearestCreatureByTag( oPC, BDN_CR_BHELEN );
                object oTrian   = UT_GetNearestCreatureByTag( oPC, BDN_CR_TRIAN );

                WR_SetObjectActive( oBhelen, FALSE );
                WR_SetObjectActive( oTrian, FALSE );

                //Add codex entry for Bhelen
                //WR_SetPlotFlag(PLT_COD_CHA_BHELEN, COD_CHA_BHELEN_MAIN_NOBLE, TRUE);
                //WR_SetPlotFlag(PLT_COD_CHA_BHELEN, COD_CHA_BHELEN_QUOTE_NOBLE, TRUE);


                break;

            }


            case BDN_GEN_DEACTIVATE_BHELEN_AND_MEN:
            {

                //--------------------------------------------------------------
                // PLOT: Bhelen and his men leave.
                //--------------------------------------------------------------

                object oBhelen = UT_GetNearestCreatureByTag(oPC, BDN_CR_BHELEN);

                WR_SetObjectActive(oBhelen, FALSE);

                break;

            }


            case BDN_GEN_DEACTIVATE_DUNCAN_AND_TRIAN:
            {

                //--------------------------------------------------------------
                // PLOT: Duncan and his men along with Trian and his men leave.
                //--------------------------------------------------------------

                object oDuncan = UT_GetNearestCreatureByTag(oPC, BDN_CR_DUNCAN);
                object oTrian = UT_GetNearestCreatureByTag(oPC, BDN_CR_TRIAN);

                WR_SetObjectActive(oDuncan, FALSE);
                WR_SetObjectActive(oTrian, FALSE);

                break;

            }


            case BDN_GEN_DEACTIVATE_FRANDLIN_IVO:
            {

                //--------------------------------------------------------------
                // PLOT: Duncan and his men along with Trian and his men leave.
                //--------------------------------------------------------------

                object      oFrandlin;

                //--------------------------------------------------------------

                oFrandlin = UT_GetNearestCreatureByTag( oPC, BDN_CR_FRANDLIN_IVO );

                //--------------------------------------------------------------

                WR_SetObjectActive( oFrandlin, FALSE );

                break;

            }


            case BDN_GEN_DEACTIVATE_FRANDLIN_IVO_AND_PROVING_MASTER:
            {

                //--------------------------------------------------------------
                // PLOT: Frandlin leaves - I don't think the proving master should leave, though
                //--------------------------------------------------------------

                object      oFrandlin;
                object      oProvingMaster;

                //--------------------------------------------------------------

                oFrandlin       = UT_GetNearestCreatureByTag( oPC, BDN_CR_FRANDLIN_IVO );
                //oProvingMaster  = UT_GetNearestCreatureByTag( oPC, BDN_CR_PROVINGS_MASTER );

                //--------------------------------------------------------------

                WR_SetObjectActive( oFrandlin, FALSE );
                //WR_SetObjectActive( oProvingMaster, FALSE );

                break;

            }


            case BDN_GEN_DEACTIVATE_HARROWMONT_AND_MEN:
            {

                //--------------------------------------------------------------
                // PLOT: Harrowmont and his men leave.
                //--------------------------------------------------------------

                object oHarrowmont = UT_GetNearestCreatureByTag(oPC, BDN_CR_HARROWMONT);

                WR_SetObjectActive(oHarrowmont, FALSE);

                break;

            }

            case BDN_GEN_DEACTIVATE_KING_ENDRIN:
            {

                //--------------------------------------------------------------
                // PLOT: King Endrin leaves.
                //--------------------------------------------------------------

                object oEndrin = UT_GetNearestCreatureByTag(oPC, BDN_CR_KING);

                WR_SetObjectActive(oEndrin, FALSE);

                break;

            }

            case BDN_GEN_EXILE_GUARD_GIVES_PLAYER_ITEMS_GOOD:
            {

                //--------------------------------------------------------------
                // PLOT: Player recieves good items
                //--------------------------------------------------------------

                break;

            }

            case BDN_GEN_EXILE_GUARD_GIVES_PLAYER_ITEMS_NORMAL:
            {

                //--------------------------------------------------------------
                // PLOT: Player recieves decent items
                //--------------------------------------------------------------
                object oGuard = UT_GetNearestCreatureByTag(oPC, BDN_CR_GUARD_DEEP_ROADS);
                UT_RemoveItemFromInventory(BDN_IM_PRISON_GUARD_SWORD_R, 1, oGuard);
                UT_RemoveItemFromInventory(BDN_IM_PRISON_GUARD_SHIELD_R, 1, oGuard);

                break;

            }

            case BDN_GEN_JUMP_FROM_PROVING:
            {

                //--------------------------------------------------------------
                // PLOT: Player is escorted to the Noble's Quarter
                //--------------------------------------------------------------

                UT_DoAreaTransition( BDN_AR_NOBLES_QUARTER, BDN_WP_NOBLES_QUARTER_ENTER );

                break;

            }

            case BDN_GEN_JUMP_TO_PROVING:
            {

                //--------------------------------------------------------------
                // PLOT: Player is escorted to the Proving Arena.
                //--------------------------------------------------------------

                if ( GetTag(GetArea(oPC)) == BDN_AR_PROVINGS )
                {
                    // Qwinn added new condition, so escort stage doesn't move player to
                    // top balcony if he's still watching
                    if (WR_GetPlotFlag(PLT_BDN110PT_PROVINGS, BDN_PROVINGS_PC_IS_WATCHING) &&
                        !WR_GetPlotFlag(PLT_BDN110PT_PROVINGS, BDN_PROVINGS_PC_DONE_WATCHING))
                    {
                        UT_LocalJump( oPC, BDN_WP_PROVING_WATCH_PC, TRUE, TRUE, FALSE, TRUE );
                        object oEscort = UT_GetNearestCreatureByTag(oPC, BDN_CR_PROVING_GUARD);
                        UT_LocalJump( oEscort, BDN_WP_PROVING_ESCORT_WATCHING);
                    }
                    else
                        UT_LocalJump( oPC, BDN_WP_PROVING_ENTER, TRUE, TRUE, FALSE, TRUE );
                }
                else
                    UT_DoAreaTransition( BDN_AR_PROVINGS, BDN_WP_PROVING_ENTER );

                break;

            }


            case BDN_GEN_KING_LORDS_BHELEN_ENTER_AFTER_TRIANS_DEATH:
            {
                break;

            }

            case BDN_GEN_PRESENTATION_TO_NOBLES_OVER:
            {

                //--------------------------------------------------------------
                // If the player never accepted Dace's plot by this point,
                // Dace is gone Forever. If player accepted the Dace plot,
                // Lady Helmi will be gone for sure.
                //--------------------------------------------------------------

                int         bAcceptedDacePlot;
                object      oLordDace;
                object      oLadyHelmi;

                //--------------------------------------------------------------

                bAcceptedDacePlot   = WR_GetPlotFlag(PLT_BDN120PT_DACE, BDN_DACE___PLOT_01_ACCEPTED);
                oLordDace           = GetObjectByTag(BDN_CR_RONUS_DACE);
                oLadyHelmi          = GetObjectByTag(BDN_CR_HELMI);

                //--------------------------------------------------------------

                if ( !bAcceptedDacePlot )
                    WR_SetObjectActive(oLordDace, FALSE);

                WR_SetObjectActive(oLadyHelmi, FALSE);

                break;

            }

            case BDN_GEN_RICA_WALKS_IN:
            {

                //--------------------------------------------------------------
                // ACTION:  Rica walks out towards the PC thinking he is Bhelen
                //--------------------------------------------------------------

                object oRica;

                //--------------------------------------------------------------

                oRica = UT_GetNearestCreatureByTag( oPC, BDN_CR_RICA );

                //--------------------------------------------------------------

                UT_QuickMoveObject( oRica, "1",FALSE );

                break;

            }


            case BDN_GEN_RICA_RUNS_AWAY:
            {

                //--------------------------------------------------------------
                // ACTION:  Rica Runs back into Bhelen's Room
                //--------------------------------------------------------------

                object oRica;

                //--------------------------------------------------------------

                oRica = UT_GetNearestCreatureByTag( oPC, BDN_CR_RICA );

                //--------------------------------------------------------------

                UT_QuickMoveObject( oRica, "2",TRUE );

                break;

            }


            case BDN_GEN_RICA_LEAVES:
            {

                //--------------------------------------------------------------
                // ACTION:  Rica Runs back into Bhelen's Room
                //--------------------------------------------------------------

                object oRica;

                //--------------------------------------------------------------

                oRica = UT_GetNearestCreatureByTag( oPC, BDN_CR_RICA );

                //--------------------------------------------------------------

                WR_SetObjectActive( oRica, FALSE );

                break;

            }


            case BDN_GEN_WEAPON_MERCHANT_KILLED:
            {

                //--------------------------------------------------------------
                // PLOT: Frandlin joins party
                //--------------------------------------------------------------

                object oWepMerchant = UT_GetNearestCreatureByTag(oPC, BDN_CR_WEAPON_MERCHANT);

                KillCreature(oWepMerchant);
                break;

            }


            case BDN_GEN_STORE_ARMOR_MERCHANT:
            {

                //--------------------------------------------------------------
                // ACTION:  Open Store
                //--------------------------------------------------------------

                object      oStore;

                //--------------------------------------------------------------

                oStore = UT_GetNearestObjectByTag(oPC,BDN_SR_ARMOR_MERCHANT);

                //--------------------------------------------------------------
                ScaleStoreItems(oStore);
                OpenStore(oStore);

                break;

            }


            case BDN_GEN_STORE_SILK_MERCHANT:
            {

                //--------------------------------------------------------------
                // ACTION:  Open Store
                //--------------------------------------------------------------

                object      oStore;

                //--------------------------------------------------------------

                oStore = UT_GetNearestObjectByTag(oPC,BDN_SR_SILK_MERCHANT);

                //--------------------------------------------------------------
                ScaleStoreItems(oStore);
                OpenStore(oStore);

                break;

            }

            case BDN_GEN_NOBLE_LEAVES:
            {
                object oNoble = UT_GetNearestCreatureByTag(oPC, BDN_CR_LESSER_NOBLE);
                UT_ExitDestroy(oNoble);
                object oSilkMerch = UT_GetNearestCreatureByTag(oPC, "bdn100cr_silk_merchant");
                SetObjectInteractive(oSilkMerch,TRUE);
                object oWeirdNoble = UT_GetNearestCreatureByTag(oPC, "bdn100cr_amb_m_3");
                SetObjectInteractive(oWeirdNoble,TRUE);
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