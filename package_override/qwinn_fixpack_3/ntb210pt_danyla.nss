//::///////////////////////////////////////////////
//:: Plot Events                                                                                                                            UT_GetNearestCreatureByTag
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for Danyla
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: Jan 22/07
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "sys_achievements_h"
#include "plt_ntb100pt_varathorn"
#include "plt_ntb200pt_deygan"
#include "plt_ntb100pt_cammen"

#include "plt_ntb220pt_danyla"
#include "plt_ntb000pt_main"
#include "ntb_constants_h"
#include "plt_ntb210pt_hermit"
#include "plt_ntb000pt_plot_items"

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
    object oDanyla = UT_GetNearestCreatureByTag(oPC,NTB_CR_DANYLA);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case NTB_DANYLA_GOES_HOSTILE:
            {
                //----------------------------------------------------------------------
                // Danyla attacks the PC
                //----------------------------------------------------------------------
                SetImmortal(oDanyla, FALSE);
                UT_CombatStart(oDanyla,oPC);
                break;
            }
            case NTB_DANYLA_KILLED_BY_PC:
            {
                //----------------------------------------------------------------------
                //CUTSCENE: pc kills Danyla
                //----------------------------------------------------------------------
                SetImmortal(oDanyla, FALSE);
                KillCreature(oDanyla,oPC);
                break;
            }
            case NTB_DANYLA_ATHRAS_LEAVES:
            {
                object oAthras = UT_GetNearestCreatureByTag(oPC,NTB_CR_ATHRAS);
                //----------------------------------------------------------------------
                //ACTION: Athras will leave permanently
                //----------------------------------------------------------------------
                WR_SetObjectActive(oAthras,FALSE);
                break;
            }
            case NTB_DANYLA_WEREWOLF_ATTACKS:
            {
                object oAthrasWerewolf = UT_GetNearestCreatureByTag(oPC,NTB_CR_ATHRAS_WEREWOLF);
                //----------------------------------------------------------------------
                //ACTION: Danyla attacks, Athras should die
                //he should have some treasure on him
                //----------------------------------------------------------------------
                SetImmortal(oDanyla, FALSE);
                UT_CombatStart(oDanyla,oPC);
                //WR_SetObjectActive(oAthrasWerewolf,FALSE);

                break;
            }
            case NTB_DANYLA_GIVES_PC_SCARF:
            {
                int nScarf = UT_CountItemInInventory(rNTB_IM_DANYLA_SCARF);
                //----------------------------------------------------------------------
                // if you don't have the item in your inventory already
                // add it
                //----------------------------------------------------------------------
                if(nScarf == FALSE)
                {
                    UT_AddItemToInventory(rNTB_IM_DANYLA_SCARF);
                }
                break;
            }
            case NTB_DANYLA_ATHRAS_TAKES_SCARF:
            {
                int nDeadHermit = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_KILLED_BY_PC,TRUE);
                int nHermitGone = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_LEAVES_PERMANENTLY,TRUE);
                object oScarf = GetItemPossessedBy(oPC,NTB_IM_DANYLA_SCARF);
                //----------------------------------------------------------------------
                // if the hermit is dead or gone, remove scarf from PC
                //otherwise, it is a trade item for the PC
                //***WHY WAS THIS SET UP SO THE PLAYER COULD DO BOTH?
                //----------------------------------------------------------------------
                //if((nDeadHermit == TRUE) || (nHermitGone == TRUE))
                //{
                    if(IsObjectValid(oScarf))
                    {
                        WR_DestroyObject(oScarf);
                    }

                //}
                break;
            }
            case NTB_DANYLA_PC_TOLD_ATHRAS:
            {
                //----------------------------------------------------------------------
                // FAB 7/2: Adding achievement for NotB
                //----------------------------------------------------------------------
                int bCondition1 = WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_WEREWOLVES_PROMISED_ALLIANCE);
                int bCondition2 = WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_ELVES_PROMISED_ALLIANCE);
                if ( !bCondition1 && !bCondition2 ) break;

                int nCounter;
                if ( WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_COUPLE_IN_LOVE) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB100PT_VARATHORN, NTB_VARATHORN_IRONBARK_PLOT_DONE) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB200PT_DEYGAN, NTB_DEYGAN_PC_RETURNED_BODY) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB200PT_DEYGAN, NTB_DEYGAN_HEALED_BY_PC) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB200PT_DEYGAN, NTB_DEYGAN_RETURNED_ALIVE_WITH_PC) ) nCounter++;

                if ( nCounter >= 1 ) Acv_Grant(30);
                //----------------------------------------------------------------------
                // End achievement code
                //----------------------------------------------------------------------

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BRECILIAN_1a);

                break;
            }
            case NTB_DANYLA_ATHRAS_TOLD_PC_ABOUT_DANYLA:
            {
                //turn off plot giver
                object oAthras = UT_GetNearestCreatureByTag(oPC,NTB_CR_ATHRAS);
                SetPlotGiver(oAthras, FALSE);


                break;
            }

            case NTB_DANYLA_ATHRAS_ANGRY:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BRECILIAN_1a);

                break;
            }

            case NTB_DANYLA_ATHRAS_DEAD:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BRECILIAN_1a);

                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        switch(nFlag)
        {
            case NTB_DANYLA_REWARD_PROMISED_AND_NOT_REWARDED:
            {
                int nPromise = WR_GetPlotFlag(PLT_NTB220PT_DANYLA, NTB_DANYLA_ATHRAS_PROMISES_PC_REWARD);
                int nReward = WR_GetPlotFlag(PLT_NTB220PT_DANYLA, NTB_DANYLA_ATHRAS_GIVES_PC_REWARD);

                if (nPromise == TRUE && nReward == FALSE)
                {
                    nResult = TRUE;
                }
                break;
            }

            case NTB_DANYLA_NO_REWARD_PROMISE_AND_NOT_REWARDED:
            {
                int nPromise = WR_GetPlotFlag(PLT_NTB220PT_DANYLA, NTB_DANYLA_ATHRAS_PROMISES_PC_REWARD);
                int nReward = WR_GetPlotFlag(PLT_NTB220PT_DANYLA, NTB_DANYLA_ATHRAS_GIVES_PC_REWARD);

                if (nPromise == FALSE && nReward == FALSE)
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_DANYLA_ATHRAS_TOLD_BUT_PC_NOT_FOUND:
            {
                int nFound = WR_GetPlotFlag(PLT_NTB220PT_DANYLA,NTB_DANYLA_FOUND_BY_PC);
                int nAthras = WR_GetPlotFlag(PLT_NTB220PT_DANYLA,NTB_DANYLA_ATHRAS_TOLD_PC_ABOUT_DANYLA);

                //----------------------------------------------------------------------
                // if not yet found by the PC
                // and Athras has told the PC about Danyla
                //----------------------------------------------------------------------
                if((nFound == FALSE) && (nAthras == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_DANYLA_NOT_PROMISED_NOT_FOUND_ELVES_PROMISED_ALLIANCE:
            {
                //
                int nFound = WR_GetPlotFlag(PLT_NTB220PT_DANYLA,NTB_DANYLA_FOUND_BY_PC);
                int nAlliance = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ELVES_PROMISED_ALLIANCE,TRUE);
                int nFind = WR_GetPlotFlag(PLT_NTB220PT_DANYLA,NTB_DANYLA_PC_PROMISED_TO_FIND_DANYLA,TRUE);
                int nAthlasTold = WR_GetPlotFlag(PLT_NTB220PT_DANYLA, NTB_DANYLA_ATHRAS_TOLD_PC_ABOUT_DANYLA);
                //----------------------------------------------------------------------
                // if not yet found by the PC
                // and PC didn't promise to find Danyla
                // and the NTB plot is finished already
                //
                // ***CHANGED to if plot is finished and never spoke with Athlas before
                //----------------------------------------------------------------------
                //if((nAlliance == TRUE) && (nFind == FALSE) && (nFound == FALSE))
                //{
                //    nResult = TRUE;
                //}
                if (nAlliance == TRUE && nAthlasTold == FALSE)
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_DANYLA__ATHRAS_TOLD_AND_PC_HUMAN:
            {
                int nTold = WR_GetPlotFlag(PLT_NTB220PT_DANYLA, NTB_DANYLA_ATHRAS_TOLD_PC_ABOUT_DANYLA);
                object oPC = GetHero();
                if(GetCreatureRacialType(oPC) == RACE_HUMAN && nTold == TRUE)
                    nResult = TRUE;
            }
        }
    }

    return nResult;
}