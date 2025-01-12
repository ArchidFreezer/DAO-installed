//==============================================================================
/*

    Dwarf Noble
     -> Provings Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: July 26, 2007
//==============================================================================

#include "plt_bdn110pt_provings"
#include "plt_bdn120pt_dace"
#include "plt_bdnpt_main"

#include "sys_audio_h"

#include "bdn_constants_h"

#include "wrappers_h"
#include "utility_h"
#include "plot_h"
#include "proving_h"
#include "plt_bdnpt_events"
#include "tutorials_h"

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

            case BDN_PROVINGS_AUTOSAVE:
            {
                //do an autosave when first entering the area
                DoAutoSave();
                //show equipment tutorial
                WR_SetPlotFlag(PLT_BDNPT_EVENTS, BDN_EVENT_SHOW_EQUIPMENT_TUTORIAL, TRUE);
                BeginTrainingMode(TRAINING_SESSION_EQUIPMENT);

                break;
            }

            case BDN_PROVINGS_HONOR_RES_MANDAR_DACE:
            {

                //--------------------------------------------------------------
                // PLOT:    Mandar shouldn't die permanently here.
                //--------------------------------------------------------------

                object oMandar = UT_GetNearestCreatureByTag( oPC, BDN_CR_MANDAR_DACE );
                effect effRes = EffectResurrection();

                UT_CombatStop( oMandar, oPC );
                ApplyEffectOnObject( EFFECT_DURATION_TYPE_INSTANT, effRes, oMandar );

                break;

            }


            case BDN_PROVINGS_PC_IS_WATCHING:
            {

                //--------------------------------------------------------------
                // PLOT:    The player has agreed to watch the Proving, and not
                //          fight in it.
                //--------------------------------------------------------------

                object      oProvMaster;
                object      oProvTrainer;
                object      oBlackstone;
                object      oFrandlin;
                object      oEscort;

                //--------------------------------------------------------------

                oProvMaster  = UT_GetNearestCreatureByTag( oPC, BDN_CR_PROVINGS_MASTER );
                oProvTrainer = UT_GetNearestCreatureByTag( oPC, BDN_CR_PROVINGS_TRAINER );
                oBlackstone  = UT_GetNearestCreatureByTag( oPC, BDN_CR_BLACKSTONE );
                oFrandlin    = UT_GetNearestCreatureByTag( oPC, BDN_CR_FRANDLIN_IVO );
                oEscort      = UT_GetNearestCreatureByTag(oPC, BDN_CR_PROVING_GUARD);

                //--------------------------------------------------------------

                // Set plot so they don't die
                SetPlot(oBlackstone,TRUE);
                SetPlot(oFrandlin,TRUE);

                //Activate the opponents
                WR_SetObjectActive(oFrandlin,TRUE);
                WR_SetObjectActive(oBlackstone,TRUE);

                //jump everyone into place
                // Qwinn:  added TTFT on next line so Gorim moves too
                UT_LocalJump( oPC, BDN_WP_PROVING_WATCH_PC, TRUE, TRUE, FALSE, TRUE );
                UT_LocalJump( oProvMaster, BDN_WP_PROVING_WATCH_PROVMASTER);
                UT_LocalJump( oBlackstone, PROVING_WP_PC_ENTER);
                UT_LocalJump( oFrandlin, PROVING_WP_OPPONENT_ENTER_PREFIX+"00");
                UT_LocalJump( oEscort, BDN_WP_PROVING_ESCORT_WATCHING);


                //start them fighting each other
                SetGroupHostility(BDN_GROUP_PROVINGS_1, BDN_GROUP_PROVINGS_2, TRUE);
                UT_CombatStart(oBlackstone,oFrandlin);

                // PC can now talk to the proving trainer
                WR_SetObjectActive( oProvTrainer, TRUE );

                //update journal that the provings are done as far as he's concerned
                WR_SetPlotFlag(PLT_BDNPT_MAIN, BDN_MAIN___PLOT_02_COMPLETED_PROVINGS, TRUE);

                //Turn on the crowd sounds
                AudioTriggerPlotEvent(29);

                break;

            }

            case BDN_PROVINGS_PC_DONE_WATCHING:
            {

                //--------------------------------------------------------------
                // PLOT:    The player is done watching the Proving Match
                //--------------------------------------------------------------

                object      oProvMaster;
                object      oProvTrainer;
                object      oBlackstone;
                object      oFrandlin;

                //--------------------------------------------------------------

                oProvMaster  = UT_GetNearestCreatureByTag( oPC, BDN_CR_PROVINGS_MASTER );
                oProvTrainer = UT_GetNearestCreatureByTag( oPC, BDN_CR_PROVINGS_TRAINER );
                oBlackstone  = UT_GetNearestCreatureByTag( oPC, BDN_CR_BLACKSTONE );
                oFrandlin    = UT_GetNearestCreatureByTag( oPC, BDN_CR_FRANDLIN_IVO );

                //--------------------------------------------------------------

                UT_LocalJump( oProvMaster, BDN_WP_PROVMASTER );
                // Qwinn added
                UT_LocalJump( oPC, BDN_WP_PROVING_ENTER, TRUE, TRUE, FALSE, TRUE );
                object oEscort = UT_GetNearestCreatureByTag(oPC, BDN_CR_PROVING_GUARD);
                UT_LocalJump( oEscort, BDN_WP_PROVING_ESCORT_POST );

                WR_SetObjectActive( oProvTrainer, FALSE );

                WR_SetObjectActive(oFrandlin,FALSE);
                WR_SetObjectActive(oBlackstone,FALSE);
                UT_CombatStop(oBlackstone,oFrandlin);

                // Set that Provings are now over.
                WR_SetPlotFlag( sPlot, BDN_PROVINGS_DONE, TRUE );

                break;

            }

            case BDN_PROVINGS_HONOR_INIT:
            {

                //--------------------------------------------------------------
                // PLOT:    Lord Bemot, Lord Meino, Lord Harrowmount, King
                //          Endrin and Lord Dace are moved to the Proving
                //          Grounds.
                //          The player appears in the center of the proving
                //          grounds next to Mandar Dace.
                //--------------------------------------------------------------
                // Transition PC to provings. Area on-enter script will activate
                // the npc's and start the dialogue.
                //--------------------------------------------------------------

                UT_DoAreaTransition( BDN_AR_PROVINGS, PROVING_WP_PC_ENTER );

                break;

            }

            case BDN_PROVINGS_HONOR_PC_LOST:
            {

                //--------------------------------------------------------------
                // BDN_PROVINGS_HONOR_PC_LOST:
                //--------------------------------------------------------------

                WR_SetPlotFlag(PLT_BDN120PT_DACE,BDN_DACE___PLOT_02_PC_LOST_MATCH,TRUE,TRUE);

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


            case BDN_PROVINGS_HONOR_DONE:
            {

                //--------------------------------------------------------------
                // COND: Player has finished the Honor Proving in some fasion
                //--------------------------------------------------------------

                int bHonorWon  = WR_GetPlotFlag( sPlot, BDN_PROVINGS_HONOR_PC_WON );
                int bHonorLost = WR_GetPlotFlag( sPlot, BDN_PROVINGS_HONOR_PC_LOST );

                if ( bHonorWon || bHonorLost )
                    bResult = TRUE;

                break;

            }


            case BDN_PROVINGS_ACTIVE:
            {

                //--------------------------------------------------------------
                // COND: Player has finished the Honor Proving in some fasion
                //--------------------------------------------------------------

                int bPCJoined     = WR_GetPlotFlag( sPlot, BDN_PROVINGS_PC_JOINED_PROVING );
                int bProvingsDone = WR_GetPlotFlag( sPlot, BDN_PROVINGS_DONE );

                if ( bPCJoined && !bProvingsDone )
                    bResult = TRUE;

                break;
            }

            case BDN_PROVINGS_FIGHTING_HELMI:
            {
                //--------------------------------------------------------------
                // COND: Player is fighting Adal Helmi in round 2 of the provings
                //      needed for dialog gender checks
                //--------------------------------------------------------------

                int bFinishedRound1 = WR_GetPlotFlag(sPlot, BDN_PROVINGS_PC_WON_ROUND_1);
                int bFinishedRound2 = WR_GetPlotFlag(sPlot, BDN_PROVINGS_PC_WON_ROUND_2);

                if ( bFinishedRound1 == TRUE && bFinishedRound2 == FALSE )
                    bResult = TRUE;

                break;

            }

        }
    }

    return bResult;

}