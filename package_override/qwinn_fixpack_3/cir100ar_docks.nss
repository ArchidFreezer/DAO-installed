//==============================================================================
/*

    Broken Circle
     -> Lake Calenhad docks area.
*/
//------------------------------------------------------------------------------
// Created By: Grant Mackay
// Created On: August 21, 2008
//==============================================================================

#include "wrappers_h"
#include "utility_h"
#include "lit_functions_h"
#include "party_h"

#include "plt_urnpt_talked_to"
#include "plt_urnpt_main"
#include "plt_cir000pt_main"

#include "plt_lite_mabari_dom"
#include "plt_gen00pt_party"
#include "plt_lite_mage_collective"
#include "plt_lite_rogue_witness"
#include "plt_lite_fite_deserters"

#include "plt_genpt_sten_talked"

#include "cir_functions_h"
#include "plt_qwinn"

const int CIR_TEAM_CULTIST_AMBUSH = 1;
const int CIR_TEAM_SCHOLARS       = 2;


void main()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evEvent         = GetCurrentEvent();            // Event
    int     nEventType      = GetEventType(evEvent);        // Event Type
    object  oEventCreator   = GetEventCreator(evEvent);     // Event Creator

    // Standard Variables
    object  oPC             = GetHero();
    object  oParty          = GetParty( oPC );
    int     bEventHandled   = FALSE;

    int     bBrokenCirDone  = WR_GetPlotFlag(PLT_CIR000PT_MAIN, BROKEN_CIRCLE_PLOT_DONE);

    //--------------------------------------------------------------------------
    // Area Events
    //--------------------------------------------------------------------------

    switch ( nEventType )
    {

        //----------------------------------------------------------------------
        // EVENT_TYPE_AREALOAD_PRELOADEXIT:
        // Sent by: The engine
        // When: for things you want to happen while the load screen is
        // still up, things like moving creatures around.
        //----------------------------------------------------------------------
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {

            if( bBrokenCirDone )
            {
                UT_TeamAppears( CIR_TEAM_SCHOLARS );
            }

            if ( WR_GetPlotFlag(PLT_URNPT_TALKED_TO, INNKEEPER_TALKED_ABOUT_CULT) )
            {

                UT_TeamAppears( CIR_TEAM_CULTIST_AMBUSH );

            }

            //Light Content - should the mages' collective bag be active
            if (WR_GetPlotFlag(PLT_LITE_MAGE_COLLECTIVE, MAGE_COLLECTIVE_LEARNED_ABOUT) == TRUE)
            {
                //mage bag is now available
                object oMageBag = UT_GetNearestObjectByTag(oPC, LITE_IP_MAGE_BAG_2);
                SetObjectInteractive(oMageBag, TRUE);
                object oMage = UT_GetNearestCreatureByTag(oPC, "lite_mage_collective");
                //should mage collective dude by marked?
                SetPlotGiver(oMage, MageCollectiveTurnInPossible(oPC));
            }

            //Light Content - should the deserters be present?
            if (WR_GetPlotFlag(PLT_LITE_FITE_DESERTERS, DESERTERS_QUEST_GIVEN) == TRUE )
            {
                UT_TeamAppears( LIT_TEAM_FITE_DESERTERS_1 );
            }


            // Light Content: False Witnesses (Box of Certain Interests)
            WR_SetPlotFlag(PLT_LITE_ROGUE_WITNESS,WITNESS_PLOT_SETUP,TRUE,TRUE);


            // Scavenger and bodies
            // Only appear if scavenger Sten's quest is active

            object oScavenger = GetObjectByTag("cir100cr_scavenger");
            object oBody_A = GetObjectByTag("body_a");
            object oBody_B = GetObjectByTag("body_b");
            object oBody_C = GetObjectByTag("body_c");
            object oBody_D = GetObjectByTag("body_d");
            object oBody_E = GetObjectByTag("body_e");
            object oBody_F = GetObjectByTag("body_f");
            object oBody_G = GetObjectByTag("body_g");

            int bLostSword = WR_GetPlotFlag(PLT_GENPT_STEN_TALKED, STEN_TALKED_ABOUT_LOST_SWORD);
            int bKnowsFaryn = WR_GetPlotFlag(PLT_GENPT_STEN_TALKED, STEN_TALKED_KNOWS_ABOUT_FARYN);

            if (bLostSword && !bKnowsFaryn)
            {
                WR_SetObjectActive(oScavenger, TRUE);
                WR_SetObjectActive(oBody_A, TRUE);
                WR_SetObjectActive(oBody_B, TRUE);
                WR_SetObjectActive(oBody_C, TRUE);
                WR_SetObjectActive(oBody_D, TRUE);
                WR_SetObjectActive(oBody_E, TRUE);
                WR_SetObjectActive(oBody_F, TRUE);
                WR_SetObjectActive(oBody_G, TRUE);
            } else
            {
                WR_SetObjectActive(oScavenger, FALSE);
                WR_SetObjectActive(oBody_A, FALSE);
                WR_SetObjectActive(oBody_B, FALSE);
                WR_SetObjectActive(oBody_C, FALSE);
                WR_SetObjectActive(oBody_D, FALSE);
                WR_SetObjectActive(oBody_E, FALSE);
                WR_SetObjectActive(oBody_F, FALSE);
                WR_SetObjectActive(oBody_G, FALSE);
            }

            break;

        }

        //----------------------------------------------------------------------
        // Sent by: The engine
        // When: all game objects in the area have loaded
        //----------------------------------------------------------------------
        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {
            //See if we've moved to post plot
            CIR_CheckAndSetPostPlot();
            //Check for Mabari Dominance
            if (WR_GetPlotFlag(PLT_LITE_MABARI_DOM, MABARI_DOM_CIRCLE_DOCKS) == TRUE)
            {
                //if dog is in the party -
                int nDog = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY);
                if (nDog == TRUE)
                {
                    object oDog = Party_GetFollowerByTag("gen00fl_dog");
                    //if this flag has been set - activate the bonus and show the message
                    UI_DisplayMessage(oDog, 4010);

                    //Activate Bonus here
                    effect eDog = EffectMabariDominance();
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eDog, oDog, 0.0f, oDog, 200261);
                }
            }

            if(WR_GetPlotFlag(PLT_CIR000PT_MAIN, POST_PLOT) == TRUE)
            {
                object oCarroll = GetObjectByTag(CIR_CR_CARROLL);
                object oKester = GetObjectByTag(CIR_CR_KESTER);
                object oKesterPostPlot = GetObjectByTag(CIR_CR_KESTER_POST_PLOT);

                //Set carroll to inactive
                SetObjectActive(oCarroll, FALSE);
                //Move kester
                SetObjectActive(oKester, FALSE);
                SetObjectActive(oKesterPostPlot, TRUE);

                //Set memorial templar active
                // Qwinn:  Put condition so he doesn't respawn in the wrong place
                object oMemorial = GetObjectByTag(CIR_CR_MEMORIAL_TEMPLAR);
                // WR_SetObjectActive(oMemorial, TRUE);
                WR_SetObjectActive(oMemorial, !WR_GetPlotFlag(PLT_CIR000PT_MAIN,POST_MEMORIAL_TEMPLAR_FINISHES));
                // Qwinn:  Added to prevent him from dropping his equipment if killed by friendly fire.
                SetLocalInt(oMemorial,"TS_OVERRIDE_EQUIPMENT",-1);
            }

            break;
        }


        //----------------------------------------------------------------------
        // EVENT_TYPE_TEAM_DESTROYED:
        // Sent by: The engine
        // When: A creature's entire team dies
        //----------------------------------------------------------------------
        case EVENT_TYPE_TEAM_DESTROYED:
        {

            int nTeamID = GetEventInteger( evEvent, 0 );

            switch ( nTeamID )
            {
                case CIR_TEAM_CULTIST_AMBUSH:
                {   /* Qwinn

                    int bWeylonDead = WR_GetPlotFlag( PLT_URNPT_MAIN, WEYLON_DEAD );

                    if ( !bWeylonDead )
                        WR_SetPlotFlag( PLT_URNPT_MAIN, PC_AMBUSHED_AT_PRINCESS, TRUE );
                    */
                    WR_SetPlotFlag( PLT_QWINN, URN_INN_PC_AMBUSHED_CHECK_JOURNAL_STATE,TRUE,TRUE);

                    break;

                }

            }

            break;

        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature exits the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_EXIT:
        {

            //if dog is in the party -
            int nDog = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY);
            if (nDog == TRUE)
            {
                object oDog = Party_GetFollowerByTag("gen00fl_dog");
                //DeActivate Bonus here
                RemoveEffectsByParameters(oDog, EFFECT_TYPE_INVALID, 200261);
            }

            break;
        }
    }

    //--------------------------------------------------------------------------
    // Pass any unhandled events to area_core
    //--------------------------------------------------------------------------

    if ( !bEventHandled )
        HandleEvent( evEvent, RESOURCE_SCRIPT_AREA_CORE );

}