//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events
*/
//:://////////////////////////////////////////////
//:: Created By: Yaron
//:: Created On: July 21st, 2006
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "wrd_constants_h"
#include "ran_constants_h"
#include "stealing_h"
#include "plt_lite_fite_leadership"
#include "plt_ranpt_generic_actions"
#include "plt_lite_mage_renold"
#include "plt_lite_mage_witnesses"


int RAN_TemplarBribe(int iLevel);
int RAN_TemplarBribe(int iLevel)
{
    if (iLevel <= 3)
        return 25;
    else if (iLevel <= 5)
        return 50;
    else if (iLevel <= 7)
        return 100;
    else if (iLevel <= 9)
        return 200;
    else if (iLevel <= 11)
        return 400;
    else if (iLevel <= 13)
        return 600;
    else if (iLevel <= 15)
        return 800;
    else if (iLevel <= 20)
        return 1000;
    else
        return 0;
}

int RAN_GetBribeAtLevels(int nMin, int nMax);
int RAN_GetBribeAtLevels(int nMin, int nMax)
{
    object oPC = GetHero();
    int iLevel = GetLevel(oPC);                // What level the player is

    // PC has enough money for the appropriate level, also doesn't return zero
    if (((UT_MoneyCheck(oPC, 0, RAN_TemplarBribe(iLevel))) && (RAN_TemplarBribe(iLevel) != FALSE))
    && ((iLevel > nMin) && (iLevel <= nMax)))
        return TRUE;
    else
        return FALSE;
}




int StartingConditional()
{
    event       eParms              = GetCurrentEvent();            // Contains all input parameters
    int         nType               = GetEventType(eParms);         // GET or SET call
    string      strPlot             = GetEventString(eParms, 0);    // Plot GUID
    int         nFlag               = GetEventInteger(eParms, 1);   // The bit flag # being affected
    object      oParty              = GetEventCreator(eParms);      // The owner of the plot table for this script
    object      oConversationOwner  = GetEventObject(eParms, 0);    // Owner on the conversation, if any
    int         nResult             = FALSE;                        // used to return value for DEFINED GET events

    object      oPC                 = GetHero();
    object      oModule             = GetModule(); //Reference to the module
    object      oPeasant            = GetObjectByTag(RAN_CR_950_PEASANT);
    object      oKentPa             = GetObjectByTag(RAN_KENT_PA);
    object      oKentMa             = GetObjectByTag(RAN_KENT_MA);

    // Stealing counter is how much the player tried but FAILED
    // to steal things
    int         iCantPay            = FALSE;                        // Flag for "Can't Pay"
    int         iLevel              = GetLevel(oPC);                // What level the player is


    object oBannorn_Commander = GetObjectByTag(RAN_BANNORN_COMMANDER);
    object oBannorn_A = GetObjectByTag(RAN_BANNORN_TROOP_A);
    object oBannorn_B = GetObjectByTag(RAN_BANNORN_TROOP_B);
    object oBannorn_C = GetObjectByTag(RAN_BANNORN_TROOP_C);
    object oBannorn_D = GetObjectByTag(RAN_BANNORN_TROOP_D);
    object oBannorn_E = GetObjectByTag(RAN_BANNORN_TROOP_E);

    object oLoghain_Commander = GetObjectByTag(RAN_LOGHAIN_COMMANDER);
    object oLoghain_A = GetObjectByTag(RAN_LOGHAIN_TROOP_A);
    object oLoghain_B = GetObjectByTag(RAN_LOGHAIN_TROOP_B);
    object oLoghain_C = GetObjectByTag(RAN_LOGHAIN_TROOP_C);
    object oLoghain_D = GetObjectByTag(RAN_LOGHAIN_TROOP_D);
    object oLoghain_E = GetObjectByTag(RAN_LOGHAIN_TROOP_E);


    plot_GlobalPlotHandler(eParms);                     // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT)                    // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case RAN_ACTIONS_MAGES_DARKSPAWN_APPEAR:
            {
                UT_TeamAppears(RAN_TEAM_MAGES_DARKSPAWN, TRUE);
                break;
            }
            case RAN_ACTIONS_ADVENTURERS_LEAVE:
            {
                UT_TeamAppears(WRD_TEAM_FENNON_DOWN, FALSE);
                break;
            }
            case RAN_ACTIONS_ORZ_GUARDS_ATTACK:
            {
                // guards attack player for stealing
                UT_TeamGoesHostile(RAN_TEAM_ORZ_GUARDS);
                break;
            }
            case RAN_ACTIONS_ORZ_GUARDS_LEAVE:
            {
                //guards leave the area
                UT_TeamAppears(RAN_TEAM_ORZ_GUARDS,FALSE);
                break;
            }
            case RAN_ACTIONS_ORZ_GUARDS_BRIBED:
            {
                // PC agrees to bribe guards to get off the hook
                UT_MoneyTakeFromObject(oPC,0,0,30);
                break;
            }
            case RAN_ACTIONS_TEMPLARS_PAID:
            {
                // PC agrees to pay the money, find out how much money is owed
                UT_MoneyTakeFromObject(oPC,0,RAN_TemplarBribe(iLevel));
                break;
            }
            case RAN_ACTIONS_TEMPLARS_LEAVE:
            {
                 //templars leave the area
                UT_TeamAppears(RAN_TEAM_TEMPLARS,FALSE);
                break;
            }
            case RAN_ACTIONS_TEMPLARS_ATTACK:
            {
                 //templars attack
                UT_TeamGoesHostile(RAN_TEAM_TEMPLARS);
                break;
            }
            case RAN_ACTIONS_BANNORN_LOGHAIN_FIGHT:
            {
                 //templars attack

                 // Each member picks an equivalent member to fight
                UT_TeamGoesHostile(GetTeamId(oConversationOwner));
                UT_CombatStart(oLoghain_Commander, oBannorn_Commander, TRUE, TRUE);
                UT_CombatStart(oLoghain_A, oBannorn_A, TRUE, TRUE);
                UT_CombatStart(oLoghain_B, oBannorn_B, TRUE, TRUE);
                UT_CombatStart(oLoghain_C, oBannorn_C, TRUE, TRUE);
                UT_CombatStart(oLoghain_D, oBannorn_D, TRUE, TRUE);
                UT_CombatStart(oLoghain_E, oBannorn_E, TRUE, TRUE);


                // Make sure other member attacks partner
                UT_CombatStart(oBannorn_Commander, oLoghain_Commander, TRUE, TRUE);
                UT_CombatStart(oBannorn_A, oLoghain_A, TRUE, TRUE);
                UT_CombatStart(oBannorn_B, oLoghain_B, TRUE, TRUE);
                UT_CombatStart(oBannorn_C, oLoghain_C, TRUE, TRUE);
                UT_CombatStart(oBannorn_D, oLoghain_D, TRUE, TRUE);
                UT_CombatStart(oBannorn_E, oLoghain_E, TRUE, TRUE);

                break;
            }
            case RAN_ACTIONS_PULLED_AXE:
            {
                 // Peasants speak to player
                UT_Talk(oPeasant, oPC);
                break;
            }

            case RAN_ACTIONS_KENTS_LEAVE:
            {
                 // Kents go to disappear
                SetObjectActive(oKentPa, FALSE);
                SetObjectActive(oKentMa, FALSE);
                break;
            }

            case RAN_270_ATTACK_SETUP:
            {
                 // Teleport party to waypoint
                UT_LocalJump(oPC, RAN_WP_270_COMBATSTART, TRUE, TRUE, FALSE, TRUE);
                UT_TeamGoesHostile(RAN_TEAM_RAN270_BANDITS, TRUE);
                break;
            }
            case RAN_120_CARAVAN_ATTACKS:
            {
                // guards attack player for stealing
                UT_TeamGoesHostile(RAN_TEAM_120_CARAVAN);
                break;
            }


        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {

            // This condition drops through all the others to see if any
            // were possible.
           case RAN_TEMPLAR_OWES_CANT_PAY:
           {
                if (UT_MoneyCheck(oPC, 0, RAN_TemplarBribe(iLevel)) == FALSE)
                  nResult = TRUE;
                break;
           }
           case RAN_TEMPLAR_OWES_30:  // Owes 25 silver
           {
                nResult = RAN_GetBribeAtLevels(0, 3);
                break;
           }
           case RAN_TEMPLAR_OWES_40:  // Owes 50 silver
           {
                nResult = RAN_GetBribeAtLevels(3, 5);
                break;
           }
           case RAN_TEMPLAR_OWES_50:  // Owes 1 Sov
           {
                nResult = RAN_GetBribeAtLevels(5, 7);
                break;
           }
           case RAN_TEMPLAR_OWES_60:  // Owes 2 Sov
           {
                nResult = RAN_GetBribeAtLevels(7, 9);
                break;
           }
           case RAN_TEMPLAR_OWES_70:  // Owes 4 Sov
           {
                nResult = RAN_GetBribeAtLevels(9, 11);
                break;
           }
           case RAN_TEMPLAR_OWES_80:  // Owes 6 sov
           {
                nResult = RAN_GetBribeAtLevels(11, 13);
                break;
           }
           case RAN_TEMPLAR_OWES_90:  // Owes 8 sov
           {
                nResult = RAN_GetBribeAtLevels(13, 15);
                break;
           }
           case RAN_TEMPLAR_OWES_100: // Owes 10 sov
           {
                nResult = RAN_GetBribeAtLevels(15, 21);
                break;
           }

           // --- END OF TEMPLAR STEALING CHECK ---





// Takes player level, returns amount needed for bribe, in silver

           case RAN_ENCOUNTER_TAORAN:
           {
               // Qwinn: The following should be based on TAORAN_QUEST_GIVEN, otherwise can't meet Raelnor before Taoran if didn't take quest in Denerim
               // int bQuestGiven          = WR_GetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_QUEST_GIVEN, TRUE);
               int bQuestGiven          = WR_GetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_TAORAN_QUEST_GIVEN, TRUE);
               int bTaoranKilled        = WR_GetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_TAORAN_KILLED, TRUE);
               int bTaoranIntimidated   = WR_GetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_TAORAN_INTIMIDATED, TRUE);
               int bQuestClosed         = WR_GetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_QUEST_CLOSED, TRUE);

               if (bQuestGiven && !bTaoranKilled && !bTaoranIntimidated && !bQuestClosed)
               {
                    // Qwinn commented out
                    // WR_SetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_QUEST_GIVEN, FALSE);
                    nResult = TRUE;
               }
               break;
            }
            case RAN_ENCOUNTER_FALSE_WITNESSES:
            {
                int bWitnessQuest   = WR_GetPlotFlag(PLT_LITE_MAGE_WITNESSES, WITNESSES_QUEST_GIVEN, TRUE);
                int bWitnessStopped = WR_GetPlotFlag(PLT_LITE_MAGE_WITNESSES, WITNESSES_ADVENTURERS_STOPPED, TRUE);
                int bWitnessSetFree = WR_GetPlotFlag(PLT_LITE_MAGE_WITNESSES, WITNESSES_ADVENTURERS_SET_FREE, TRUE);

                if (bWitnessQuest && !bWitnessStopped && !bWitnessSetFree)
                {
                    // WR_SetPlotFlag(PLT_LITE_MAGE_WITNESSES, WITNESSES_QUEST_GIVEN, FALSE);
                    nResult = TRUE;
                }

                break;
            }
            case RAN_ENCOUNTER_SEEN_ME:
            {
                int bSeenMeQuest = WR_GetPlotFlag(PLT_LITE_MAGE_RENOLD, RENOLD_QUEST_GIVEN, TRUE);
                int bSeenMeComp  = WR_GetPlotFlag(PLT_LITE_MAGE_RENOLD, RENOLD_QUEST_COMPLETE, TRUE);

                if (bSeenMeQuest && !bSeenMeComp)
                {
                    // WR_SetPlotFlag(PLT_LITE_MAGE_RENOLD, RENOLD_QUEST_GIVEN, FALSE);
                    nResult = TRUE;
                }
                break;
            }
        }
    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}