//::///////////////////////////////////////////////
//:: Plot Events for Redcliffe
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for arl100pt_siege_prep
*/
//:://////////////////////////////////////////////
//:: Created By: Sheryl
//:: Created On: February 26th, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "campaign_h"
#include "cutscenes_h"

#include "plt_cod_cha_eamon"

#include "plt_genpt_news"
#include "plt_urnpt_main"
#include "plt_arl100pt_siege_prep"
#include "plt_arl100pt_equip_militia"
#include "plt_arl100pt_perth_ready"
#include "plt_arl000pt_contact_eamon"
#include "arl_constants_h"
#include "arl_siege_h"

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
    object oTomas = UT_GetNearestCreatureByTag(oPC,ARL_CR_TOMAS);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!

        switch(nFlag)
        {
        case ARL_SIEGE_PREP_PC_CHANGED_MIND_ABOUT_HELPING:
        {
            WR_SetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_PC_REFUSED_TO_HELP, FALSE, TRUE);
            WR_SetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_PC_AGREED_TO_HELP, TRUE, TRUE);
        }
        break;

        case ARL_SIEGE_PREP_PC_BROUGHT_TO_TEAGAN:
        {
            // ACTION: fade to black, move the player and tomas into the chantry
            // and have Lord Teagan initiate dialogue (on area transition)
               UT_DoAreaTransition(ARL_AR_CHANTRY,ARL_WP_PC_INTRODUCTION);

            // Open Redcliffe Castle as a world map location
            object oCastle = GetObjectByTag(WML_WOW_RED_CASTLE);
            WR_SetWorldMapLocationStatus(oCastle, WM_LOCATION_ACTIVE);

            WR_SetPlotFlag(PLT_COD_CHA_EAMON, COD_CHA_EAMON_SICK, TRUE, TRUE);
        }
        break;

        case ARL_SIEGE_PREP_SIEGE_BEGINS:
        {
            //Set Redcliffe Village as world map enabled.
            object oVillage = GetArea(oPC);
            //Safety check, in case the player is using some kind of debugger.
            if (GetTag(oVillage) == ARL_AR_REDCLIFFE_VILLAGE)
            {
                SetLocalInt(oVillage, AREA_WORLD_MAP_ENABLED, TRUE);
            }

            //Remove now useless plot items.
            UT_RemoveItemFromInventory(ARL_R_IT_STASH);
            UT_RemoveItemFromInventory(ARL_R_IT_BARREL_OF_LAMP_OIL);
            UT_RemoveItemFromInventory(ARL_R_IT_OWEN_STASH_KEY);

            //The battle happens in the night version of the village jump the player there.
            UT_DoAreaTransition(ARL_AR_REDCLIFFE_VILLAGE_NIGHT, ARL_WP_SIEGE_PARTY_START);

            //percentage complete plot tracking
            ACH_TrackPercentageComplete(ACH_FAKE_REDCLIFFE_1a);
        }
        break;

        case ARL_SIEGE_PREP_VILLAGE_ABANDONED:
        {
            //percentage complete plot tracking
            ACH_TrackPercentageComplete(ACH_FAKE_REDCLIFFE_1b);
        }
        break;

        case ARL_SIEGE_PREP_PC_TOLD_TO_SPEAK_TO_MURDOCK_PERTH:
        {
            WR_SetPlotFlag(PLT_ARL100PT_PERTH_READY, ARL_PERTH_READY_PERTH_NOT_READY, TRUE, TRUE);
            WR_SetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_TOLD_TO_TALK_TO_MURDOCK, TRUE, TRUE);

            //For the journal, this flag updated the contact_eamon/The Arl of Redcliffe plot.
            WR_SetPlotFlag(PLT_ARL000PT_CONTACT_EAMON, ARL_CONTACT_EAMON_LEARNED_CASTLE_IS_CLOSED, TRUE, TRUE);
        }
        break;

        case ARL_SIEGE_PREP_AUTOSAVE_START_OF_PLOT:
        {
            if (nOldValue == FALSE)
            {
                DoAutoSave();
            }
        }
        break;


        }

     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case ARL_SIEGE_PREP_CHANGED_MIND_AND_TEAGAN_NOT_COMMENTED:
            {
                //IF ARL_SIEGE_PREP_PC_CHANGED_MIND
                //IF NOT ARL_SIEGE_PREP_TEAGAN_COMMENTED_ON_CHANGED_MIND

                int bChangedMind = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_PC_CHANGED_MIND_ABOUT_HELPING);
                int bCommented = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_TEAGAN_COMMENTED_ON_CHANGED_MIND);

                nResult = (bChangedMind == TRUE) && (bCommented == FALSE);
            }
            break;

            case ARL_SIEGE_PREP_MILITIA_MORALE_HIGH:
            {
                // Militia morale +2 or higher
                int nMorale = Arl_GetMilitiaMorale();

                nResult = (nMorale >= 2);
            }
            break;

            case ARL_SIEGE_PREP_MILITIA_MORALE_LOW:
            {
                // Militia morale -2 or lower
                int nMorale = Arl_GetMilitiaMorale();

                nResult = (nMorale <= -1);
            }
            break;

            case ARL_SIEGE_PREP_KNIGHTS_MORALE_HIGH:
            {
                // Knights’ morale +1 or higher
                /* Qwinn:  Disabled, function causes too much overhead
                int nMorale = Arl_GetKnightsMorale();

                nResult = (nMorale >= 1);
                */
                nResult = WR_GetPlotFlag(PLT_ARL100PT_HOLY_AMULET, ARL_HOLY_AMULET_PERTH_HAS_AMULETS);
            }
            break;

            case ARL_SIEGE_PREP_KNIGHTS_MORALE_LOW:
            {
                // Knights’ morale -1 or lower
                // Qwinn:  Disabled function check, not necessary
                // int nMorale = Arl_GetKnightsMorale();

                //nResult = (nMorale <= -1);

                //Knights can't have low morale.
                nResult = FALSE;
            }
            break;

            case ARL_SIEGE_PREP_READY_FOR_BATTLE:
            {
                // IF ARL_MURDOCK_READY_MURDOCK_READY
                // IF ARL_PERTH_READY_PERTH_READY

                int bMurdockReady = WR_GetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_MURDOCK_READY);
                int bPerthReady = WR_GetPlotFlag(PLT_ARL100PT_PERTH_READY, ARL_PERTH_READY_PERTH_READY);

                nResult = (bMurdockReady == TRUE) && (bPerthReady == TRUE);

            }
            break;

            case ARL_SIEGE_PREP_CAN_ASK_PERTH_ABOUT_URN_IGNORANT:
            {
                int bKnowsUrnQuest = WR_GetPlotFlag(PLT_GENPT_NEWS, NEWS_PC_KNOWS_ABOUT_SEARCH_FOR_URN, TRUE);
                int bHasAshes = WR_GetPlotFlag(PLT_URNPT_MAIN, URN_PLOT_DONE, TRUE);

                nResult = (bKnowsUrnQuest == FALSE) && (bHasAshes == FALSE);
            }
            break;

            case ARL_SIEGE_PREP_CAN_ASK_PERTH_ABOUT_URN_KNOWLEDGEABLE:
            {
                int bKnowsUrnQuest = WR_GetPlotFlag(PLT_GENPT_NEWS, NEWS_PC_KNOWS_ABOUT_SEARCH_FOR_URN, TRUE);
                int bHasAshes = WR_GetPlotFlag(PLT_URNPT_MAIN, URN_PLOT_DONE, TRUE);

                nResult = (bKnowsUrnQuest == TRUE) && (bHasAshes == FALSE);
            }
            break;

        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}