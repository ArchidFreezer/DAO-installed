//------------------------------------------------------------------------------
// genpt_morrigan_defined
//------------------------------------------------------------------------------
//
//  Morrigan's 'defined' plot script. Handles compounded conditionals within
//  the morrigan_main dialog.
//
//  Associated with the 'genpt_morrigan_defined.plo' plot file.
//
//
//  **** TBD:
//
//       1) Determine if the player has Flemith's Grimoire for the check:
//
//          MORRIGAN_DEFINED_PLAYER_HAS_GRIMOIRE
//
//       2) Determine if the player has Flemith's Real Grimoire for the check:
//
//          MORRIGAN_DEFINED_PLAYER_HAS_REAL_GRIMOIRE
//
//       3) Determine if the ritual has actually been completed for the check:
//
//          MORRIGAN_DEFINED_RITUAL_COMPLETED
//
//
//
//------------------------------------------------------------------------------
// 2007/5/22 - Owner: Grant Mackay
//------------------------------------------------------------------------------

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "plt_arl100pt_enter_castle"
#include "plt_arl200pt_remove_demon"
// Qwinn:  Need to replace this:
// #include "plt_denpt_anora"
#include "plt_denpt_main"
#include "plt_clipt_main"

#include "plt_genpt_morrigan_main"
#include "plt_genpt_morrigan_defined"
#include "plt_genpt_morrigan_talked"
#include "plt_genpt_app_morrigan"

#include "plt_gen00pt_class_race_gend"
#include "plt_mnp000pt_generic"

#include "plt_genpt_app_alistair"
#include "plt_genpt_app_leliana"
#include "plt_genpt_app_zevran"
#include "plt_cir000pt_main"
#include "plt_clipt_morrigan_ritual"

int StartingConditional()
{
    event eParms = GetCurrentEvent(); // Contains all input parameters


    int nType   = GetEventType(eParms);       // GET or SET call
    int nFlag   = GetEventInteger(eParms, 1); // The bit flag # being affected


    string strPlot = GetEventString(eParms, 0); // Plot GUID


    object oParty = GetEventCreator(eParms);   // The owner of the plot table for this script
    object oOwner = GetEventObject(eParms, 0); // Conversation owner, if any
    object oPC    = GetHero();                 // Player character


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
        }
    }


    //--------------------------------------------------------------------------
    //    CONDITIONALS -> defined flags
    //--------------------------------------------------------------------------


    else
    {

        switch(nFlag)
        {

            case MORRIGAN_DEFINED_ADORE_BUT_NOT_IN_LOVE:
            {
                //IF: APP_MORRIGAN_IS_ADORE
                //and IF (NOT): APP_MORRIGAN_IS_IN_LOVE
                int nAdore = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_IS_ADORE, TRUE);
                int nInLove = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_IS_IN_LOVE, TRUE);
                if((nAdore == TRUE) && (nInLove == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case MORRIGAN_DEFINED_IN_LOVE_OR_MAKE_LOVE:
            {
                int bMadeLove = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_MAKE_LOVE);
                int bInLove   = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_IS_IN_LOVE);

                if (bMadeLove || bInLove)
                    nResult = TRUE;
                break;
            }
            /*
                Morrigan adores the player, her romance is active and it has
                not yet been discussed.
            */
            case MORRIGAN_DEFINED_ADORE_NOT_TALKED_ABOUT_ADORE:
            {
                int bRomance = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_ACTIVE);
                int bAdore   = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_IS_ADORE);
                int bTalked  = WR_GetPlotFlag(PLT_GENPT_MORRIGAN_TALKED, MORRIGAN_TALKED_ABOUT_ADORE);

                if (bRomance && bAdore && !bTalked)
                    nResult = TRUE;

                break;
            }

            /*
                The player watied to tell Morrigan about the grimoire and has
                not yet given it to her.
            */
            case MORRIGAN_DEFINED_WAIT_TO_TELL_BOOK_NOT_GIVEN_BOOK:
            {
                int bWait = WR_GetPlotFlag(PLT_GENPT_MORRIGAN_MAIN, MORRIGAN_MAIN_WAIT_TO_TELL_OF_BOOK);
                int bGive = WR_GetPlotFlag(PLT_GENPT_MORRIGAN_MAIN, MORRIGAN_MAIN_GIVEN_GRIMOIRE);

                if (bWait && !bGive)
                    nResult = TRUE;

                break;
            }


            /*
                The romance between Morrigan and the player has been cut off
                but can still be restarted.
            */
            case MORRIGAN_DEFINED_ROMANCE_CUT_OFF_CAN_RESTART:
            {
                int bCutOff    = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_CUT_OFF);
                int bNoRestart = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_CAN_NOT_RESTART);

                if (bCutOff && !bNoRestart)
                    nResult = TRUE;

                break;
            }

            /*
                The player is male, Morrigan's romance is currently active
                and not in the 'cut off' state.
            */
            case MORRIGAN_DEFINED_MALE_PLAYER_ROMANCE_ACTIVE_AND_NOT_CUT_OFF:
            {
                int bMalePlayer = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_MALE);
                int bRomance    = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_ACTIVE);
                int bCutOff     = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_CUT_OFF);

                if (bMalePlayer && bRomance && !bCutOff)
                    nResult = TRUE;

                break;
            }

            /*
                The player has talked to Morrigan once about Flemith but has
                not given her the grimoire.
            */
            case MORRIGAN_DEFINED_TALKED_ABOUT_FLEMITH_NOT_GIVEN_GRIMOIRE:
            {
                int bFlemith  = WR_GetPlotFlag(PLT_GENPT_MORRIGAN_TALKED, MORRIGAN_TALKED_ABOUT_FELMITH_1);
                int bGrimoire = WR_GetPlotFlag(PLT_GENPT_MORRIGAN_MAIN, MORRIGAN_MAIN_GIVEN_GRIMOIRE);

                if (bFlemith && !bGrimoire)
                    nResult = TRUE;

                break;
            }

            /*
                The player has talked to Morrigan twice about Flemith, and her
                Flemith plot is active but not yet completed.
            */
            case MORRIGAN_DEFINED_FLEMITH_PLOT_ACTIVE_NOT_COMPLETED_TALKED_2:
            {
                int bFlemith  = WR_GetPlotFlag(PLT_GENPT_MORRIGAN_TALKED, MORRIGAN_TALKED_ABOUT_FELMITH_2);
                int bActive   = WR_GetPlotFlag(PLT_GENPT_MORRIGAN_MAIN, MORRIGAN_MAIN_FLEMITH_PLOT_ACTIVE);
                // Qwinn:  This was incomplete
                // int bComplete = WR_GetPlotFlag(PLT_GENPT_MORRIGAN_MAIN, MORRIGAN_MAIN_FLEMITH_PLOT_COMPLETED);
                int bComplete = (WR_GetPlotFlag(PLT_GENPT_MORRIGAN_MAIN, MORRIGAN_MAIN_FLEMITH_PLOT_COMPLETED) ||
                                 WR_GetPlotFlag(PLT_GENPT_MORRIGAN_MAIN, MORRIGAN_MAIN_GIVEN_REAL_GRIMOIRE));

                if (bFlemith && bActive && !bComplete)
                    nResult = TRUE;

                break;
            }

            /*
                Morrigan is friendly but not romantically involved with the
                player and the party is currently in the camp.
            */
            case MORRIGAN_DEFINED_FRIENDLY_AND_ROMANCE_NOT_ACTIVE:
            {
                int bFriendly = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_IS_FRIENDLY);
                int bRomance  = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_ACTIVE);
                int bCamp     = WR_GetPlotFlag(PLT_MNP000PT_GENERIC, MAIN_PLOT_GENERIC_PARTY_AT_CAMP);

                // Qwinn:  Removed camp condition as unnecessary, restores a kiss line
                if (bFriendly && !bRomance /* && bCamp */)
                    nResult = TRUE;

                break;
            }

            /*
                The player and Morrigan have not made love, the player has
                not dumped Morrigan and Morrigan's romance has not been
                cut off at any point.
            */
            case MORRIGAN_DEFINED_NOT_ROMANCE_MAKE_LOVE_DUMPED_OR_CUT_OFF:
            {
                int bMakeLove = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_MAKE_LOVE);
                int bDumped   = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_DUMPED);
                int bCutOff   = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_CUT_OFF);

                if (!bMakeLove && !bDumped && !bCutOff)
                    nResult = TRUE;

                break;
            }

            /*
                Zevran or Leliana's romance plot is active.
            */
            case MORRIGAN_DEFINED_OTHER_ROMANCE_ACTIVE:
            {
                int bZevran  = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_ROMANCE_ACTIVE);
                int bLeliana = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_ROMANCE_ACTIVE);

                // Qwinn fixed
                // if (bZevran && bLeliana)
                if (bZevran || bLeliana)
                    nResult = TRUE;

                break;
            }

            /*
                The player is a male, has not made love to Morrigan and has
                not dumped her.
            */
            case MORRIGAN_DEFINED_MALE_PLAYER_NOT_MADE_LOVE_OR_DUMPED:
            {
                int bMalePlayer = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_MALE);
                int bMadeLove   = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_MAKE_LOVE);
                int bDumped     = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_DUMPED);

                if (bMalePlayer && !bMadeLove && !bDumped)
                    nResult = TRUE;

                break;
            }

            /*
                The player is in a party camp.
            */
            case MORRIGAN_DEFINED_PLAYER_IN_CAMP:
            {
                nResult = WR_GetPlotFlag(PLT_MNP000PT_GENERIC, MAIN_PLOT_GENERIC_PARTY_AT_CAMP);
                break;
            }

            /*
                Morrigan has talked to the player about shape-shifting but
                has not yet agreed to teach the player.
            */
            case MORRIGAN_DEFINED_TALKED_SHAPE_SHIFTING_NOT_AGREED_TO_TEACH:
            {
                int bShifting = WR_GetPlotFlag(PLT_GENPT_MORRIGAN_TALKED, MORRIGAN_TALKED_ABOUT_SHAPE_SHIFTING);
                int bTeach    = WR_GetPlotFlag(PLT_GENPT_MORRIGAN_MAIN, MORRIGAN_MAIN_AGREED_TO_TEACH_SHAPESHIFTING);

                if (bShifting && !bTeach)
                    nResult = TRUE;

                break;
            }

            /*
                Morrigan is not warm towards the player nor interested
                romantically in the player.
            */
            case MORRIGAN_DEFINED_IS_NOT_WARM_OR_INTERESTED:
            {
                int bWarm     = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_IS_WARM);
                int bInterest = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_IS_INTERESTED);

                if (!bWarm && !bInterest)
                    nResult = TRUE;

                break;
            }

            /*
                Morrigan and the player have made love but are not in love.
            */
            case MORRIGAN_DEFINED_MADE_LOVE_NOT_IN_LOVE:
            {
                int bMadeLove = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_MAKE_LOVE);
                int bInLove   = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_IS_IN_LOVE);

                if (bMadeLove && !bInLove)
                    nResult = TRUE;

                break;
            }

            /*
                Morrigan is warm, the broken circle plot is currently active
                and Morrigan has not yet been given the Grimoire.
            */
            case MORRIGAN_DEFINED_IS_WARM_BROKEN_CIRCLE_STARTED_AND_NO_GRIMOIRE:
            {
                int bWarm = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_IS_WARM);
                int bCircle = WR_GetPlotFlag(PLT_CIR000PT_MAIN, ENTERED_TOWER); // ***TBD
                int bGrimoire = WR_GetPlotFlag(PLT_GENPT_MORRIGAN_MAIN, MORRIGAN_MAIN_GIVEN_GRIMOIRE);

                if (bWarm && bCircle && !bGrimoire)
                    nResult = TRUE;

                break;
            }

            /*
                The player is male and has not cut off a romance with
                Morrigan.
            */
            case MORRIGAN_DEFINED_MALE_PLAYER_ROMANCE_NOT_CUT_OFF:
            {
                int bMalePlayer = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_MALE);
                int bCutOff     = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_CUT_OFF);

                if (bMalePlayer && !bCutOff)
                    nResult = TRUE;

                break;
            }

            /*
                The party is in the tower where the broken circle plot
                takes place.
            */
            case MORRIGAN_DEFINED_PARTY_IN_BROKEN_CIRCLE_TOWER:
            {
                object oArea = GetArea(oPC);

                string sTag = GetTag(oArea);

                if (sTag == "cir200ar_tower_level_1" ||
                    sTag == "cir210ar_tower_level_2" ||
                    sTag == "cir220ar_tower_level_3" ||
                    sTag == "cir230ar_tower_level_4" ||
                    sTag == "cir240ar_tower_harrowing")
                    nResult = TRUE;

                break;
            }

            /*
                Morrigan is friendly but not romantically involved with the
                player and either Alistair's, Leliana's or Zevran's romance
                is currently active.
            */
            case MORRIGAN_DEFINED_FRIENDLY_NOT_LOVE_OTHER_FOLLOWER_ROMANCE:
            {
                int bFriendly = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_IS_FRIENDLY);
                int bRomance  = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_ACTIVE);
                int bAlistair = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_IN_LOVE);
                int bLeliana  = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_IS_IN_LOVE);
                int bZevran   = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_IS_IN_LOVE);

                int bOtherRomance = bAlistair || bLeliana || bZevran;

                if (bFriendly && !bRomance && bOtherRomance)
                    nResult = TRUE;

                break;
            }

            /*
                Morrigan's romance is active and she is in love.
            */
            case MORRIGAN_DEFINED_ROMANCE_ACTIVE_AND_IN_LOVE:
            {
                int bRomance = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_ACTIVE);
                int bLove    = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_IS_IN_LOVE);

                if (bRomance && bLove)
                    nResult = TRUE;

                break;
            }

            /*
                The romance between Morrigan and the player is active, Morrigan
                cares about the player and they're currently at camp.
            */
            case MORRIGAN_DEFINED_ROMANCE_ACTIVE_CARE_AND_IN_CAMP:
            {
                int bRomance = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_ACTIVE);
                int bCare    = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_IS_CARE);
                int bCamp    = WR_GetPlotFlag(PLT_MNP000PT_GENERIC, MAIN_PLOT_GENERIC_PARTY_AT_CAMP);

                if (bRomance && bCare && bCamp)
                    nResult = TRUE;

                break;
            }

            /*
                The ritualhas been completed signalling the climax.
            */
            case MORRIGAN_DEFINED_RITUAL_COMPLETED:
            {
                nResult = WR_GetPlotFlag(PLT_CLIPT_MORRIGAN_RITUAL, MORRIGAN_RITUAL_DONE);
                break;
            }

            /*
                Either the romance is still active or Morrigan is still in
                love with the player.
            */
            case MORRIGAN_DEFINED_ROMANCE_ACTIVE_OR_STILL_IN_LOVE:
            {
                int bRomance = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_ACTIVE);
                int bLove    = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_STILL_IN_LOVE);

                if (bRomance || bLove)
                    nResult = TRUE;

                break;
            }


            /*
                Morrigan is currently in love or "still" in love with the player
                or even just friendly
            */
            case MORRIGAN_DEFINED_IN_LOVE_OR_STILL_IN_LOVE_OR_FRIENDLY:
            {
                int bInLove = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_IS_IN_LOVE);
                int bStillInLove = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_STILL_IN_LOVE);
                int bFriendly = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_IS_FRIENDLY);

                if (bInLove || bStillInLove || bFriendly)
                    nResult = TRUE;

                break;
            }

            /*
                Morrigan is currently in love of "still" in love.
            */
            case MORRIGAN_DEFINED_IN_LOVE_OR_STILL_IN_LOVE:
            {
                int bInLove = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_IS_IN_LOVE);
                int bStillInLove = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_STILL_IN_LOVE);

                if (bInLove || bStillInLove)
                    nResult = TRUE;

                break;

            }

            /*
                Morrigan cares for the player, they are in the camp and they
                have not yet made love.
            */
            case MORRIGAN_DEFINED_CARE_IN_CAMP_AND_NOT_MAKE_LOVE:
            {
                int bCare = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_IS_CARE);
                int bCamp = WR_GetPlotFlag(PLT_MNP000PT_GENERIC, MAIN_PLOT_GENERIC_PARTY_AT_CAMP);
                int bLove = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_MAKE_LOVE);

                if (bCare && bCamp && !bLove)
                    nResult = TRUE;

                break;
            }

            case MORRIGAN_DEFINED_READY_TO_CONFRONT_DEMON_CONNOR:
            {
                int bPreparedForDemon    = WR_GetPlotFlag(PLT_ARL100PT_ENTER_CASTLE, ARL_ENTER_CASTLE_PC_LEARNS_THAT_CONNOR_IS_RESPONSIBLE);
                int bDefeatedDemon       = WR_GetPlotFlag(PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_DEMON_DEALT_WITH);

                if (bPreparedForDemon && !bDefeatedDemon)
                    nResult = TRUE;

                break;
            }

            case MORRIGAN_DEFINED_PLAYER_MARRY_ANORA_IN_LOVE_CLIMAX_NOT_STARTED:
            {
                // Qwinn fixed:
                // int bMarryAnora     = WR_GetPlotFlag(PLT_DENPT_ANORA, DEN_ANORA_PC_MARRIAGE_ARRANGED);
                int bMarryAnora     = WR_GetPlotFlag(PLT_DENPT_MAIN,LANDSMEET_PLAYER_IS_KING);
                int bInLove         = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_ACTIVE);
                int bClimaxStarted  = WR_GetPlotFlag(PLT_CLIPT_MAIN, CLI_MAIN_AT_CITY_GATES);

                if (bMarryAnora && bInLove && !bClimaxStarted)
                    nResult = TRUE;

                break;
            }

            // Qwinn added
            case MORRIGAN_DEFINED_PLAYER_HAS_GRIMOIRE:
            {
                object oBlackGrimoire = GetItemPossessedBy(oPC,"gen_im_gift_grimoire");
                if (IsObjectValid(oBlackGrimoire))
                   nResult = TRUE;
            }

            // Qwinn added
            case MORRIGAN_DEFINED_PLAYER_HAS_REAL_GRIMOIRE:
            {
                object oRealGrimoire = GetItemPossessedBy(oPC,"gen_im_gift_flmgrimoire");
                if (IsObjectValid(oRealGrimoire))
                   nResult = TRUE;
            }






            /*
                DEBUG -> should not reach this point.
            */
            default:
            {
                break;
            }

        } // switch

    }


    plot_OutputDefinedFlag(eParms, nResult);


    return nResult;
}