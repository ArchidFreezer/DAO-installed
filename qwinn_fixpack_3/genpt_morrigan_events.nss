//------------------------------------------------------------------------------
// genpt_morrigan_events
//------------------------------------------------------------------------------
//
//  Morrigan's 'events' plot script. Handles special case event setting where
//  the 'EVENT_ON' flag must also be set.
//
//  Associated with the 'genpt_morrigan_events.plo' plot file.
//
//------------------------------------------------------------------------------
// 2007/5/22 - Owner: Grant Mackay
//------------------------------------------------------------------------------

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "cutscenes_h"

#include "plt_genpt_morrigan_events"
#include "plt_genpt_app_morrigan"
#include "plt_cir000pt_main"
#include "plt_genpt_morrigan_events"
#include "plt_gen00pt_class_race_gend"
#include "plt_genpt_morrigan_main"
#include "plt_mnp000pt_autoss_main2"
// Qwinn: Adding for recruit check below.
#include "plt_gen00pt_party"

int StartingConditional()
{
    event eParms = GetCurrentEvent(); // Contains all input parameters


    int nType   = GetEventType(eParms);         // GET or SET call
    int nFlag   = GetEventInteger(eParms, 1);   // The bit flag # being affected


    string strPlot = GetEventString(eParms, 0); // Plot GUID


    object oParty = GetEventCreator(eParms);   // The owner of the plot table for this script
    object oOwner = GetEventObject(eParms, 0); // Conversation owner, if any
    object oPC    = GetHero();                 // Player character

    int bHuman = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_RACE_HUMAN, TRUE);
    int bDwarf = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_RACE_DWARF, TRUE);
    int bElf   = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_RACE_ELF, TRUE);

    // Sex scenes with Morrigan
    resource rMorriganSex_HumanMale = CUTSCENE_MOR_SEX_HUMAN;
    resource rMorriganSex_DwarfMale = CUTSCENE_MOR_SEX_DWARF;
    resource rMorriganSex_ElfMale   = CUTSCENE_MOR_SEX_ELF;

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info


    int nResult = FALSE; // return value for DEFINED GET events


    //--------------------------------------------------------------------------
    //    ACTIONS -> normal flags
    //--------------------------------------------------------------------------


    if(nType == EVENT_TYPE_SET_PLOT)
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {


            case MORRIGAN_EVENT_AFTER_MAKE_LOVE:
            {
                if (nValue == TRUE)
                {
                    WR_SetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_MAKE_LOVE, TRUE, TRUE);

                    UT_Talk(GetObjectByTag(GEN_FL_MORRIGAN), oPC);
                }

                break;
            }
            case MORRIGAN_EVENT_MAKE_LOVE:
            {
                resource rCutscene;

                // remove gore from Morrigan and player
                object oMorrigan = UT_GetNearestObjectByTag(oPC, GEN_FL_MORRIGAN);
                Gore_RemoveAllGore(oPC);
                Gore_RemoveAllGore(oMorrigan);

                if (nValue == TRUE)
                {
                    // If Player is Human
                    if (bHuman)
                        rCutscene = rMorriganSex_HumanMale;

                    // If Player is Dwarf
                    if (bDwarf)
                        rCutscene = rMorriganSex_DwarfMale;

                    // If Player is Elf
                    if (bElf)
                        rCutscene = rMorriganSex_ElfMale;


                    // Play proper cutscene (assuming one was picked.)
                    if (rCutscene != INVALID_RESOURCE)
                    {
                        WR_SetPlotFlag(PLT_GENPT_MORRIGAN_EVENTS, MORRIGAN_EVENT_ON, TRUE);
                        CS_LoadCutscene(rCutscene, PLT_GENPT_MORRIGAN_EVENTS, MORRIGAN_EVENT_AFTER_MAKE_LOVE);
                    }

                }
                break;
            }

            case MORRIGAN_EVENT_ROMANCE_ENDED:
            {

                // This event is no longer used.
                // Qwinn:  Maybe not, but this flag is used in a bunch of places
                // Making it more useful by adding CAN_NOT_RESTART, and making sure the romance flag is cleared
                // by letting the ROMANCE_CUT_OFF script run
                // WR_SetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_CUT_OFF, TRUE);
                WR_SetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_CUT_OFF, TRUE, TRUE);
                WR_SetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_CAN_NOT_RESTART, TRUE, TRUE);
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN2, AUTOSS_MOR_BREAKING_UP_WITH_MORRIGAN, TRUE, TRUE);

                break;
            }

        }  // End switch
    }


    //--------------------------------------------------------------------------
    //    CONDITIONALS -> defined flags
    //--------------------------------------------------------------------------


    else
    {
        switch(nFlag)
        {
            case MORRIGAN_EVENT_READ_GRIMOIRE:
            {
                int bCirPlot = (WR_GetPlotFlag(PLT_CIR000PT_MAIN, BROKEN_CIRCLE_PLOT_DONE));
                int bGotGrimoire = (WR_GetPlotFlag(PLT_GENPT_MORRIGAN_MAIN, MORRIGAN_MAIN_GIVEN_GRIMOIRE));
                // Qwinn:  Adding check to make sure Morrigan hasn't been asked to leave the party
                int bRecruited = (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_RECRUITED));

                // If Morrigan has the grimoire, done the circle plot and player
                // is in camp resolve as true.
                if (bCirPlot && bGotGrimoire && bRecruited)
                    nResult = TRUE;


                break;

            } // end Case
        } // End switch
    }


    plot_OutputDefinedFlag(eParms, nResult);


    return nResult;
}