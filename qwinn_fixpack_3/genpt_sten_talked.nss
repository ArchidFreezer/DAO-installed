//::///////////////////////////////////////////////
//:: Plot Events for Sten Defined
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for Sten Talked
*/
//:://////////////////////////////////////////////
//:: Created By: Mark Barazzuol
//:: Created On: Oct 10/24/2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "plt_genpt_sten_defined"
#include "plt_genpt_sten_main"
#include "plt_genpt_sten_talked"
#include "plt_gen00pt_class_race_gend"
#include "plt_gen00pt_party"
#include "plt_cod_cha_sten"
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

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case STEN_TALKED_KNOWS_ABOUT_FARYN:
            {
                WR_SetPlotFlag(PLT_GENPT_STEN_MAIN,STEN_MAIN_KNOWS_ABOUT_FARYN,TRUE);
                break;
            }

            // Qwinn:  See the defined section for set of STEN_TALKED_KNOWS_ABOUT_FARM_MURDERS.
            // It's a main flag and should have been up here.  Also changing which plot activates codex entry.
            case STEN_TALKED_ABOUT_MURDER1:
            {
                // Adjust the Codex Entry
                WR_SetPlotFlag(PLT_COD_CHA_STEN, COD_CHA_STEN_MURDERS, TRUE);
                break;
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case STEN_TALKED_KNOWS_DWYN_HAS_SWORD:
            {
                // Qwinn:  Fix to skipping Faryn, this used to check STEN_TALKED_KNOWS_ABOUT_FARYN instead of DWYN
                // int nFarynTalked    = WR_GetPlotFlag(PLT_GENPT_STEN_TALKED,STEN_TALKED_KNOWS_ABOUT_FARYN,TRUE);
                int nFarynTalked    = WR_GetPlotFlag(PLT_GENPT_STEN_TALKED,STEN_TALKED_KNOWS_ABOUT_DWYN,TRUE);
                int nStenHasSword   = WR_GetPlotFlag(PLT_GENPT_STEN_MAIN,STEN_MAIN_PC_RETRIEVES_SWORD,TRUE);

                if(nFarynTalked && !nStenHasSword)
                {
                    nResult = TRUE;
                }
                break;
            }

            // Qwinn:  This was supposed to limit your getting the "I want to talk about something you mentioned"
            // option to when you actually had an option, but it didn't work (and wouldn't have even if not for
            // that last nResult = TRUE, since EVERY flag in the plot file gets checked and at least one will
            // always be true).  I added 4 plot variables set when each of the 4 dialogue chains has been
            // finished, to be used here.
            /*
            case STEN_TALKED_QUESTIONS:
            {
                // Counter
                int nCount;

                for (nCount = 0; nCount < 256; nCount++)
                {
                    // If any one of the talk options sten can talk about is true, this flag is true
                    if (WR_GetPlotFlag(PLT_GENPT_STEN_TALKED, nCount))
                        nResult = TRUE;
                }
                nResult = TRUE;
                break;
            }
            */
            case STEN_TALKED_QUESTIONS:
            {
                // Qwinn:  Needed to devise a way to do this without clearing any of the existing flags.
                // I can't find anywhere they're used other than these conversations, but don't want to risk
                // deactivating some later conversation I haven't found by clearing them.
                int nMagicStart = WR_GetPlotFlag(PLT_GENPT_STEN_TALKED,STEN_TALKED_ABOUT_MAGIC1,TRUE);
                int nReligStart = WR_GetPlotFlag(PLT_GENPT_STEN_TALKED,STEN_TALKED_ABOUT_RELIGION1,TRUE);
                int nSeherStart = WR_GetPlotFlag(PLT_GENPT_STEN_TALKED,STEN_TALKED_ABOUT_SEHERON1,TRUE);
                int nTamasStart = WR_GetPlotFlag(PLT_GENPT_STEN_TALKED,STEN_TALKED_ABOUT_TAMASSRANS1,TRUE);

                // Qwinn:  The third religion one doesn't require Warm. Can't be sure unintentional so not changing that.
                int nMagic3 = WR_GetPlotFlag(PLT_GENPT_STEN_TALKED,STEN_TALKED_ABOUT_MAGIC3,TRUE);
                int nSeher3 = WR_GetPlotFlag(PLT_GENPT_STEN_TALKED,STEN_TALKED_ABOUT_SEHERON3,TRUE);
                int nTamas3 = WR_GetPlotFlag(PLT_GENPT_STEN_TALKED,STEN_TALKED_ABOUT_TAMASSRANS3,TRUE);

                // Qwinn:  The third religion one doesn't require Warm
                int nCanSeeMagic3 = WR_GetPlotFlag(PLT_GENPT_STEN_DEFINED,STEN_DEFINED_APP_WARM_AND_TALKED_ABOUT_MAGIC3,TRUE);
                int nCanSeeSeher3 = WR_GetPlotFlag(PLT_GENPT_STEN_DEFINED,STEN_DEFINED_APP_WARM_AND_TALKED_ABOUT_SEHERON3,TRUE);
                int nCanSeeTamas3 = WR_GetPlotFlag(PLT_GENPT_STEN_DEFINED,STEN_DEFINED_APP_WARM_AND_TALKED_ABOUT_TAMASSRANS3,TRUE);

                int nMagicDone = WR_GetPlotFlag(PLT_QWINN,STEN_TALKED_ABOUT_MAGIC_DONE,TRUE);
                int nReligDone = WR_GetPlotFlag(PLT_QWINN,STEN_TALKED_ABOUT_RELIGION_DONE,TRUE);
                int nSeherDone = WR_GetPlotFlag(PLT_QWINN,STEN_TALKED_ABOUT_SEHERON_DONE,TRUE);
                int nTamasDone = WR_GetPlotFlag(PLT_QWINN,STEN_TALKED_ABOUT_TAMASSRANS_DONE,TRUE);

                if ( (nMagicStart && (!nMagicDone) && (nCanSeeMagic3 || (!nMagic3))) ||
                     (nReligStart && (!nReligDone))  ||
                     (nSeherStart && (!nSeherDone) && (nCanSeeSeher3 || (!nSeher3))) ||
                     (nTamasStart && (!nTamasDone) && (nCanSeeTamas3 || (!nTamas3)))
                   )
                {
                    nResult = TRUE;
                }

                break;
            }

            // Qwinn:  STEN_TALKED_KNOWS_ABOUT_FARM_MURDERS was never set previously, so you never got to ask
            // Sten about the farmers during his personal quest start.  I now set it when anyone tells you
            // about farmers in Lothering (via STEN_TOLD_MURDER), but that sets this codex entry which gives
            // more info than player has (player doesn't find out he was attacked by Darkspawn till the personal
            // quest.  Luckily, existing variable STEN_TALKED_ABOUT_MURDER1 gets set at the perfect time for
            // this codex entry.  Changing the case to that.
            // ALSO, for some reason this was in the defined section, should be in main flag section.  Moving it up.
            // EDIT:  Don't know if it was the reason it was done this way, but the fact that it was set up as
            // defined rather than a main flag is the only reason anyone ever saw that codex entry.  As a defined
            // flag, that code will run even if you're just checking the variable's value, don't need to set it
            // to get it to run.
            /* case STEN_TALKED_KNOWS_ABOUT_FARM_MURDERS:
            {
                // Adjust the Codex Entry
                WR_SetPlotFlag(PLT_COD_CHA_STEN, COD_CHA_STEN_MURDERS, TRUE);
                break;
            }
            */

        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}