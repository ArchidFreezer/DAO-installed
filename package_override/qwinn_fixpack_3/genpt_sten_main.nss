//::///////////////////////////////////////////////
//:: Plot Events
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for sten's main plot
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: Sept 6/07
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "plt_genpt_sten_main"
#include "plt_gen00pt_party"
#include "plt_genpt_sten_events"
#include "orz_constants_h"
#include "plt_cod_cha_sten"
#include "camp_constants_h"
#include "plt_mnp000pt_autoss_main2"


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
    object oFaryn = UT_GetNearestObjectByTag(oPC,ORZ_CR_FARYN);
    object oSten = UT_GetNearestObjectByTag(oPC,GEN_FL_STEN);
    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    resource rStenSword     = R"gen_im_gift_sword_sten.uti";
    resource rStenSwordReal = R"gen_im_wep_mel_gsw_stn.uti";

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case STEN_MAIN_FARYN_EXITS:
            {
                //ACTION: Faryn exits.
                WR_SetObjectActive(oFaryn,FALSE);
                break;
            }
            case STEN_MAIN_PC_BRIBES_FARYN:
            {
                //PC loses appropriate gold.
                // Qwinn:  Actually, it was only deducting copper.
                int nFive = WR_GetPlotFlag(PLT_GENPT_STEN_MAIN,STEN_MAIN_FARYN_ACCEPTS_BRIBE,TRUE);
                int nFour = WR_GetPlotFlag(PLT_GENPT_STEN_MAIN,STEN_MAIN_FARYN_ACCEPTS_MEDIUM_BRIBE,TRUE);
                int nTwo = WR_GetPlotFlag(PLT_GENPT_STEN_MAIN,STEN_MAIN_FARYN_ACCEPTS_SMALL_BRIBE,TRUE);

                if(nFive == TRUE)
                {
                    // UT_MoneyTakeFromObject(oPC,ORZ_FARYN_CASH_REQ_HIGH);
                    UT_MoneyTakeFromObject(oPC,0,0,ORZ_FARYN_CASH_REQ_HIGH);
                }
                else if(nFour == TRUE)
                {
                    // UT_MoneyTakeFromObject(oPC,ORZ_FARYN_CASH_REQ_MEDIUM);
                    UT_MoneyTakeFromObject(oPC,0,0,ORZ_FARYN_CASH_REQ_MEDIUM);
                }
                else if(nTwo == TRUE)
                {
                    // UT_MoneyTakeFromObject(oPC,ORZ_FARYN_CASH_REQ_LOW);
                    UT_MoneyTakeFromObject(oPC,0,0,ORZ_FARYN_CASH_REQ_LOW);
                }
                break;
            }

            case STEN_MAIN_PC_PAY_SIX_GOLD:
            {
                // Create Gift sword for PC to give to Sten
                UT_MoneyTakeFromObject(oPC, 0, 0, 6);
                break;
            }
            case STEN_MAIN_PC_PAY_THREE_GOLD:
            {
                // Create Gift sword for PC to give to Sten
                UT_MoneyTakeFromObject(oPC, 0, 0, 3);
                break;
            }
            case STEN_MAIN_PC_PAY_TWO_GOLD:
            {
                // Create Gift sword for PC to give to Sten
                UT_MoneyTakeFromObject(oPC, 0, 0, 2);
                break;
            }
            case STEN_MAIN_FARYN_OPENS_STORE:
            {
                //Open store.  Everything Faryn sells was pillaged from the dead soldiers at Ostagar,
                //so most of it should probably have heraldry for various Banns or the king.
                break;
            }
            case STEN_MAIN_LEAVES_FOREVER:
            {
                //ACTION: Sten leaves.
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_STEN_RECRUITED, FALSE, TRUE);
                WR_SetObjectActive(oSten, FALSE);
                // Codex entry for Sten leaving
                WR_SetPlotFlag(PLT_COD_CHA_STEN, COD_CHA_STEN_FIRED, TRUE);

                //Auto screenshot
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN2, AUTOSS_STE_STEN_ASKED_TO_LEAVE, TRUE, TRUE);

                break;
            }
            case STEN_MAIN_CHALLENGES_PC:
            {
                //ACTION: Sten attacks the player.

                // Drop Entire Party (Store Party)
                UT_PartyStore(TRUE);
                SetGroupId(oSten, 45);
                // Set Sten Immortal
                SetImmortal(oSten,TRUE);
                // Set Surrender Flags for Sten (variable table)
                WR_SetPlotFlag(PLT_GENPT_STEN_EVENTS, STEN_EVENTS_ON, TRUE);
                UT_SetSurrenderFlag(oSten, TRUE, PLT_GENPT_STEN_MAIN, STEN_MAIN_FIGHT_DEFEATED, TRUE);
                // Set other PCs to non combatants

                // Set Sten Hostile
                UT_CombatStart(oSten, oPC);
                // Any off comments from Party
                    // Nothing right now - Check soundsets?
                // Sten will attack with bare fists if he has to
                break;
            }
            case STEN_MAIN_FIGHT_DEFEATED:
            {
                // Restore Party Later on (Restore Party)
                UT_PartyRestore();
                // If PC loses the fight he's dead.
                break;
            }

            case STEN_MAIN_HAS_SWORD_BACK:
            {
                //ACTION: Gives sten his sword.
                CreateItemOnObject(rStenSwordReal, oSten, 1);
                // Add codex entry
                WR_SetPlotFlag(PLT_COD_CHA_STEN, COD_CHA_STEN_PLOT_COMPLETE, TRUE);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_COMPANIONS_5);

                break;
            }
            case STEN_MAIN_PC_RETRIEVES_SWORD:
            {
                // Create Gift sword for PC to give to Sten
                CreateItemOnObject(rStenSword, oSten, 1);
                break;
            }
            case STEN_MAIN_MOVES_TO_CAMP_WAYPOINT:
            {
                UT_LocalJump(oSten,WP_CAMP_GEN_FL_STEN);
                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        switch(nFlag)
        {
            case STEN_MAIN_PC_HAS_SIX_GOLD:
            {
                int nBribe = UT_MoneyCheck(oPC, 0, 0, 6);
                if(nBribe == TRUE)
                {
                    nResult = TRUE;
                }
                break;
            }
            case STEN_MAIN_PC_HAS_FIVE_GOLD:
            {
                // Qwinn:  This is checking for copper, not gold
                // int nBribe = UT_MoneyCheck(oPC,ORZ_FARYN_CASH_REQ_HIGH);
                int nBribe = UT_MoneyCheck(oPC,0,0,ORZ_FARYN_CASH_REQ_HIGH);
                if(nBribe == TRUE)
                {
                    nResult = TRUE;
                }
                break;
            }
            case STEN_MAIN_PC_HAS_FOUR_GOLD:
            {
                // Qwinn:  This is checking for copper, not gold
                // int nBribe = UT_MoneyCheck(oPC,ORZ_FARYN_CASH_REQ_MEDIUM);
                int nBribe = UT_MoneyCheck(oPC,0,0,ORZ_FARYN_CASH_REQ_MEDIUM);
                if(nBribe == TRUE)
                {
                    nResult = TRUE;
                }
                break;
            }
            case STEN_MAIN_PC_HAS_TWO_GOLD:
            {
                // Qwinn:  This is checking for copper, not gold
                // int nBribe = UT_MoneyCheck(oPC,ORZ_FARYN_CASH_REQ_LOW);
                int nBribe = UT_MoneyCheck(oPC,0,0,ORZ_FARYN_CASH_REQ_LOW);
                if(nBribe == TRUE)
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