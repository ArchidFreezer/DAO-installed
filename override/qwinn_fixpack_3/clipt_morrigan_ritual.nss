// Morrigan's Ritual plot script

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "cli_constants_h"
#include "cutscenes_h"

#include "plt_clipt_morrigan_ritual"
#include "plt_gen00pt_party"
#include "plt_clipt_generic_actions"
#include "plt_gen00pt_class_race_gend"
#include "plt_cod_cha_morrigan"

#include "plt_qwinn"

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

    object oMorrigan = UT_GetNearestCreatureByTag(oPC, GEN_FL_MORRIGAN);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case MORRIGAN_RITUAL_WITH_ALISTAIR:
            case MORRIGAN_RITUAL_WITH_LOGHAIN:
            case MORRIGAN_RITUAL_WITH_PLAYER:
            {

                // clear 'convince' flags
                WR_SetPlotFlag(strPlot, MORRIGAN_RITUAL_CONVINCE_ALISTAIR, FALSE);
                WR_SetPlotFlag(strPlot, MORRIGAN_RITUAL_CONVINCE_LOGHAIN, FALSE);

                //--------------------------------------------------------
                // There are three cutscenes - human, dwarf, elf. The dwarf
                // and elf are straightforward - the male PC simply maps to
                // PLAYER. The human version is also used for Loghain
                // and Alistair, so it needs some custom mapping.
                //--------------------------------------------------------

                int bHuman = FALSE;
                string[] arActors;
                object[] arReplacements;
                arActors[0] = "player_placeholder";
                arReplacements[0] = oPC;

                if( nFlag == MORRIGAN_RITUAL_WITH_ALISTAIR )
                {
                    bHuman = TRUE;
                    arReplacements[0] = UT_GetNearestCreatureByTag(oPC, GEN_FL_ALISTAIR);
                }
                else if( nFlag == MORRIGAN_RITUAL_WITH_LOGHAIN )
                {
                    bHuman = TRUE;
                    arReplacements[0] = UT_GetNearestCreatureByTag(oPC, GEN_FL_LOGHAIN);
                }
                else if( WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_RACE_HUMAN) == TRUE )
                {
                    bHuman = TRUE;
                    // arReplacements[0] defaults to oPC
                }

                if(bHuman)
                {
                    CS_LoadCutsceneWithReplacements(CUTSCENE_CLI_MORRIGAN_RITUAL_HM,
                        arActors, arReplacements,
                        PLT_CLIPT_GENERIC_ACTIONS, CLI_ACTIONS_START_MARCH_CUTSCENE);
                }
                else
                {
                    if(WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_RACE_DWARF) == TRUE)
                    {
                        CS_LoadCutscene(CUTSCENE_CLI_MORRIGAN_RITUAL_DM, PLT_CLIPT_GENERIC_ACTIONS,
                            CLI_ACTIONS_START_MARCH_CUTSCENE);
                    }
                    else if(WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_RACE_ELF) == TRUE)
                    {
                        CS_LoadCutscene(CUTSCENE_CLI_MORRIGAN_RITUAL_EM, PLT_CLIPT_GENERIC_ACTIONS,
                            CLI_ACTIONS_START_MARCH_CUTSCENE);
                    }
                }

                //percentage complete plot tracking
                if(nFlag == MORRIGAN_RITUAL_WITH_ALISTAIR)
                {
                    ACH_TrackPercentageComplete(ACH_FAKE_FINAL_1b);
                }
                else if(nFlag == MORRIGAN_RITUAL_WITH_LOGHAIN)
                {
                    ACH_TrackPercentageComplete(ACH_FAKE_FINAL_1c);
                }
                else
                {
                    ACH_TrackPercentageComplete(ACH_FAKE_FINAL_1d);
                }

                break;
            }
            case MORRIGAN_RITUAL_KNOWN:
            {
                // Codex entry for offer
                // Qwinn replaced this with qwinn:CLI_PC_KNOWS_RITUAL
                // This flag means Ali/Log know what the ritual is for
                // WR_SetPlotFlag(PLT_COD_CHA_MORRIGAN, COD_CHA_MORRIGAN_OFFER, TRUE);
                if (nValue == 1)
                   WR_SetPlotFlag(PLT_QWINN,CLI_RITUAL_MENTIONED,TRUE);
                break;
            }


            case MORRIGAN_RITUAL_REFUSED:
            {
                // clear 'convince' flags
                WR_SetPlotFlag(strPlot, MORRIGAN_RITUAL_CONVINCE_ALISTAIR, FALSE);
                WR_SetPlotFlag(strPlot, MORRIGAN_RITUAL_CONVINCE_LOGHAIN, FALSE);

                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_RECRUITED, FALSE, TRUE);
                WR_SetPlotFlag(PLT_COD_CHA_MORRIGAN, COD_CHA_MORRIGAN_OFFER_REFUSED, TRUE);
                //CS_LoadCutscene(CUTSCENE_CLI_MORRIGAN_LEAVES, PLT_CLIPT_GENERIC_ACTIONS,
                //    CLI_ACTIONS_START_MARCH_CUTSCENE);
                //Cutscene was pulled into the dialog, so now just call the plot flag
                //that the end script would have called.
                WR_SetPlotFlag(PLT_CLIPT_GENERIC_ACTIONS, CLI_ACTIONS_START_MARCH_CUTSCENE, TRUE, TRUE);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_FINAL_1a);

                break;
            }
            case MORRIGAN_RITUAL_RETURN_TO_MORRIGAN:
            {
                UT_Talk(oMorrigan, oPC);
                break;
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case MORRIGAN_RITUAL_CONVINCE_ALISTAIR_OR_LOGHAIN:
            {
                if(WR_GetPlotFlag(strPlot, MORRIGAN_RITUAL_CONVINCE_ALISTAIR) ||
                    WR_GetPlotFlag(strPlot, MORRIGAN_RITUAL_CONVINCE_LOGHAIN))
                        nResult = TRUE;
                break;
            }
            case MORRIGAN_RITUAL_DONE:
            {
                if(WR_GetPlotFlag(strPlot, MORRIGAN_RITUAL_WITH_ALISTAIR) ||
                    WR_GetPlotFlag(strPlot, MORRIGAN_RITUAL_WITH_LOGHAIN) ||
                    WR_GetPlotFlag(strPlot, MORRIGAN_RITUAL_WITH_PLAYER))
                        nResult = TRUE;
                break;
            }
            case MORRIGAN_RITUAL_NOT_REFUSED_AND_KNOWN:
            {
                if(!WR_GetPlotFlag(strPlot, MORRIGAN_RITUAL_REFUSED) &&
                    WR_GetPlotFlag(strPlot, MORRIGAN_RITUAL_KNOWN))
                    nResult = TRUE;
                break;
            }

        }

    }

    return nResult;
}