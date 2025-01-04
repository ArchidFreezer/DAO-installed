//::///////////////////////////////////////////////
//:: Plot Events for entering Castle Redcliffe
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////

//:://////////////////////////////////////////////
//:: Created By: Sheryl
//:: Created On: Feb 26 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "sys_ambient_h"

#include "arl_constants_h"
#include "arl_functions_h"

#include "plt_cod_cha_isolde"
#include "plt_cod_cha_connor"

#include "plt_arl000pt_contact_eamon"
#include "plt_arl100pt_enter_castle"
#include "plt_arl200pt_remove_demon"
#include "plt_gen00pt_party"

// Qwinn added
#include "plt_genpt_wynne_main"

int StartingConditional()
{
    event eParms = GetCurrentEvent();                // Contains all input parameters
    int nType = GetEventType(eParms);               // GET or SET call
    string strPlot = GetEventString(eParms, 0);         // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);          // The bit flag # being affected
    object oParty = GetEventCreator(eParms);      // The owner of the plot table for this script
    object oConversationOwner = GetEventObject(eParms, 0); // Owner on the conversation, if any
    int nResult = FALSE; // used to return value for DEFINED GET events
    object oPC = GetHero();

    object oJowan = UT_GetNearestCreatureByTag(oPC, ARL_CR_JOWAN);
    object oIsolde = UT_GetNearestCreatureByTag(oPC, ARL_CR_ISOLDE);


    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info


    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
        case ARL_ENTER_CASTLE_ISOLDE_TALKS_AT_MILL:
        {
            // Activate Isolde and her guard and make her talk.
            object oGuard = UT_GetNearestCreatureByTag(oPC, ARL_CR_ISOLDE_GUARD);

            WR_SetObjectActive(oIsolde, TRUE);
            WR_SetObjectActive(oGuard, TRUE);
            UT_Talk(oIsolde, oPC);

            //Update the codex with information on Isolde
            WR_SetPlotFlag(PLT_COD_CHA_ISOLDE, COD_CHA_ISOLDE_MAIN, TRUE, TRUE);
        }
        break;

        case ARL_ENTER_CASTLE_PC_HAS_RING:
        {
              // Give PC the signet ring.

            if (nValue == FALSE)
            {
                UT_RemoveItemFromInventory(ARL_R_IT_SIGNET_RING);
            }
            else
            {
                UT_AddItemToInventory(ARL_R_IT_SIGNET_RING, 1);
            }
        }
        break;

        case ARL_ENTER_CASTLE_TEAGAN_AGREED_TO_FOLLOW_ISOLDE:
        {
            // Teagan wants to talk to the PC in private. Initiate his conversation.
            // Deactivate Isolde's guard.
            object oTeagan = UT_GetNearestCreatureByTag(oPC, ARL_CR_TEAGAN);
            object oGuard = UT_GetNearestCreatureByTag(oPC, ARL_CR_ISOLDE_GUARD);

            WR_SetObjectActive(oGuard, FALSE);
            UT_Talk(oTeagan, oPC);

        }
        break;


        case ARL_ENTER_CASTLE_PC_KILLS_JOWAN:
        {
            //If Jowan is killed by the PC, he is no longer awaiting sentance.
            WR_SetPlotFlag(PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_JOWAN_AWAITS_SENTENCE, FALSE, TRUE);

            //And of course Jowan is dead.
            WR_SetPlotFlag(PLT_ARL100PT_ENTER_CASTLE, ARL_ENTER_CASTLE_JOWAN_DEAD, TRUE, TRUE);

            //PC executes Jowan in dialog, doesn't fight him.
            //UT_TeamGoesHostile(ARL_TEAM_JOWAN, TRUE);
        }
        break;

        case ARL_ENTER_CASTLE_JOWANS_CELL_OPEN:
        {
            object oCell = UT_GetNearestObjectByTag(oPC, ARL_IP_DOOR_JOWAN);
            SetPlaceableState(oCell, PLC_STATE_DOOR_OPEN_2);
        }
        break;

        case ARL_ENTER_CASTLE_PC_BRINGS_JOWAN_TO_HALL:
        {
              WR_SetPlotFlag(PLT_ARL100PT_ENTER_CASTLE, ARL_ENTER_CASTLE_JOWAN_IN_HALL, TRUE, TRUE);
              WR_SetPlotFlag(PLT_ARL100PT_ENTER_CASTLE, ARL_ENTER_CASTLE_JOWAN_BROUGHT_TO_HALL, TRUE, TRUE);
              UT_DoAreaTransition(ARL_AR_CASTLE_MAIN_FLOOR, ARL_WP_CONNOR_CUTSCENE);
        }
        break;

        case ARL_ENTER_CASTLE_TEAGAN_BRINGS_JOWAN_TO_HALL:
        {
              WR_SetPlotFlag(PLT_ARL100PT_ENTER_CASTLE, ARL_ENTER_CASTLE_JOWAN_IN_HALL, TRUE, TRUE);
              WR_SetPlotFlag(PLT_ARL100PT_ENTER_CASTLE, ARL_ENTER_CASTLE_JOWAN_BROUGHT_TO_HALL, TRUE, TRUE);
              WR_SetObjectActive(oJowan, TRUE);
              UT_Talk(oIsolde, oPC);
        }
        break;

        case ARL_ENTER_CASTLE_PC_LEARNS_THAT_CONNOR_IS_RESPONSIBLE:
        {
            // Qwinn added
            if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_PARTY))
                WR_SetPlotFlag(PLT_GENPT_WYNNE_MAIN, WYNNE_MAIN_PRESENT_WHEN_CONNOR_MET,TRUE);
            
            // Make Connor's mind-controlled guards and Teagan attack.
            UT_TeamGoesHostile(ARL_TEAM_CONNOR_HALL, TRUE);

            //Have Isolde hide in a corner and pray.
            UT_QuickMoveObject(oIsolde, ARL_WP_ISOLDE_DURING_FIGHT, TRUE);
            AddCommand(oIsolde, CommandPlayAnimation(650), FALSE, FALSE, COMMAND_ADDBEHAVIOR_DONTCLEAR);


            //For the journal, this flag updated the contact_eamon/The Arl of Redcliffe plot.
            WR_SetPlotFlag(PLT_ARL000PT_CONTACT_EAMON, ARL_CONTACT_EAMON_LEARNED_THAT_DEMON_POSSESSED_SON, TRUE, TRUE);

            WR_SetPlotFlag(PLT_COD_CHA_CONNOR, COD_CHA_CONNOR_MAIN, TRUE, TRUE);

            //percentage complete plot tracking
            ACH_TrackPercentageComplete(ACH_FAKE_BLIGHT_5b);
        }
        break;

        case ARL_ENTER_CASTLE_PERTH_ENTERS_HALL_WITH_PC:
        {
            UT_DoAreaTransition(ARL_AR_CASTLE_MAIN_FLOOR, ARL_WP_CONNOR_CUTSCENE);
        }
        break;

        case ARL_ENTER_CASTLE_PERTH_AT_GATES:
        {
            UT_TeamAppears(ARL_TEAM_KNIGHTS, FALSE);
        }
        break;

        case ARL_ENTER_CASTLE_PERTH_WAITING_AT_GATES:
        {
            UT_QuickMove(ARL_CR_PERTH, ARL_WP_COURTYARD_PERTH, FALSE, FALSE, TRUE);
            UT_QuickMove(ARL_CR_KNIGHT_1, ARL_WP_COURTYARD_KNIGHT1, FALSE, FALSE, TRUE);
            UT_QuickMove(ARL_CR_KNIGHT_2, ARL_WP_COURTYARD_KNIGHT2, FALSE, FALSE, TRUE);
            UT_QuickMove(ARL_CR_KNIGHT_3, ARL_WP_COURTYARD_KNIGHT3, FALSE, FALSE, TRUE);
        }


        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
        case ARL_ENTER_CASTLE_PC_ENTERS_HALL_ALONE:
        {
            // IF GEN_PLAYER_ALONE
            // IF NOT ARL_ENTER_CASTLE_PERTH_ENTERS_HALL_WITH_PC

            int bNoParty = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_PLAYER_ALONE, TRUE);
            int bNoPerth = WR_GetPlotFlag(PLT_ARL100PT_ENTER_CASTLE, ARL_ENTER_CASTLE_PERTH_ENTERS_HALL_WITH_PC);

            nResult = (bNoParty == TRUE) && (bNoPerth == TRUE);

        }
        break;

        case ARL_ENTER_CASTLE_JOWAN_AVAILABLE_TO_INTERJECT:
        {
            // IF ARL_ENTER_CASTLE_JOWAN_FOLLOWS_PC
            // OR
            // IF ARL_ENTER_CASTLE_JOWAN_ON_HIS_OWN

            int bJowanFollows = WR_GetPlotFlag(PLT_ARL100PT_ENTER_CASTLE, ARL_ENTER_CASTLE_JOWAN_FOLLOWS_PC);
            int bJowanAlone = WR_GetPlotFlag(PLT_ARL100PT_ENTER_CASTLE, ARL_ENTER_CASTLE_JOWAN_ON_HIS_OWN);

            nResult = (bJowanFollows == TRUE) || (bJowanAlone == TRUE);

        }
        break;

        case ARL_ENTER_CASTLE_JOWAN_STILL_IN_DUNGEON:
        {

            // IF NOT ARL_ENTER_CASTLE_JOWAN_LEFT_PERMANENTLY
            // AND
            // IF NOT ARL_ENTER_CASTLE_JOWAN_DEAD
            // AND
            // IF NOT ARL_ENTER_CASTLE_JOWAN_ON_HIS_OWN

            int bJowanLeft = WR_GetPlotFlag(PLT_ARL100PT_ENTER_CASTLE, ARL_ENTER_CASTLE_JOWAN_LEFT_PERMANENTLY);
            int bJowanDead = WR_GetPlotFlag(PLT_ARL100PT_ENTER_CASTLE, ARL_ENTER_CASTLE_JOWAN_DEAD);
            int bJowanAlone = WR_GetPlotFlag(PLT_ARL100PT_ENTER_CASTLE, ARL_ENTER_CASTLE_JOWAN_ON_HIS_OWN);

            nResult = (bJowanLeft == FALSE) && (bJowanDead == FALSE) && (bJowanAlone == FALSE);

        }
        break;

        case ARL_ENTER_CASTLE_JOWAN_STILL_IN_CASTLE:
        {

            // IF NOT ARL_ENTER_CASTLE_JOWAN_LEFT_PERMANENTLY
            // AND
            // IF NOT ARL_ENTER_CASTLE_JOWAN_DEAD

            int bJowanLeft = WR_GetPlotFlag(PLT_ARL100PT_ENTER_CASTLE, ARL_ENTER_CASTLE_JOWAN_LEFT_PERMANENTLY);
            int bJowanDead = WR_GetPlotFlag(PLT_ARL100PT_ENTER_CASTLE, ARL_ENTER_CASTLE_JOWAN_DEAD);

            nResult = (bJowanLeft == FALSE) && (bJowanDead == FALSE);

        }
        break;

        }

    }


    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}