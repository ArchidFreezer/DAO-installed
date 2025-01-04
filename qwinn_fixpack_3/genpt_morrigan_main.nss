//------------------------------------------------------------------------------
// genpt_morrigan_main
//------------------------------------------------------------------------------
//
//  Morrigan's 'main' plot script. Handles special case plot flag setting.
//
//  Associated with the 'genpt_morrigan_main.plo' plot file.
//
//------------------------------------------------------------------------------
// 2007/5/22 - Owner: Mark Barazzuol
//------------------------------------------------------------------------------

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "plt_gen00pt_party"
#include "plt_cod_cha_morrigan"
#include "plt_gen00pt_class_race_gend"
#include "cutscenes_h"
#include "plt_genpt_app_morrigan"

#include "plt_genpt_morrigan_main"
#include "plt_mnp000pt_autoss_main2"

#include "camp_constants_h"

// Qwinn added
#include "plt_genpt_morrigan_events"


// insult tracking variable, stored on module. *** double check
const string INSULT_COUNTER = "MORRIGAN_MAIN_INSULT_COUNTER";

int StartingConditional()
{
    event eParms = GetCurrentEvent(); // Contains all input parameters


    int nType   = GetEventType(eParms);         // GET or SET call
    int nFlag   = GetEventInteger(eParms, 1);   // The bit flag # being affected


    string strPlot = GetEventString(eParms, 0); // Plot GUID


    object oParty = GetEventCreator(eParms);   // The owner of the plot table for this script
    object oOwner = GetEventObject(eParms, 0); // Conversation owner, if any
    object oPC    = GetHero();                 // Player character
    object oFlem  = GetObjectByTag("pre211cr_flemeth");

    // Morrigan's Ring she gives the player
    resource rMorriganRing = R"gen_im_acc_rng_r09.uti";


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

                Log_Trace_Scripting_Error("xTest", "Entered Morrigain Plot Script", oPC);
        switch(nFlag)
        {

            case MORRIGAN_MAIN_AGREED_TO_TEACH_SHAPESHIFTING:
            {
//              Morrigan has agreed to teach the player the shape shifter class
                RW_UnlockSpecializationTrainer(SPEC_WIZARD_SHAPESHIFTER);
                break;
            }

            /*
                The player has insulted Morrigan, keep a counter.
            */
            case MORRIGAN_MAIN_INSULTED:
            {
                int nCount = GetLocalInt(GetModule(), INSULT_COUNTER);

                nCount++;

                SetLocalInt(GetModule(), INSULT_COUNTER, nCount);

                break;
            }
            case MORRIGAN_MAIN_FLEMITH_ALIVE:
            {
                resource rFlemethKey = R"pre200im_key_flemeth.uti";
                object oDragon = GetObjectByTag("pre210cr_dragon");

                // Gives PC the key to her hut
                CreateItemOnObject(rFlemethKey, oPC, 1, "", FALSE, TRUE);
                // Take key off dragon
                UT_RemoveItemFromInventory(rFlemethKey, 1, oDragon);

                break;
            }

            case MORRIGAN_MAIN_LEAVES_FOR_GOOD:
            {
                // Fire Morrigan
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_RECRUITED, FALSE, TRUE);
                SetObjectActive(GetObjectByTag(GEN_FL_MORRIGAN), FALSE);
                WR_SetPlotFlag(PLT_COD_CHA_MORRIGAN, COD_CHA_MORRIGAN_FIRED, TRUE);
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN2, AUTOSS_MOR_MORRIGAN_LEAVES_PARTY, TRUE, TRUE);
                break;
            }

            case MORRIGAN_MAIN_KISS:
            {
                resource rCutscene;

                int bHuman = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_RACE_HUMAN, TRUE);
                int bDwarf = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_RACE_DWARF, TRUE);
                int bElf   = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_RACE_ELF, TRUE);

                resource rMorriganKiss_Human      = CUTSCENE_MOR_KISS_HM;
                resource rMorriganKiss_Dwarf      = CUTSCENE_MOR_KISS_HD;
                resource rMorriganKiss_Elf        = CUTSCENE_MOR_KISS_HE;
                //  The player an Morrigan kiss.

                    // If Player is Human
                    if (bHuman)
                        rCutscene = rMorriganKiss_Human;

                    // If Player is Dwarf
                    if (bDwarf)
                        rCutscene = rMorriganKiss_Dwarf;

                    // If Player is Elf
                    if (bElf)
                        rCutscene = rMorriganKiss_Elf;

                    // And if the player is in the camp
                    if (rCutscene != INVALID_RESOURCE)
                        CS_LoadCutscene(rCutscene);

                break;
            }

            /*
                The player gives Morrigan the Grimoire.
            */
            case MORRIGAN_MAIN_GIVEN_GRIMOIRE:
            {
                // *** Handled in sp_module_item_acq

                // Qwinn added
                object oBlackGrimoire = GetItemPossessedBy(oPC,"gen_im_gift_grimoire");
                if (IsObjectValid(oBlackGrimoire))
                   RemoveItem(oBlackGrimoire,1);

                break;
            }

            /*
                The player gives Morrigan the real Grimoire.
            */
            case MORRIGAN_MAIN_GIVEN_REAL_GRIMOIRE:
            {
                // *** Code to start conv Handled in sp_module_item_acq
                // Sets friendly flag as well.

                //percentage complete plot tracking

                // Qwinn added
                object oRealGrimoire = GetItemPossessedBy(oPC,"gen_im_gift_flmgrimoire");
                if (IsObjectValid(oRealGrimoire))
                   RemoveItem(oRealGrimoire,1);
                // In case they have skipped the camp scene by gifting the grimoire outside of camp,
                // once grimoire is given we don't want that dialogue to trigger anymore
                WR_SetPlotFlag(PLT_GENPT_MORRIGAN_EVENTS, MORRIGAN_EVENT_FLEMITH_PLOT_COMPLETED,FALSE);

                WR_SetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_FRIENDLY_ELIGIBLE, TRUE, TRUE);
                ACH_TrackPercentageComplete(ACH_FAKE_COMPANIONS_3a);

                break;
            }

            case MORRIGAN_MAIN_PLAYER_KEPT_GRIMOIRE:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_COMPANIONS_3a);

                break;
            }

            case MORRIGAN_MAIN_FLEMITH_READY_TO_FIGHT:
            {
                // Flemeth moves to waypoint, Deactivate Flemeth, (Activate Dragon)
                object  oDragon         = GetObjectByTag("pre210cr_dragon");
                object  oFlemeth        = GetObjectByTag("pre211cr_flemeth");


                // Deactivate Flemeth
                SetObjectActive(oFlemeth, FALSE);
                // Activate Dragon
                SetObjectActive(oDragon, TRUE);
                
                // Qwinn added
                WR_SetPlotFlag(PLT_GENPT_MORRIGAN_MAIN, MORRIGAN_MAIN_FLEMITH_ALIVE, FALSE, FALSE);

                // UT_ExitDestroy(oFlem, FALSE, "pre210wp_dragon");
                break;
            }


            case MORRIGAN_MAIN_GIVE_PC_RING:
            {
//                Morrigan gives PC her ring.
                CreateItemOnObject(rMorriganRing, oPC);
                    nResult = TRUE;

                break;
            }
            case MORRIGAN_MAIN_MOVES_TO_CAMP_WAYPOINT:
            {
                object oMorrigan = UT_GetNearestCreatureByTag(oPC,GEN_FL_MORRIGAN);
                UT_LocalJump(oMorrigan,WP_CAMP_GEN_FL_MORRIGAN);
                break;
            }
        }
    }


    //--------------------------------------------------------------------------
    //    CONDITIONALS -> defined flags
    //--------------------------------------------------------------------------


    else
    {
        switch(nFlag)
        {

            /*
                Morrigan has been insulted once, and only once.
            */
            case MORRIGAN_MAIN_COUNTER_INSULTED_IS_1:
            {
                int nCount = GetLocalInt(GetModule(), INSULT_COUNTER);

                if (nCount == 1)
                    nResult = TRUE;

                break;
            }

            /*
                Morrigan has been insulted twice.
            */
            case MORRIGAN_MAIN_COUNTER_INSULTED_IS_2:
            {
                int nCount = GetLocalInt(GetModule(), INSULT_COUNTER);

                if (nCount == 2)
                    nResult = TRUE;

                break;
            }

            /*
                Morrigan has been insulted more than twice.
            */
            case MORRIGAN_MAIN_COUNTER_INSULTED_IS_3:
            {
                int nCount = GetLocalInt(GetModule(), INSULT_COUNTER);

                if (nCount > 2)
                    nResult = TRUE;

                break;
            }

            /*
                Morrigan has been insulted any number of times.
             */
            case MORRIGAN_MAIN_COUNTER_INSULTED_IS_NOT_ZERO:
            {
                int nCount = GetLocalInt(GetModule(), INSULT_COUNTER);

                if (nCount > 0)
                    nResult = TRUE;

                break;
            }




            /*
                DEBUG -> control should not reach this point.
             */
            default:
            {
                break;
            }

        }
    }


    plot_OutputDefinedFlag(eParms, nResult);


    return nResult;
}