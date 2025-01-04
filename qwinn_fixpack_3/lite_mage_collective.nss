//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for the mage board and
    collective representative
*/
//:://////////////////////////////////////////////
//:: Created By: Keith
//:: Created On: Jan 8th, 2009
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "lit_functions_h"



#include "achievement_core_h"

void CheckDefendingActive();

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

    int nBanastorDone = WR_GetPlotFlag(PLT_LITE_MAGE_BANASTOR, BANASTOR_SCROLLS_FOUND);
    int nBanastorComplete = WR_GetPlotFlag(PLT_LITE_MAGE_BANASTOR, BANASTOR_QUEST_COMPLETE);
    int nHerbalGiven = WR_GetPlotFlag(PLT_LITE_MAGE_HERBAL, HERBAL_QUEST_GIVEN);
    int nHerbalComplete = WR_GetPlotFlag(PLT_LITE_MAGE_HERBAL , HERBAL_QUEST_COMPLETE);
    int nTerminationDone = WR_GetPlotFlag(PLT_LITE_MAGE_TERMINATION, TERMINATION_APPRENTICES_TERMINATED);
    int nTerminationComplete = WR_GetPlotFlag(PLT_LITE_MAGE_TERMINATION, TERMINATION_QUEST_COMPLETE);
    int nPlacesDone = WR_GetPlotFlag(PLT_LITE_MAGE_PLACES, PLACES_FOUND);
    int nPlacesComplete = WR_GetPlotFlag(PLT_LITE_MAGE_PLACES, PLACES_QUEST_COMPLETE);
    int nKillerDone = WR_GetPlotFlag(PLT_LITE_MAGE_KILLER, KILLER_MAGES_KILLED);
    int nKillerComplete = WR_GetPlotFlag(PLT_LITE_MAGE_KILLER, KILLER_QUEST_COMPLETE);
    int nSilenceDone = WR_GetPlotFlag(PLT_LITE_MAGE_SILENCE, SILENCE_BRIBE_DELIVERED);
    int nSilenceComplete = WR_GetPlotFlag(PLT_LITE_MAGE_SILENCE, SILENCE_QUEST_COMPLETE);
    int nWitnessessDone = WR_GetPlotFlag(PLT_LITE_MAGE_WITNESSES, WITNESSES_ADVENTURERS_STOPPED);
    int nWitnessessComplete = WR_GetPlotFlag(PLT_LITE_MAGE_WITNESSES, WITNESSES_QUEST_COMPLETE);
    int nRenoldDone = WR_GetPlotFlag(PLT_LITE_MAGE_RENOLD, RENOLD_NOTE_FOUND);
    int nRenoldComplete = WR_GetPlotFlag(PLT_LITE_MAGE_RENOLD, RENOLD_QUEST_COMPLETE);
    int nDefendingDone = WR_GetPlotFlag(PLT_LITE_MAGE_DEFENDING, DEFENDING_TESTIMONY_GIVEN);
    int nDefendingComplete = WR_GetPlotFlag(PLT_LITE_MAGE_DEFENDING, DEFENDING_QUEST_COMPLETE);
    int nWarningDone = WR_GetPlotFlag(PLT_LITE_MAGE_WARNING, WARNING_DOORS_MARKED);
    int nWarningComplete = WR_GetPlotFlag(PLT_LITE_MAGE_WARNING, WARNING_QUEST_COMPLETE);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case MAGE_COLLECTIVE_LEARNED_ABOUT:
            {
                //mage bag is now available
                //check what area this is
                string szAreaTag = GetTag(GetArea(oPC));
                object oBag;

                if (szAreaTag == "den200ar_market")
                {
                    oBag = UT_GetNearestObjectByTag(oPC, LITE_IP_MAGE_BAG_1);
                }
                else if (szAreaTag == "cir100ar_docks")
                {
                    oBag = UT_GetNearestObjectByTag(oPC, LITE_IP_MAGE_BAG_2);
                }
                else if (szAreaTag == "arl100ar_redcliffe_village")
                {
                    oBag = UT_GetNearestObjectByTag(oPC, LITE_IP_MAGE_BAG_3);
                }

                SetObjectInteractive(oBag, TRUE);

                break;
            }
            case MAGE_COLLECTIVE_PLOT_TURN_IN:
            {
                //Mark any plots that are done as complete - if this is the last quest - then activate Defending

                //Mage Banastor
                if (nBanastorDone == TRUE && nBanastorComplete == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_MAGE_BANASTOR, BANASTOR_QUEST_COMPLETE, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }
                //Mage Termination
                else if ( nTerminationDone == TRUE && nTerminationComplete == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_MAGE_TERMINATION, TERMINATION_QUEST_COMPLETE, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }

                //Mage Places
                else if (nPlacesDone == TRUE && nPlacesComplete == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_MAGE_PLACES, PLACES_QUEST_COMPLETE, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }

                //Mage Killer
                else if (nKillerDone == TRUE && nKillerComplete == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_MAGE_KILLER, KILLER_QUEST_COMPLETE, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }

                //Mage Silence
                else if (nSilenceDone == TRUE && nSilenceComplete == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_MAGE_SILENCE, SILENCE_QUEST_COMPLETE, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }
                //Mage Renold
                else if (nRenoldDone == TRUE && nRenoldComplete == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_MAGE_RENOLD, RENOLD_QUEST_COMPLETE, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }
                //Mage Witnesses
                else if (nWitnessessDone == TRUE && nWitnessessComplete == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_MAGE_WITNESSES, WITNESSES_QUEST_COMPLETE, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }
                //Mage Defending
                else if (nDefendingDone == TRUE && nDefendingComplete == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_MAGE_DEFENDING, DEFENDING_QUEST_COMPLETE, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }
                //mage Warning
                else if (nWarningDone == TRUE && nWarningComplete == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_MAGE_WARNING, WARNING_QUEST_COMPLETE, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }
                //Mage Herbal
                else if ( nHerbalGiven == TRUE && nHerbalComplete == FALSE)
                {
                    //get all of the stacks of health poultices
                    object [] arrMushroom = GetItemsInInventory(oPC, GET_ITEMS_OPTION_BACKPACK, 0, LITE_IM_DEEP_MUSHROOM);

                    //if there is a valid stack
                    if (IsObjectValid(arrMushroom[0]) == TRUE)
                    {
                        //if you have at least 20 in your stack, you can turn them in.
                        int nMushrooms = GetItemStackSize(arrMushroom[0]);
                        if (nMushrooms >= 10)
                        {
                            //remove poultice items
                            UT_RemoveItemFromInventory(rLITE_IM_STOCK_MUSHROOM, 10);
                            //set plot done
                            WR_SetPlotFlag(PLT_LITE_MAGE_HERBAL , HERBAL_QUEST_COMPLETE, TRUE, TRUE);
                            if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                        }
                    }
                }
                

                //grant achievement for finishing a mage plot
                ACH_CollectiveAchievement();

                CheckDefendingActive();

                if (MageCollectiveTurnInPossible(oPC) == FALSE)
                {
                   object oMage = UT_GetNearestCreatureByTag(oPC, "lite_mage_collective");
                   SetPlotGiver(oMage, FALSE);
                }
                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case MAGE_COLLECTIVE_PLOT_READY:
            {
                //Mage Banastor
                if (nBanastorDone == TRUE && nBanastorComplete == FALSE)
                {
                    nResult = TRUE;
                }

                //Mage Herbal
                if ( nHerbalGiven == TRUE && nHerbalComplete == FALSE)
                {
                    //get all of the stacks of health poultices
                    object [] arrMushroom = GetItemsInInventory(oPC, GET_ITEMS_OPTION_BACKPACK, 0, LITE_IM_DEEP_MUSHROOM);

                    //if there is a valid stack
                    if (IsObjectValid(arrMushroom[0]) == TRUE)
                    {
                        //if you have at least 20 in your stack, you can turn them in.
                        int nMushrooms = GetItemStackSize(arrMushroom[0]);
                        if (nMushrooms >= 10)
                        {
                            nResult = TRUE;
                        }
                    }

                }

                //Mage Termination
                if ( nTerminationDone == TRUE && nTerminationComplete == FALSE)
                {
                    nResult = TRUE;
                }

                //Mage Places
                if (nPlacesDone == TRUE && nPlacesComplete == FALSE)
                {
                    nResult = TRUE;
                }

                //Mage Killer
                if (nKillerDone == TRUE && nKillerComplete == FALSE)
                {
                    nResult = TRUE;
                }

                //Mage Silence
                if (nSilenceDone == TRUE && nSilenceComplete == FALSE)
                {
                    nResult = TRUE;
                }
                //Mage Renold
                if (nRenoldDone == TRUE && nRenoldComplete == FALSE)
                {
                    nResult = TRUE;
                }
                //Mage Witnesses
                if (nWitnessessDone == TRUE && nWitnessessComplete == FALSE)
                {
                    nResult = TRUE;
                }
                //Mage Defending
                if (nDefendingDone == TRUE && nDefendingComplete == FALSE)
                {
                    nResult = TRUE;
                }
                //mage Warning
                if (nWarningDone == TRUE && nWarningComplete == FALSE)
                {
                    nResult = TRUE;
                }
                break;
            }

        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}

void CheckDefendingActive()
{
    //if all other plots are done activate defending on the mage board
    int nBanastorComplete = WR_GetPlotFlag(PLT_LITE_MAGE_BANASTOR, BANASTOR_QUEST_COMPLETE);
    int nHerbalComplete = WR_GetPlotFlag(PLT_LITE_MAGE_HERBAL , HERBAL_QUEST_COMPLETE);
    int nTerminationComplete = WR_GetPlotFlag(PLT_LITE_MAGE_TERMINATION, TERMINATION_QUEST_COMPLETE);
    int nPlacesComplete = WR_GetPlotFlag(PLT_LITE_MAGE_PLACES, PLACES_QUEST_COMPLETE);
    int nKillerComplete = WR_GetPlotFlag(PLT_LITE_MAGE_KILLER, KILLER_QUEST_COMPLETE);
    int nSilenceComplete = WR_GetPlotFlag(PLT_LITE_MAGE_SILENCE, SILENCE_QUEST_COMPLETE);
    int nWitnessessComplete = WR_GetPlotFlag(PLT_LITE_MAGE_WITNESSES, WITNESSES_QUEST_COMPLETE);
    int nRenoldComplete = WR_GetPlotFlag(PLT_LITE_MAGE_RENOLD, RENOLD_QUEST_COMPLETE);
    int nDefendingComplete = WR_GetPlotFlag(PLT_LITE_MAGE_DEFENDING, DEFENDING_QUEST_COMPLETE);
    int nWarningComplete = WR_GetPlotFlag(PLT_LITE_MAGE_WARNING, WARNING_QUEST_COMPLETE);

    if ( nBanastorComplete == TRUE && nHerbalComplete == TRUE &&
         nTerminationComplete == TRUE && nPlacesComplete == TRUE &&
         nKillerComplete == TRUE && nSilenceComplete == TRUE &&
         nWitnessessComplete == TRUE && nRenoldComplete == TRUE && nWarningComplete == TRUE)
    {
        WR_SetPlotFlag(PLT_LITE_MAGE_DEFENDING, DEFENDING_MAGE_BOARD, TRUE);
    }
}