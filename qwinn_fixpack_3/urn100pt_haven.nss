//------------------------------------------------------------------------------
//  urn100pt_haven.nss
//------------------------------------------------------------------------------
//
//  Plot scripting for the Haven/Cultist Vilalge plot of the Urn of Sacred Ashes
//
//------------------------------------------------------------------------------
//  Jan 10, 2007 - Created: Ferret
//  Oct 26, 2007 - Owner: Grant Mackay
//------------------------------------------------------------------------------

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "sys_audio_h"

#include "cutscenes_h"

#include "urn_functions_h"

#include "plt_urn100pt_haven"
#include "plt_urnpt_area_jumps"
#include "plt_mnp000pt_autoss_main"

int StartingConditional()
{

    event  eParms  = GetCurrentEvent();             // Contains all input parameters
    string strPlot = GetEventString(eParms, 0);     // Plot GUID

    int nType   = GetEventType(eParms);             // GET or SET call
    int nFlag   = GetEventInteger(eParms, 1);       // The bit flag # being affected
    int nResult = FALSE;                            // used to return value for DEFINED GET events

    object oPC   = GetHero();                         // The player
    object oThis = GetEventObject(eParms, 0);         // Owner on the conversation, if any
    object oExit = GetObjectByTag(URN_WP_TO_CHANTRY); // Exit waypoint for the area

    object oTarg;

    plot_GlobalPlotHandler(eParms);                  // any global plot operations, including debug info


    // actions -> normal flags only
    if(nType == EVENT_TYPE_SET_PLOT)
    {
        int nValue    = GetEventInteger(eParms, 2);         // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);         // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!

        switch(nFlag)
        {

            //------------------------------------------------------------------
            //  NON-SPECIFIC
            //------------------------------------------------------------------

            // Qwinn added
            case PC_ACQUIRED_MEDALLION:
            {
               WR_SetPlotFlag(PLT_URN100PT_HAVEN, PC_NEEDS_MEDALLION, FALSE );
               break;
            }


            case FOUND_BLOODY_ALTAR:
            {

                WR_SetPlotFlag(PLT_URN100PT_HAVEN, SOMETHING_AFOOT_IN_HAVEN, TRUE );
                break;
            }


            case FOUND_KNIGHTS:
            {
                //Take a screenshot, hopefully of the knight
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN, AUTOSS_URN_FOUND_DEAD_KNIGHT, TRUE, TRUE);

                WR_SetPlotFlag(PLT_URN100PT_HAVEN, SOMETHING_AFOOT_IN_HAVEN, TRUE );
                break;
            }



            //------------------------------------------------------------------
            //  FROM: URN110_EIRIK
            //------------------------------------------------------------------


            case VILLAGE_GOES_HOSTILE:
            {

                URN_RemoveChantryVillagers();

                // Eirik and some of his men attack
                oTarg = GetObjectByTag(URN_CR_EIRIK);

                UT_CombatStart(oTarg, oPC);

                int i;

                for (i = 0; i < URN_N_CHANTRY_GUARDS; ++i)
                {

                    oTarg = GetObjectByTag(URN_CR_CH_GUARD + IntToString(i));

                    UT_CombatStart(oTarg, oPC);

                }

                // An ambush is set up outside the Chantry
                oTarg = GetObjectByTag(URN_CR_CH_VILLAGER);
                WR_SetObjectActive(oTarg, FALSE);
                oTarg = GetObjectByTag(URN_CR_HAVEN_CHILD);
                WR_SetObjectActive(oTarg, FALSE);
                oTarg = GetObjectByTag(URN_CR_HAVEN_VILLAGER);
                WR_SetObjectActive(oTarg, FALSE);
                oTarg = GetObjectByTag(URN_CR_SHOPKEEPER);
                WR_SetObjectActive(oTarg, FALSE);
                oTarg = GetObjectByTag(URN_CR_HAVEN_GUARD);
                WR_SetObjectActive(oTarg, FALSE);

                UT_TeamAppears(URN_TEAM_VILLAGE_AMBUSH);

                break;

            }


            // An ambush is set up outside
            case VILLAGE_SET_FOR_AMBUSH:
            {

                // An ambush is set up outside the Chantry
                oTarg = GetObjectByTag(URN_CR_CH_VILLAGER);
                WR_SetObjectActive(oTarg, FALSE);
                oTarg = GetObjectByTag(URN_CR_HAVEN_CHILD);
                WR_SetObjectActive(oTarg, FALSE);
                oTarg = GetObjectByTag(URN_CR_HAVEN_VILLAGER);
                WR_SetObjectActive(oTarg, FALSE);
                oTarg = GetObjectByTag(URN_CR_SHOPKEEPER);
                WR_SetObjectActive(oTarg, FALSE);
                oTarg = GetObjectByTag(URN_CR_HAVEN_GUARD);
                WR_SetObjectActive(oTarg, FALSE);

                UT_TeamAppears(URN_TEAM_VILLAGE_AMBUSH);

                break;

            }

            // All of the villagers leave the sermon
            case VILLAGERS_LEAVE_SERMON:
            {

                URN_RemoveChantryVillagers();
                break;

            }

            // Audio event during eirik conversation.
            case HAVEN_SERMON_INTERRUPTED_AUDIO:
            {
                AudioTriggerPlotEvent(66);
                break;
            }


            //------------------------------------------------------------------
            //  FROM: URN130_SHOPKEEP
            //------------------------------------------------------------------


            case SHOPKEEPER_KILLED:
            {
                // The village alarm is set
                WR_SetPlotFlag(PLT_URN100PT_HAVEN, ALARM_RAISED, TRUE);

                UT_CombatStart(oThis, oPC);

                break;
            }


            //------------------------------------------------------------------
            //  FROM: URN100_CHILD
            //------------------------------------------------------------------


            case CHILD_RUNS_AWAY:
            {

                DestroyObject(oThis, 0);
                break;

            }


            //------------------------------------------------------------------
            //  FROM: URN110_GENITIVI
            //------------------------------------------------------------------


            case GENIVITI_TRANSPORTS_TO_TEMPLE:
            {

                // Set up Genitivi's move
                WR_SetObjectActive(oThis, FALSE);
                WR_SetPlotFlag(PLT_URNPT_AREA_JUMPS, GENITIVI_TO_TEMPLE, TRUE);

                // Move the PC
                UT_DoAreaTransition(URN_AR_RUINED_TEMPLE, URN_WP_PC_TO_TEMPLE);

                // Make the ruined temple available on the world map.
                object oPin = GetObjectByTag("wml_wow_urn_ruins");

                WR_SetWorldMapLocationStatus(oPin, 2);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_URN_1);

                break;

            }

        }

    }



    //--------------------------------------------------------------------------
    // EVENT_TYPE_GET_PLOT -> defined conditions only
    //--------------------------------------------------------------------------



    else
    {

        switch(nFlag)
        {

            case FOUND_WEIRDNESS_IN_HOUSES:
            {

                int bCondition1 = WR_GetPlotFlag(PLT_URN100PT_HAVEN, FOUND_BLOODY_ALTAR);
                int bCondition2 = WR_GetPlotFlag(PLT_URN100PT_HAVEN, FOUND_KNIGHTS);

                nResult = bCondition1 || bCondition2;

                break;

            }


            // Does the PC have Eirik's medallion?
            // Qwinn:  Added "And hasn't told Genitivi he has it yet", since it is only checked
            // for that purpose and we don't want the option to appear more than once.
            case PC_HAS_MEDALLION:
            {   resource rMedal = R"urn110ip_medallion.uti";
                int bHasMedallion  = UT_CountItemInInventory(rMedal);
                int bNeedMedallion = WR_GetPlotFlag(PLT_URN100PT_HAVEN, PC_NEEDS_MEDALLION);

                if (bHasMedallion && bNeedMedallion)
                   nResult = TRUE;
                break;
            }

        }

    }

    return nResult;

}