//==============================================================================
/*
    bpsk_spiders_knives_plot.nss
    This tracks the quest to rescue Ser Arbither and liberate Knife Edge Manor.
*/
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "sys_ambient_h"

#include "lot_constants_h"

#include "plt_bpsk_rescue_knives"
#include "plt_bpsk_retake_manor"
#include "plt_bp_spiders_knives"

//------------------------------------------------------------------------------

int StartingConditional()
{
    event   eParms              =   GetCurrentEvent();              // Contains all input parameters

    int     nType               =   GetEventType(eParms);           // GET or SET call
    int     nFlag               =   GetEventInteger(eParms, 1);     // The bit flag # being affected
    int     nResult             =   FALSE;                          // used to return value for DEFINED GET events

    string  strPlot             =   GetEventString(eParms, 0);      // Plot GUID

    object  oParty              =   GetEventCreator(eParms);        // The owner of the plot table for this script
    object  oConversationOwner  =   GetEventObject(eParms, 0);      // Owner on the conversation, if any
    object  oPC                 =   GetHero();
    object  oKnives             =   GetObjectByTag("bpsk_knives");

    plot_GlobalPlotHandler(eParms);                                 // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue      =   GetEventInteger(eParms, 2);             // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue   =   GetEventInteger(eParms, 3);             // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case BPSK_COCOONS_FOUND:
            {

                if (!(WR_GetPlotFlag(PLT_BPSK_RESCUE_KNIVES,KNIVES_FOUND)))
                {
                    // Apply plot flag and glow to cocoon.
                    object oCocoon = GetObjectByTag("bpsk_cocoon_knives");
                    if (IsObjectValid(oCocoon))
                    {
                        SetPlotGiver(oCocoon,TRUE);
                        ApplyEffectVisualEffect(oCocoon, oCocoon, 5020, EFFECT_DURATION_TYPE_PERMANENT,0.0);
                    }else{
                        DisplayFloatyMessage(oPC,"Cocoon not found.",FLOATY_MESSAGE,0xff0000,10.0);
                    }
                }
                break;
            }

            case BPSK_MANOR_ATTACK:
            {
                // Knife edge Manor about to be attacked by darkspawn - move inhabitants around.
                // Prepare Templars & Knives
                object oTemplar_wp = GetObjectByTag("wp_templars");
                object oTemplar = GetObjectByTag("bpsk_templar");
                WR_AddCommand(oTemplar,CommandMoveToObject(oTemplar_wp,FALSE),TRUE,TRUE);
//                Ambient_MoveRandom(oTemplar,2,FALSE);
                oTemplar = GetObjectByTag("bpsk_matron_guard");
                WR_AddCommand(oTemplar,CommandMoveToObject(oTemplar_wp,FALSE),TRUE,TRUE);
//                Ambient_MoveRandom(oTemplar,2,FALSE);
//                WR_AddCommand(oKnives,CommandMoveToObject(oTemplar_wp,FALSE),TRUE,TRUE);
                Ambient_Start(oKnives,1,5,"",24,-1.0);
//                Ambient_MoveRandom(oKnives,2,FALSE);
//                UT_TeamMove(8,"wp_templars",FALSE,1.5,FALSE);
                Ambient_StartTeam(8);

                // Scared servants
                object oServant = GetObjectByTag("arl200cr_servant");
                object oFear_wp1 = GetObjectByTag("wp_fear1");
                object oFear_wp2 = GetObjectByTag("wp_fear2");
                WR_AddCommand(oServant,CommandMoveToObject(oFear_wp1,TRUE),TRUE,TRUE);
                AddCommand (oServant, CommandWait (120.0), FALSE, TRUE, COMMAND_ADDBEHAVIOR_DONTCLEAR);
                Ambient_Start(oServant,1,5,"",95,-1.0);
//                Ambient_MoveRandom(oServant,2,FALSE);
                oServant = GetObjectByTag("bpsk_cook");
                WR_AddCommand(oServant,CommandMoveToObject(oFear_wp2,TRUE),TRUE,TRUE);
                AddCommand (oServant, CommandWait (120.0), FALSE, TRUE, COMMAND_ADDBEHAVIOR_DONTCLEAR);
                Ambient_Start(oServant,1,5,"",117,-1.0);
//                Ambient_MoveRandom(oServant,2,FALSE);
                oServant = GetObjectByTag("bhn100cr_kitchen_servant_f");
                WR_AddCommand(oServant,CommandMoveToObject(oFear_wp2,TRUE),TRUE,TRUE);
                AddCommand (oServant, CommandWait (120.0), FALSE, TRUE, COMMAND_ADDBEHAVIOR_DONTCLEAR);
                Ambient_Start(oServant,1,5,"",96,-1.0);
//                Ambient_MoveRandom(oServant,2,FALSE);
                oServant = GetObjectByTag("bhn100cr_kitchen_servant_m");
                WR_AddCommand(oServant,CommandMoveToObject(oFear_wp2,TRUE),TRUE,TRUE);
                AddCommand (oServant, CommandWait (120.0), FALSE, TRUE, COMMAND_ADDBEHAVIOR_DONTCLEAR);
                Ambient_Start(oServant,1,5,"",99,-1.0);
//                Ambient_MoveRandom(oServant,2,FALSE);
                oServant = GetObjectByTag("bhn100cr_servant_f");
                WR_AddCommand(oServant,CommandMoveToObject(oFear_wp1,TRUE),TRUE,TRUE);
                AddCommand (oServant, CommandWait (120.0), FALSE, TRUE, COMMAND_ADDBEHAVIOR_DONTCLEAR);
                Ambient_Start(oServant,1,5,"",129,-1.0);
//                Ambient_MoveRandom(oServant,2,FALSE);
                oServant = GetObjectByTag("bhn100cr_servant_m");
                WR_AddCommand(oServant,CommandMoveToObject(oFear_wp1,TRUE),TRUE,TRUE);
                AddCommand (oServant, CommandWait (120.0), FALSE, TRUE, COMMAND_ADDBEHAVIOR_DONTCLEAR);
                Ambient_Start(oServant,1,5,"",117,-1.0);
//                Ambient_MoveRandom(oServant,2,FALSE);
                oServant = GetObjectByTag("den211cr_scullion");
                WR_AddCommand(oServant,CommandMoveToObject(oFear_wp1,TRUE),TRUE,TRUE);
                AddCommand (oServant, CommandWait (120.0), FALSE, TRUE, COMMAND_ADDBEHAVIOR_DONTCLEAR);
                Ambient_Start(oServant,1,5,"",61,-1.0);
//                Ambient_MoveRandom(oServant,2,FALSE);
                oServant = GetObjectByTag("den212cr_maid_1");
                WR_AddCommand(oServant,CommandMoveToObject(oFear_wp1,TRUE),TRUE,TRUE);
                AddCommand (oServant, CommandWait (120.0), FALSE, TRUE, COMMAND_ADDBEHAVIOR_DONTCLEAR);
                Ambient_Start(oServant,1,5,"",63,-1.0);
//                Ambient_MoveRandom(oServant,2,FALSE);
                oServant = GetObjectByTag("den212cr_maid_2");
                WR_AddCommand(oServant,CommandMoveToObject(oFear_wp1,TRUE),TRUE,TRUE);
                AddCommand (oServant, CommandWait (120.0), FALSE, TRUE, COMMAND_ADDBEHAVIOR_DONTCLEAR);
                Ambient_Start(oServant,1,5,"",95,-1.0);
//                Ambient_MoveRandom(oServant,2,FALSE);
                oServant = GetObjectByTag("den212cr_servant");
                WR_AddCommand(oServant,CommandMoveToObject(oFear_wp1,TRUE),TRUE,TRUE);
                AddCommand (oServant, CommandWait (120.0), FALSE, TRUE, COMMAND_ADDBEHAVIOR_DONTCLEAR);
                Ambient_Start(oServant,1,5,"",116,-1.0);
//                Ambient_MoveRandom(oServant,2,FALSE);

               break;
            }

            case BPSK_EPI_SLIDESHOW:
            {
                BeginSlideshow(R"bpsk_knives.dlg");
                break;
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {


        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}