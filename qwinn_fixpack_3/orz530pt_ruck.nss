//:://////////////////////////////////////////////
/*
    Paragon of Her Kind
     -> Ruck Plot Script
*/
//:://////////////////////////////////////////////
//:: Created By: Joshua Stiksma
//:: Created On: March 6, 2007
//:://////////////////////////////////////////////

#include "plt_orz530pt_ruck"
#include "orz_constants_h"
#include "orz_functions_h"
#include "wrappers_h"
#include "utility_h"
#include "plot_h"

#include "sys_ambient_h"
#include "plt_qwinn"    



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


            case ORZ_RUCK_SHOUTS_AT_PC:
            {

                //--------------------------------------------------------------
                // PLOT:    Player has killed the spiders at the center of
                //          Ortan Taig, which causes Ruck to show up.
                // ACTION:  Ruck shows up and initiates Conversation
                //--------------------------------------------------------------

                object oRuck = UT_GetNearestCreatureByTag(oPC,ORZ_CR_RUCK);

                // Activate Ruck
                WR_SetObjectActive(oRuck,TRUE);

                // Have him initiate Conversation
                UT_Talk(oRuck,oPC);

                break;
            }

            case ORZ_RUCK_RUNS_TO_TUNNEL:
            {
                object oRuck = UT_GetNearestCreatureByTag(oPC,ORZ_CR_RUCK);
                SetLocalInt(oRuck,AMBIENT_ANIM_PATTERN,61);
                PlaySoundSet(oRuck,SS_WARCRY,1.0f);
                UT_QuickMoveObject(oRuck,"orz530wp_ruck_tunnel",TRUE);
                break;
            }

            case ORZ_RUCK_PC_HAS_MET:
            {

                //--------------------------------------------------------------
                // PLOT:    Ruck has finished talking to the PC and will
                //          now be at his camp.
                // ACTION:  Ruck runs to his camp
                //--------------------------------------------------------------

                object oRuck = UT_GetNearestCreatureByTag(oPC,ORZ_CR_RUCK);
                UT_LocalJump(oRuck,ORZ_WP_RUCK_MOVETO);
                
                // Qwinn added - give him a more appropriate animation while in his camp - Hespiths
                Ambient_OverrideBehaviour(oRuck,128,-1.0,-1);

                UT_TeamAppears(ORZ_TEAM_RUCK_SPIDER_AMBUSH);

                break;

            }

            case ORZ_RUCK_ATTACKS_PC:
            {

                //--------------------------------------------------------------
                // PLOT:    The player has threatened or angered Ruck.
                // ACTION:  Ruck goes hostile and attacks.
                //--------------------------------------------------------------

                object oRuck = UT_GetNearestCreatureByTag(oPC,ORZ_CR_RUCK);

                UT_CombatStart( oRuck, oPC );

                break;
            }

            case ORZ_RUCK_IS_INTIMIDATED_BY_PC:
            {
               WR_SetPlotFlag(PLT_QWINN,ORZ_FOUND_RUCK_CHECK_QUEST_STATUS,TRUE,TRUE);
               break;
            }
            case ORZ_RUCK_SMITTEN_BY_PC:
            {
               WR_SetPlotFlag(PLT_QWINN,ORZ_FOUND_RUCK_CHECK_QUEST_STATUS,TRUE,TRUE);
               break;
            }
            case ORZ_RUCK_PC_GETS_RUCKS_SWORD:
            {
               UT_AddItemToInventory(R"gen_im_wep_mel_lsw_dwv.uti");
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