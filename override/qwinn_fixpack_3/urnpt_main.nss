//------------------------------------------------------------------------------
//  urnpt_main.nss
//------------------------------------------------------------------------------
//
//  Plot scripting for the Main plot of the Urn of Sacred Ashes.
//
//------------------------------------------------------------------------------
//  Jan 10, 2007 - Created: Ferret
//  Oct 26, 2007 - Owner: Grant Mackay
//------------------------------------------------------------------------------

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "urn_constants_h"

#include "plt_mnp000pt_main_events"
#include "plt_mnp000pt_autoss_main"

#include "plt_urnpt_area_jumps"
#include "plt_urnpt_main"
#include "plt_urn100pt_haven"
#include "plt_urn200pt_temple"
#include "plt_urn200pt_cult"
#include "plt_urnpt_talked_to"

#include "plt_cod_cha_genitivi"
#include "plt_arl200pt_remove_demon"
#include "campaign_h"

#include "achievement_core_h"

#include "plt_qwinn"

int StartingConditional()
{

    event  eParms  = GetCurrentEvent();             // Contains all input parameters
    string strPlot = GetEventString(eParms, 0);     // Plot GUID

    int nType   = GetEventType(eParms);             // GET or SET call
    int nFlag   = GetEventInteger(eParms, 1);       // The bit flag # being affected
    int nResult = FALSE;                            // used to return value for DEFINED GET events

    object oPC   = GetHero();                       // The player
    object oThis = GetEventObject(eParms, 0);       // Owner on the conversation, if any

    object oTarg;

    plot_GlobalPlotHandler(eParms);                  // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT)                        // actions -> normal flags only
    {

        int nValue    = GetEventInteger(eParms, 2);         // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);         // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {


            //------------------------------------------------------------------
            // NON CONVERSATION SPECIFIC
            //------------------------------------------------------------------


            case URN_PLOT_DONE:
            {

                if(nOldValue == 0)
                {
                    WR_SetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, PLAYER_FINISHED_A_MAJOR_PLOT, TRUE, TRUE);
                }

                /*  Qwinn:  Need to comment out the COD_CHA_GENITIVI_RETURNS set, and that makes this whole block useless.
                if ( WR_GetPlotFlag(PLT_URN200PT_CULT, URN_TAINTED) )
                {
                    //WR_SetPlotFlag( PLT_COD_CHA_GENITIVI, COD_CHA_GENITIVI_URN_DESTROYED, TRUE );
                }

                else
                {
                    WR_SetPlotFlag( PLT_COD_CHA_GENITIVI, COD_CHA_GENITIVI_RETURNS, TRUE );
                }
                */

                break;

            }


            // The player can now travel to the village of Haven
            case HAVEN_OPENED:
            {
                //Take an automatic screenshot... the player should be in Genitivi's
                //back room.
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN, AUTOSS_URN_WEYLON_A_FRAUD, TRUE, TRUE);

                // Below is the REAL setting of the Haven village active on the world map
                object oHaven = GetObjectByTag(WML_WOW_URN_VILLAGE);
                WR_SetWorldMapLocationStatus(oHaven, WM_LOCATION_ACTIVE);

                break;

            }


            //------------------------------------------------------------------
            // FROM: URN110_GENITIVI
            //------------------------------------------------------------------


            // The PC gets a reward for his help with Genitivi
            case GENITIVI_REWARDS_PC:
            {
                // Qwinn added
                WR_SetPlotFlag(PLT_URNPT_MAIN, GENITIVI_RETURNS_TO_DENERIM, TRUE, FALSE);
                WR_SetPlotFlag(PLT_COD_CHA_GENITIVI, COD_CHA_GENITIVI_RETURNS, TRUE);
                break;
            }

            // Genitivi goes to Denerim
            case GENITIVI_RETURNS_TO_DENERIM:
            {
                /*  Qwinn replaced
                // Genitivi pops up in Denerim
                WR_SetPlotFlag( PLT_URNPT_AREA_JUMPS, GENITIVI_TO_DENERIM, TRUE);
                WR_SetPlotFlag(PLT_COD_CHA_GENITIVI, COD_CHA_GENITIVI_RETURNS, TRUE);

                object oGenitivi = UT_GetNearestCreatureByTag(oPC, URN_CR_GENITIVI, TRUE);
                WR_SetObjectActive(oGenitivi, FALSE);
                */
                if (WR_GetPlotFlag(PLT_URNPT_MAIN, GENITIVI_DENIED) == FALSE)
                {
                    WR_SetPlotFlag( PLT_URNPT_AREA_JUMPS, GENITIVI_TO_DENERIM, TRUE);
                    object oGenitivi = UT_GetNearestCreatureByTag(oPC, URN_CR_GENITIVI, TRUE);
                    WR_SetObjectActive(oGenitivi, FALSE);
                }
                break;

            }

            // Genitivi is attacked by the PC
            case GENITIVI_ATTACKED:
            {

                object oGenitivi = UT_GetNearestCreatureByTag(oPC, URN_CR_GENITIVI, TRUE);
                WR_SetObjectActive(oGenitivi, FALSE);
                WR_SetPlotFlag(PLT_COD_CHA_GENITIVI, COD_CHA_GENITIVI_DIES, TRUE);

                break;

            }

            // Genitivi runs in terror
            case GENITIVI_FLEES:
            {

                WR_SetPlotFlag( PLT_COD_CHA_GENITIVI, COD_CHA_GENITIVI_URN_DESTROYED, TRUE );
                object oGenitivi = UT_GetNearestCreatureByTag(oPC, URN_CR_GENITIVI, TRUE);
                WR_SetObjectActive(oGenitivi, FALSE);
                break;

            }

            // Genitivi's offer is shut down, he goes to Denerim
            case GENITIVI_DENIED:
            {
                // Genitivi goes away to Denerim
                WR_SetPlotFlag( PLT_URNPT_AREA_JUMPS, GENITIVI_TO_DENERIM, TRUE);
                // Qwinn commented out:
                // WR_SetPlotFlag(PLT_COD_CHA_GENITIVI, COD_CHA_GENITIVI_RETURNS, TRUE);
                WR_SetPlotFlag(PLT_URN100PT_HAVEN, GENITIVI_SENT_HOME, TRUE);

                object oGenitivi = UT_GetNearestCreatureByTag(oPC, URN_CR_GENITIVI, TRUE);
                WR_SetObjectActive(oGenitivi, FALSE);

                UT_DoAreaTransition(URN_AR_RUINED_TEMPLE, URN_WP_PC_TO_TEMPLE);

                object oTemple = GetObjectByTag(WML_WOW_URN_RUINS);
                WR_SetWorldMapLocationStatus(oTemple, WM_LOCATION_ACTIVE);

                break;

            }

            // Genitivi is with the player, heads to the temple
            case GENITIVI_FOLLOWS:
            {

                object oGenitivi = UT_GetNearestCreatureByTag(oPC, URN_CR_GENITIVI, TRUE);
                WR_SetObjectActive(oGenitivi, FALSE);

                UT_DoAreaTransition(URN_AR_RUINED_TEMPLE, URN_WP_PC_TO_TEMPLE);

                // He will reappear in the Ruined Temple
                WR_SetPlotFlag( PLT_URNPT_AREA_JUMPS, GENITIVI_TO_TEMPLE, TRUE);

                object oTemple = GetObjectByTag(WML_WOW_URN_RUINS);
                WR_SetWorldMapLocationStatus(oTemple, WM_LOCATION_ACTIVE);


                break;

            }


            //------------------------------------------------------------------
            // FROM: DEN110_WEYLON
            //------------------------------------------------------------------


            // Fake Weylon attacks and is killed
            case WEYLON_ATTACKS:
            {

                UT_CombatStart(oThis, oPC);
                break;

            }

            // The PC learns that Genitivi is missing.
            case HEARD_GENITIVI_IS_MISSING:
            {

                WR_SetPlotFlag(PLT_URNPT_MAIN, URN_PLOT_START, TRUE);
                WR_SetPlotFlag(PLT_COD_CHA_GENITIVI, COD_CHA_GENITIVI_STARTING_URN_QUEST, TRUE);
                break;

            }


            //------------------------------------------------------------------
            //  FROM: NRD110_INNKEEPER
            //------------------------------------------------------------------

            // Shady Patron leaves
            case INNKEEPER_BEING_WATCHED:
            {

                oTarg = GetObjectByTag(URN_CR_SHADY_PATRON);
                DestroyObject(oTarg, 0);
                break;

            }

            case INNKEEPER_CHECK_JOURNAL_STATE:
            {

                int bWeylonDead = WR_GetPlotFlag( PLT_URNPT_MAIN, WEYLON_DEAD );

                if( !bWeylonDead )
                {

                    WR_SetPlotFlag(PLT_URNPT_MAIN, INNKEEPER_REVEALS_SECRET, TRUE, TRUE);

                }

                break;

            }

            // Qwinn added
            case INNKEEPER_WATCHED_CHECK_JOURNAL_STATE:
            {
                Safe_Destroy_Object(GetObjectByTag("urn300cr_shady"));
                if( !WR_GetPlotFlag( PLT_URNPT_MAIN, WEYLON_DEAD ) )
                    WR_SetPlotFlag(PLT_URNPT_MAIN, INNKEEPER_BEING_WATCHED, TRUE, TRUE);
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

            // The Innkeeper has blabbed and the guys aren't killed
            case INNKEEPER_HAS_BLABBED:
            {

                // int bCondition1 = WR_GetPlotFlag( PLT_URNPT_MAIN, INNKEEPER_REVEALS_SECRET);
                // int bCondition2 = WR_GetPlotFlag( PLT_URNPT_MAIN, PC_AMBUSHED_AT_PRINCESS);

                int bCondition1 = WR_GetPlotFlag( PLT_URNPT_MAIN, INNKEEPER_CHECK_JOURNAL_STATE);
                int bCondition2 = WR_GetPlotFlag( PLT_QWINN, URN_INN_PC_AMBUSHED_CHECK_JOURNAL_STATE);


                nResult = bCondition1 && !bCondition2;

                break;
            }

            // Genitivi was brushed off and is awaiting news
            case GENITIVI_AWAITS_NEWS:
            {

                int bCondition1 = WR_GetPlotFlag(PLT_URNPT_MAIN, GENITIVI_DENIED);
                int bCondition2 = WR_GetPlotFlag(PLT_URN200PT_TEMPLE, PC_HAS_ASHES);

                nResult = bCondition1 && bCondition2;

                break;

            }

            // The dragon Andraste yet lives and the player has encoutnered it.
            case DRAGON_LIVES:
            {

                int bEncoun = WR_GetPlotFlag(PLT_URNPT_MAIN, PC_ENCOUNTERED_DRAGON);
                int bKilled = WR_GetPlotFlag(PLT_URNPT_MAIN, PC_KILLED_DRAGON);

                nResult = bEncoun && !bKilled;

                break;

            }

            // The player was sent by the fake Weylon and hasn't yet been ambushed.
            case PC_SENT_TO_INN_AND_NOT_AMBUSHED:
            {

                int bSent       = WR_GetPlotFlag(PLT_URNPT_MAIN, PC_SENT_TO_INN);
                // Qwinn changed
                // int bAmbush     = WR_GetPlotFlag(PLT_URNPT_MAIN, PC_AMBUSHED_AT_PRINCESS);
                int bAmbush     = WR_GetPlotFlag(PLT_QWINN, URN_INN_PC_AMBUSHED_CHECK_JOURNAL_STATE);
                int bGenitivi   = WR_GetPlotFlag(PLT_URNPT_MAIN, FOUND_GENITIV_IN_HAVEN);
                int bTalked     = WR_GetPlotFlag(PLT_URNPT_TALKED_TO, INNKEEPER_TALKED_ABOUT_CULT);

                nResult = bSent && !bAmbush && !bGenitivi && !bTalked;

                break;

            }

            // The player has killed the fake Weylon but not yet been ambushed.
            case PC_KILLED_WEYLON_AND_NOT_AMBUSHED:
            {

                int bKilled     = WR_GetPlotFlag(PLT_URNPT_MAIN, WEYLON_DEAD);
                // Qwinn changed
                // int bAmbush     = WR_GetPlotFlag(PLT_URNPT_MAIN, PC_AMBUSHED_AT_PRINCESS);
                int bAmbush     = WR_GetPlotFlag(PLT_QWINN, URN_INN_PC_AMBUSHED_CHECK_JOURNAL_STATE);
                int bGenitivi   = WR_GetPlotFlag(PLT_URNPT_MAIN, FOUND_GENITIV_IN_HAVEN);
                int bTalked     = WR_GetPlotFlag(PLT_URNPT_TALKED_TO, INNKEEPER_TALKED_ABOUT_CULT);

                nResult = bKilled && !bAmbush && !bGenitivi && !bTalked;

                break;
            }

            // Isolde is still around and the Arl Eamon plot has been completed.
            case PC_CAN_MENTION_ISOLDE:
            {
                // Qwinn added bKnowsArlSick check
                int bDemon  = WR_GetPlotFlag(PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_DEMON_DEALT_WITH);
                int bIsolde = WR_GetPlotFlag(PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_JOWAN_DOES_RITUAL);
                int bKnowsArlSick = WR_GetPlotFlag(PLT_URNPT_MAIN, GENITIVI_KNOWS_ARL_IS_SICK);

                nResult = bKnowsArlSick && bDemon && !bIsolde;

                break;

            }


        }

    }

    return nResult;

}