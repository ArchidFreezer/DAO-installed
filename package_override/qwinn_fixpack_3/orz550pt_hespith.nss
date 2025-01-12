//:://////////////////////////////////////////////
/*
    Paragon of Her Kind
     -> Hespith Plot Script
*/
//:://////////////////////////////////////////////
//:: Created By: Joshua Stiksma
//:: Created On: March 12, 2007
//:://////////////////////////////////////////////

#include "plt_orz550pt_hespith"
#include "orz_constants_h"
#include "orz_functions_h"
#include "wrappers_h"
#include "utility_h"
#include "plot_h"

// Qwinn added
#include "plt_genpt_party_triggers"

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

        object oHespith = GetObjectByTag( ORZ_CR_HESPITH );
        string sWaypoint = "";

        // Check for which flag was set
        switch(nFlag)
        {

            case ORZ_HESPITH_AMBIENT_MODE:
            {
                //--------------------------------------------------------------
                // PLOT:    Hespith is now dead
                // ACTION:  PC one-shots her
                //--------------------------------------------------------------
                object oHespithAmb = GetObjectByTag(ORZ_CR_HESPITH_AMB);

                UT_Talk( oHespith, oHespith, R"orz550_hespith_amb.dlg" );
                UT_LocalJump( oHespithAmb, ORZ_WP_HESPITH_AMBIENT_1, TRUE );

                break;
            }

            case ORZ_HESPITH_KILLED:
            {
                //--------------------------------------------------------------
                // PLOT:    Hespith is now dead
                // ACTION:  PC one-shots her
                //--------------------------------------------------------------
                KillCreature( oHespith );

                break;
            }

            case ORZ_HESPITH_RUNS:
            {
                //--------------------------------------------------------------
                // PLOT:    Player has spoken to hespith
                // ACTION:  Hespith runs off and dissappears.
                //--------------------------------------------------------------
                object  oWaypoint = GetObjectByTag( ORZ_WP_HESPITH_RUN );

                UT_LocalJump(oHespith,ORZ_WP_HESPITH_RUN_FROM,TRUE);
                UT_QuickMoveObject(oHespith,ORZ_WP_HESPITH_RUN,TRUE,FALSE,TRUE,TRUE);
                SetObjectInteractive( oHespith, FALSE );
                
                // Qwinn adapted the following from gentr_party_triggers to restore party_bark 69
                object [] arParty = GetPartyList();
                int nSize = GetArraySize(arParty);
                if(nSize > 1) // not just the player
                { 
                   resource rPartyTriggerDialog = GetLocalResource(GetModule(), PARTY_TRIGGER_DIALOG_FILE);
                   WR_SetPlotFlag(PLT_GENPT_PARTY_TRIGGERS,PARTY_BARK_69_ORZ_HESPITH_RUNS_OFF, TRUE);
                   object oFollower1 = arParty[1]; // first follower - just use to init the dialog - others might actually talk
                   UT_Talk(oFollower1, oPC, rPartyTriggerDialog);
                }
                break;
            }

            case ORZ_HESPITH_DEACTIVATE:
            {
                //--------------------------------------------------------------
                // ACTION:  Move Hespith to next waypoint
                //--------------------------------------------------------------
                object oHespithAmb = GetObjectByTag(ORZ_CR_HESPITH_AMB);
                string sWP ="";

                if (WR_GetPlotFlag(sPlot,ORZ_HESPITH_AMBIENT_BARK_05))
                    sWP = ORZ_WP_HESPITH_AMBIENT_6;
                else if (WR_GetPlotFlag(sPlot,ORZ_HESPITH_AMBIENT_BARK_04))
                    sWP = ORZ_WP_HESPITH_AMBIENT_5;
                else if (WR_GetPlotFlag(sPlot,ORZ_HESPITH_AMBIENT_BARK_03))
                    sWP = ORZ_WP_HESPITH_AMBIENT_4;
                else if (WR_GetPlotFlag(sPlot,ORZ_HESPITH_AMBIENT_BARK_02))
                    sWP = ORZ_WP_HESPITH_AMBIENT_3;
                else if (WR_GetPlotFlag(sPlot,ORZ_HESPITH_AMBIENT_BARK_01))
                    sWP = ORZ_WP_HESPITH_AMBIENT_2;

                if (sWP!="")
                    UT_LocalJump( oHespithAmb, sWP, TRUE );

                break;
            }


            case ORZ_HESPITH_BROODMOTHER_DEFEATED:
            {

                //--------------------------------------------------------------
                // PLOT:    Player has killed the broodmother.
                // ACTION:  Hespith has some more to say.
                //--------------------------------------------------------------

                // Make Hespith visible again.
                WR_SetObjectActive(oHespith,TRUE);
                UT_Talk( oHespith, oPC );

                break;

            }

            //------------------------------------------------------------------
            // ACTION: Hespith jumps near the player and speaks.
            //------------------------------------------------------------------

            case ORZ_HESPITH_AMBIENT_BARK_01: sWaypoint = ORZ_WP_HESPITH_AMBIENT_1; break;
            case ORZ_HESPITH_AMBIENT_BARK_02: sWaypoint = ORZ_WP_HESPITH_AMBIENT_2; break;
            case ORZ_HESPITH_AMBIENT_BARK_03: sWaypoint = ORZ_WP_HESPITH_AMBIENT_3; break;
            case ORZ_HESPITH_AMBIENT_BARK_04: sWaypoint = ORZ_WP_HESPITH_AMBIENT_4; break;
            case ORZ_HESPITH_AMBIENT_BARK_05: sWaypoint = ORZ_WP_HESPITH_AMBIENT_5; break;
            case ORZ_HESPITH_AMBIENT_BARK_06: sWaypoint = ORZ_WP_HESPITH_AMBIENT_6; break;

        }

        if ( sWaypoint != "" )
        {
            object oHespithAmb = GetObjectByTag(ORZ_CR_HESPITH_AMB);
            UT_LocalJump( oHespithAmb, sWaypoint, TRUE );
            UT_Talk( oHespithAmb, oHespithAmb, R"",FALSE );
        }

    }

    //--------------------------------------------------------------------------
    // Conditions -> defined flags only (GET DEFINED)
    //--------------------------------------------------------------------------

    else
    {
    }

    return bResult;

}