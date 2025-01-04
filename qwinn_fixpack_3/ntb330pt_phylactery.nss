//::///////////////////////////////////////////////
//:: Plot Events
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for the phylactery in the ruins
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: Jan 26/07
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "ntb_constants_h"
#include "sys_audio_h"
#include "sys_rewards_h"

#include "plt_ntb330pt_phylactery"
#include "plt_ntb000pt_generic"
#include "plt_genpt_app_alistair"
#include "plt_genpt_app_leliana"
#include "plt_genpt_app_morrigan"
#include "plt_gen00pt_party"


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
    object oAltar = UT_GetNearestObjectByTag(oPC,NTB_IP_PHYLACTERY_ALTAR);
    object oPhylactery = UT_GetNearestObjectByTag(oPC,NTB_IP_PHYLACTERY);
    int nAlistair = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY);
    int nLeliana = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_IN_PARTY);
    int nMorrigan = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_IN_PARTY);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case NTB_PHYLACTERY_SPELL_EFFECT:
            {
                //----------------------------------------------------------------------
                // visual effect for spell
                //----------------------------------------------------------------------
                ApplyEffectVisualEffect(oPC,oPC,1033,EFFECT_DURATION_TYPE_TEMPORARY,0.0,0);
                RW_UnlockSpecializationTrainer(SPEC_WIZARD_ARCANE_WARRIOR);
                break;
            }
            case NTB_PHYLACTERY_ARCANE_WARRIOR_RELEASED:
            {

                //----------------------------------------------------------------------
                //ACTION: have a small explosion effect on the altar
                //ACTION: unlock the Arcane Warrior class
                //destroy phylactery
                //----------------------------------------------------------------------
                ApplyEffectVisualEffect(oAltar,oAltar,1005,EFFECT_DURATION_TYPE_TEMPORARY,0.0,0);

                WR_SetObjectActive(oPhylactery,FALSE);
                //Altar can't be interacted with any more
                SetObjectInteractive(oAltar, FALSE);

                //Good followers approve
                if (nAlistair == TRUE)
                {
                    WR_SetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_INC_LOW, TRUE, TRUE);
                }
                if (nLeliana == TRUE)
                {
                    WR_SetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_INC_LOW, TRUE, TRUE);
                }

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BRECILIAN_5a);

                break;
            }
            case NTB_PHYLACTERY_BETRAYED:
            {
                //----------------------------------------------------------------------
                //ACTION: Phylactery goes back on the ground - cold and dead
                //----------------------------------------------------------------------

                //Altar can't be interacted with any more
                SetObjectInteractive(oAltar, FALSE);

                //Good followers dissaprove
                if (nAlistair == TRUE)
                {
                    WR_SetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_DEC_MED, TRUE, TRUE);
                }
                if (nLeliana == TRUE)
                {
                    WR_SetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_DEC_LOW, TRUE, TRUE);
                }
                //Bad followers approve
                if (nMorrigan == TRUE)
                {
                    WR_SetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_INC_MED, TRUE, TRUE);
                }

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BRECILIAN_5a);

                break;
            }
            case NTB_PHYLACTERY_DROPPED:
            {
                //----------------------------------------------------------------------
                //ACTION: Phylactery back on the ground - still can be interacted with
                //----------------------------------------------------------------------

                break;
            }
            case NTB_PHYLACTERY_AUDIO_EVENT_36:
            {
                AudioTriggerPlotEvent(36);
                break;
            }
            case NTB_PHYLACTERY_AUDIO_EVENT_37:
            {
                AudioTriggerPlotEvent(37);
                break;
            }
            case NTB_PHYLACTERY_AUDIO_EVENT_38:
            {
                AudioTriggerPlotEvent(38);
                break;
            }
            case NTB_PHYLACTERY_AUDIO_EVENT_39:
            {
                AudioTriggerPlotEvent(9);
                break;
            }
            case NTB_PHYLACTERY_AUDIO_EVENT_40:
            {
                AudioTriggerPlotEvent(40);
                break;
            }
            case NTB_PHYLACTERY_AUDIO_EVENT_41:
            {
                AudioTriggerPlotEvent(41);
                break;
            }
            case NTB_PHYLACTERY_AUDIO_EVENT_49:
            {
                AudioTriggerPlotEvent(49);
                break;
            }
            case NTB_PHYLACTERY_AUDIO_EVENT_50:
            {
                AudioTriggerPlotEvent(50);
                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        switch(nFlag)
        {
            case NTB_PHYLACTERY_PC_TOLD_ABOUT_ARCANE_WARRIOR_NOT_HOW_TO_BREAK:
            {
                int nBreak = WR_GetPlotFlag(PLT_NTB330PT_PHYLACTERY,NTB_PHYLACTERY_PC_TOLD_HOW_TO_BREAK,TRUE);
                int nArcane = WR_GetPlotFlag(PLT_NTB330PT_PHYLACTERY,NTB_PHYLACTERY_PC_TOLD_ABOUT_ARCANE_WARRIOR,TRUE);
                //----------------------------------------------------------------------
                // if the PC doesn't know how to break the phylactery
                // and does know about the arcane warrior
                //----------------------------------------------------------------------
                if((nBreak == FALSE) && (nArcane == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_PHYLACTERY_PC_TOLD_HOW_TO_BREAK_AND_IN_ALTAR_ROOM:
            {
                int nBreak = WR_GetPlotFlag(PLT_NTB330PT_PHYLACTERY,NTB_PHYLACTERY_PC_TOLD_HOW_TO_BREAK,TRUE);
                int nAltar = WR_GetPlotFlag(PLT_NTB000PT_GENERIC,NTB_GENERIC_PC_IN_ALTAR_ROOM,TRUE);
                //----------------------------------------------------------------------
                // if the PC knows how to break the phylactery
                // and the PC is in the altar room
                //----------------------------------------------------------------------
                if((nBreak == TRUE) && (nAltar == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
        }
    }

    return nResult;
}