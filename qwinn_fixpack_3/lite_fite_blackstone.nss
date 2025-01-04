//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for the fighter board and
    blackstone representative
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

#include "plt_lite_fite_blackstone"
#include "plt_cod_lite_fite_blackston"


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

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case FITE_BLACKSTONE_LEARNED_ABOUT:
            {
                //fighter box is now available
                //check what area this is
                string szAreaTag = GetTag(GetArea(oPC));
                object oBox;

                if (szAreaTag == "lot120ar_danes_refuge")
                {
                    oBox = UT_GetNearestObjectByTag(oPC, LITE_IM_BLACKSTONE_BOX_1);
                }
                else if (szAreaTag == "den220ar_noble_tavern")
                {
                    oBox = UT_GetNearestObjectByTag(oPC, LITE_IM_BLACKSTONE_BOX_2);
                }
                else if (szAreaTag == "arl100ar_redcliffe_village")
                {
                    oBox = UT_GetNearestObjectByTag(oPC, LITE_IM_BLACKSTONE_BOX_3);
                }
                WR_SetPlotFlag(PLT_COD_LITE_FITE_BLACKSTON, BLACKSTONE_MAIN, TRUE, TRUE);

                SetObjectInteractive(oBox, TRUE);

                break;
            }
            case FITE_BLACKSTONE_PLOT_TURN_IN:
            {
                //Plot States
                int nCondolencesDone = WR_GetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_DELIVERED);
                int nCondolencesComplete = WR_GetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_QUEST_COMPLETE);
                int nConscriptsDone = WR_GetPlotFlag(PLT_LITE_FITE_CONSCRIPTS, CONSCRIPTS_MET);
                int nConscriptsComplete = WR_GetPlotFlag(PLT_LITE_FITE_CONSCRIPTS, CONSCRIPTS_QUEST_COMPLETE);
                int nDesertersDone = WR_GetPlotFlag(PLT_LITE_FITE_DESERTERS, DESERTERS_FOUND);
                int nDesertersComplete = WR_GetPlotFlag(PLT_LITE_FITE_DESERTERS, DESERTERS_QUEST_COMPLETE);
                int nGreaseDone = WR_GetPlotFlag(PLT_LITE_FITE_GREASE, GREASE_NOTICES_DELIVERED);
                int nGreaseComplete = WR_GetPlotFlag(PLT_LITE_FITE_GREASE, GREASE_QUEST_COMPLETE);
                int nLeadRaelnorDone = WR_GetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_RAELNOR_DEAD);
                int nLeadRaelnorComplete = WR_GetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_COMPLETE_RAELNOR_DEAD);
                int nLeadTaoranDone = WR_GetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_TAORAN_KILLED);
                int nLeadTaoranComplete = WR_GetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_COMPLETE_TAORAN_DEAD);
                int nRestockGiven = WR_GetPlotFlag(PLT_LITE_FITE_RESTOCK, RESTOCK_QUEST_GIVEN);
                int nRestockComplete = WR_GetPlotFlag(PLT_LITE_FITE_RESTOCK, RESTOCK_QUEST_COMPLETE);
                //int nRopesGiven = WR_GetPlotFlag(PLT_LITE_FITE_ROPES, ROPES_QUEST_GIVEN);
                //int nRopesComplete = WR_GetPlotFlag(PLT_LITE_FITE_ROPES, ROPES_QUEST_COMPLETE);
                int nLeadershipAccepted = WR_GetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_QUEST_GIVEN);

                int nQuestsCompleted =  nCondolencesComplete + nConscriptsComplete + nDesertersComplete +
                                        nGreaseComplete + nRestockComplete;

                //The player completed a fighter board quest, give achievement
                ACH_FighterAchievement();

                //if we got here - something was ready to be turned in, so let's find what's ready (could be multiple things)

                //Condolences done but not turned in
                if ( nCondolencesDone == TRUE && nCondolencesComplete == FALSE)
                {
                    //set quest as done
                    WR_SetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_QUEST_COMPLETE, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }
                //Conscripts done but not turned in
                else if ( nConscriptsDone == TRUE && nConscriptsComplete == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_FITE_CONSCRIPTS, CONSCRIPTS_QUEST_COMPLETE, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }
                //Deserters done but not turned in
                else if ( nDesertersDone == TRUE && nDesertersComplete == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_FITE_DESERTERS, DESERTERS_QUEST_COMPLETE, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                    //remove the supplies
                     UT_RemoveItemFromInventory(rLITE_IM_FITE_DESERTERS_SUP, 3);
                }
                //Grease done but not turned in
                else if ( nGreaseDone == TRUE && nGreaseComplete == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_FITE_GREASE, GREASE_QUEST_COMPLETE, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }
                //Leadership (Raelnor killing) done but not turned in
                else if ( nLeadRaelnorDone == TRUE && nLeadRaelnorComplete == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_COMPLETE_RAELNOR_DEAD, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }
                //Leadership (Taoran killing) done but not turned in
                else if ( nLeadTaoranDone == TRUE && nLeadTaoranComplete == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_COMPLETE_TAORAN_DEAD, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }

                //Restock done but not turned in
                else if (nRestockGiven == TRUE && nRestockComplete == FALSE)
                {
                    //remove the 20 health poultices (Check which kind the player has and remove them
                    //from the crappy ones to the best ones, in order
                    int nPoulticesRemoved = 0;
                    int nStackSize = 0;
                    //get all of the stacks of health potions
                    int nPoultice1 = UT_CountItemInInventory(rLITE_IM_HEALTH_POUL_LESSER);
                    int nPoultice2 = UT_CountItemInInventory(rLITE_IM_HEALTH_POUL);
                    int nPoultice3 = UT_CountItemInInventory(rLITE_IM_HEALTH_POUL_GREATER);
                    int nPoultice4 = UT_CountItemInInventory(rLITE_IM_HEALTH_POUL_POTENT);

                //if there is a valid stack - add to the total potions
                    if (nPoultice1 > 0)
                    {
                        nStackSize = nPoultice1;
                        if (nStackSize >= 20)
                        {
                            UT_RemoveItemFromInventory(rLITE_IM_HEALTH_POUL_LESSER, 20);
                            nPoulticesRemoved = 20;
                        }
                        else
                        {
                            UT_RemoveItemFromInventory(rLITE_IM_HEALTH_POUL_LESSER, nStackSize);
                            nPoulticesRemoved = nStackSize;
                        }
                    }
                    if (nPoulticesRemoved < 20)
                    {
                        if (nPoultice2 > 0)
                        {
                            nStackSize = nPoultice2;
                            //if you have enough to cover the rest of the potions then remove them
                            if (nStackSize >= 20 - nPoulticesRemoved)
                            {
                                UT_RemoveItemFromInventory(rLITE_IM_HEALTH_POUL, 20 - nPoulticesRemoved);
                                nPoulticesRemoved = 20;
                            }
                            else
                            {
                                UT_RemoveItemFromInventory(rLITE_IM_HEALTH_POUL, nStackSize);
                                nPoulticesRemoved = nPoulticesRemoved - nStackSize;
                            }
                        }
                        //check if we've removed enough yet - if not - go to the third stack
                        if (nPoulticesRemoved < 20)
                        {
                            if (nPoultice3 >0)
                            {
                                nStackSize = nPoultice3;
                                //if you have enough to cover the rest of the potions then remove them
                                if (nStackSize >= 20 - nPoulticesRemoved)
                                {
                                    UT_RemoveItemFromInventory(rLITE_IM_HEALTH_POUL_GREATER, 20 - nPoulticesRemoved);
                                    nPoulticesRemoved = 20;
                                }
                                else
                                {
                                    UT_RemoveItemFromInventory(rLITE_IM_HEALTH_POUL_GREATER, nStackSize);
                                    nPoulticesRemoved = nPoulticesRemoved - nStackSize;
                                }
                            }
                            //check if we've removed enough yet - if not - go to the fourth stack
                            if (nPoulticesRemoved < 20)
                            {
                                if (nPoultice4 > 0)
                                {
                                    nStackSize = nPoultice4;
                                    //THIS "HAS" to be enough to cover the rest of the potions then remove them
                                    if (nStackSize >= 20 - nPoulticesRemoved)
                                    {
                                        UT_RemoveItemFromInventory(rLITE_IM_HEALTH_POUL_POTENT, 20 - nPoulticesRemoved);
                                        nPoulticesRemoved = 20;
                                    }

                                }
                            }
                        }
                    }
                    WR_SetPlotFlag(PLT_LITE_FITE_RESTOCK, RESTOCK_QUEST_COMPLETE, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }
                //Ropes done but not turned in  **** ROPES CUT
                /*
                if ( nRopesGiven == TRUE && nRopesComplete == FALSE)
                {
                    //get all of the rope traps in inventory
                    int nRopeTrap = UT_CountItemInInventory(rLITE_IM_FITE_ROPE_TRAP);
                    if (nRopeTrap >= 10)
                    {
                        //remove rope trap items
                        UT_RemoveItemFromInventory(rLITE_IM_FITE_ROPE_TRAP, 10);
                        //set plot done
                        WR_SetPlotFlag(PLT_LITE_FITE_ROPES, ROPES_QUEST_COMPLETE, TRUE, TRUE);
                        if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                    }

                }
                */
                //Activate Leadership quest after 4 others completed (restock not necessary
                if ((nCondolencesDone == TRUE || nCondolencesComplete == TRUE) &&
                    (nConscriptsDone == TRUE || nConscriptsComplete == TRUE) &&
                    (nDesertersDone == TRUE || nDesertersComplete == TRUE)&&
                    (nGreaseDone == TRUE || nGreaseComplete == TRUE) &&
                    nLeadershipAccepted == FALSE)
                {
                    //set the leadership plot on the board
                    WR_SetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_FIGHTER_BOARD, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }

                if (BlackstoneTurnInPossible() == FALSE)
                {
                    object oBlackstone = UT_GetNearestCreatureByTag(oPC, "lite_fite_blackstone");
                    SetPlotGiver(oBlackstone, FALSE);
                }
                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case FITE_BLACKSTONE_PLOT_READY:
            {
                if (WR_GetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_DELIVERED) == TRUE && WR_GetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_QUEST_COMPLETE) == FALSE)
                {
                    nResult = TRUE;
                }
                //Conscripts done but not turned in
                else if (WR_GetPlotFlag(PLT_LITE_FITE_CONSCRIPTS, CONSCRIPTS_MET) == TRUE && WR_GetPlotFlag(PLT_LITE_FITE_CONSCRIPTS, CONSCRIPTS_QUEST_COMPLETE) == FALSE)
                {
                    nResult = TRUE;
                }
                //Deserters done but not turned in
                else if (WR_GetPlotFlag(PLT_LITE_FITE_DESERTERS, DESERTERS_FOUND) == TRUE && WR_GetPlotFlag(PLT_LITE_FITE_DESERTERS, DESERTERS_QUEST_COMPLETE) == FALSE)
                {
                    nResult = TRUE;
                }
                //Grease done but not turned in
                else if (WR_GetPlotFlag(PLT_LITE_FITE_GREASE, GREASE_NOTICES_DELIVERED) == TRUE && WR_GetPlotFlag(PLT_LITE_FITE_GREASE, GREASE_QUEST_COMPLETE) == FALSE)
                {
                    nResult = TRUE;
                }
                //Leadership (Raelnor killing) done but not turned in
                else if (WR_GetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_RAELNOR_DEAD) == TRUE && WR_GetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_COMPLETE_RAELNOR_DEAD) == FALSE)
                {
                    nResult = TRUE;
                }
                //Leadership (Taoran killing) done but not turned in
                else if (WR_GetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_TAORAN_KILLED) == TRUE && WR_GetPlotFlag(PLT_LITE_FITE_LEADERSHIP, LEADERSHIP_COMPLETE_TAORAN_DEAD) == FALSE)
                {
                    nResult = TRUE;
                }
                //Lost Orders done but not turned in
                else if (WR_GetPlotFlag(PLT_LITE_FITE_LOSTORDERS, LOSTORDERS_FOUND) == TRUE && WR_GetPlotFlag(PLT_LITE_FITE_LOSTORDERS, LOSTORDERS_QUEST_COMPLETE) == FALSE)
                {
                    nResult = TRUE;
                }
                //Quality done but not turned in
                else if (WR_GetPlotFlag(PLT_LITE_FITE_QUALITY, QUALITY_OPPONENTS_BEATEN) == TRUE && WR_GetPlotFlag(PLT_LITE_FITE_QUALITY, QUALITY_QUEST_COMPLETE) == FALSE)
                {
                    nResult = TRUE;
                }
                //Restock done but not turned in
                if (nResult == FALSE)
                {
                    if (WR_GetPlotFlag(PLT_LITE_FITE_RESTOCK, RESTOCK_QUEST_COMPLETE) == FALSE && WR_GetPlotFlag(PLT_LITE_FITE_RESTOCK, RESTOCK_QUEST_GIVEN) == TRUE)
                    {
                        int nPoulticeCount = 0;
                        nPoulticeCount = UT_CountItemInInventory(rLITE_IM_HEALTH_POUL_LESSER);
                        nPoulticeCount = nPoulticeCount + UT_CountItemInInventory(rLITE_IM_HEALTH_POUL);
                        nPoulticeCount = nPoulticeCount + UT_CountItemInInventory(rLITE_IM_HEALTH_POUL_GREATER);
                        nPoulticeCount = nPoulticeCount + UT_CountItemInInventory(rLITE_IM_HEALTH_POUL_POTENT);

                        if (nPoulticeCount >= 20)
                        {
                            nResult = TRUE;
                        }
                    }

                    //Ropes done but not turned in  ****ROPES PLOT CUT
                    /*
                    if (WR_GetPlotFlag(PLT_LITE_FITE_ROPES, ROPES_QUEST_COMPLETE) == FALSE && WR_GetPlotFlag(PLT_LITE_FITE_ROPES, ROPES_QUEST_GIVEN) == TRUE)
                    {
                        //get how many ropes are in inventory
                        int nRopeTrap = UT_CountItemInInventory(rLITE_IM_FITE_ROPE_TRAP);
                        if (nRopeTrap >= 10)
                        {
                            nResult = TRUE;
                        }

                    }
                    */
                }

                break;
            }

        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}