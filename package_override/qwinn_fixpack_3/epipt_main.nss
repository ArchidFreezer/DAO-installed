//::///////////////////////////////////////////////
//:: Epilogue
//:: Copyright (c) 2008 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Main Plot Script
*/
//:://////////////////////////////////////////////
//:: Created By: Mark Barazzuol
//:: Created On: Jine 2nd, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "plot_h"
#include "sys_audio_h"
#include "epi_constants_h"
#include "cutscenes_h"

#include "plt_epipt_main"
#include "plt_clipt_archdemon"
#include "plt_clipt_morrigan_ritual"
#include "plt_gen00pt_party"
#include "plt_denpt_alistair"
#include "plt_denpt_main"
#include "plt_genpt_app_morrigan"
#include "plt_epipt_main"
#include "plt_genpt_app_alistair"     

#include "plt_qwinn"

#include "approval_h"

int IsAlistairDead()
{
    // Was the Ritual performed?
    int bAlistairKillingBlow    = WR_GetPlotFlag(PLT_CLIPT_ARCHDEMON, CLIMAX_ARCHDEMON_ALISTAIR_KILLS_ARCHDEMON,FALSE);
    int bRitual                 = WR_GetPlotFlag(PLT_CLIPT_MORRIGAN_RITUAL, MORRIGAN_RITUAL_DONE,FALSE);
    int bExecuted               = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_KILLED);

    if (bAlistairKillingBlow && (bRitual == FALSE))
        return TRUE;
    else if(bExecuted)
        return TRUE;
    else
        return FALSE;

}

void JumpToWp(string sObject, string sWP)
{
    object oObject = GetObjectByTag(sObject);
    location lWP = GetLocation(GetObjectByTag(sWP));

    SetLocation(oObject, lWP);
}


int StartingConditional()
{
    event eParms = GetCurrentEvent();                       // Contains all input parameters
    int nType = GetEventType(eParms);                       // GET or SET call
    string strPlot = GetEventString(eParms, 0);             // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);                 // The bit flag # being affected
    object oParty = GetEventCreator(eParms);                // The owner of the plot table for this script
    object oConversationOwner = GetEventObject(eParms, 0);  // Owner on the conversation, if any
    int nResult = FALSE;                                    // used to return value for DEFINED GET events
    object oPC = GetHero();

    object oTarg;

    plot_GlobalPlotHandler(eParms);                         // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT)                        // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);            // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);         // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!

        switch(nFlag)
        {

            case EPI_JUMP_TO_FUNERAL:
            {
                // Start the funeral sequence
                UT_DoAreaTransition(EPI_AR_FUNERAL, "epi200wp_start");
            break;
            }

            case EPI_JUMP_TO_POST_CORONATION:
            {
                // Start the post coronation sequence
                UT_DoAreaTransition(EPI_AR_POST_CORONATION, "epi300wp_start");
            break;
            }
            case EPI_JUMP_TO_CREDITS:
            {
                // Start the Credits
                //CS_LoadCutscene( CUTSCENE_CREDITS_PLACEHOLDER, PLT_EPIPT_MAIN, EPI_JUMP_TO_MAIN_MENU );
                ShowStartMenu(TRUE);
            break;
            }
            case EPI_JUMP_TO_MAIN_MENU:
            {
                // Open the main menu
                ShowStartMenu();
            break;
            }
            case EPI_JUMP_TO_SLIDE_SHOW:
            {
                string sArea = GetTag(GetArea(OBJECT_SELF));
                // Cancel all ambient sounds.
                // If Post Coronation
                if (sArea == EPI_AR_POST_CORONATION)
                    AudioTriggerPlotEvent(EPI_AUDIO_POSTCORONATION_AMB_OFF);
                else
                // If Funeral
                    AudioTriggerPlotEvent(EPI_AUDIO_FUNERAL_AMB_OFF);

                BeginSlideshow(TALK_EPI_SLIDESHOW);
                break;
            }
            case EPI_JUMP_TO_SECOND_SCENE:
            {
                // Decide if the player is alive or dead.
                if (WR_GetPlotFlag(PLT_EPIPT_MAIN, EPI_PLAYER_IS_DEAD))
                    UT_DoAreaTransition(EPI_AR_FUNERAL, "epi200wp_start");
                else
                    UT_DoAreaTransition(EPI_AR_POST_CORONATION, "epi300wp_start");

                break;
            }
            case EPI_SET_POSTCORONATION_SPEECH_DONE:
            {
                // Warp characters to their proper positions

                Log_Trace_Scripting_Error(GetCurrentScriptName(), "Jump to Origins");

                JumpToWp(EPI_CR_ALISTAIR, "wp_alistair");
                JumpToWp(EPI_CR_DOG, "wp_dog");
                JumpToWp(EPI_CR_LELIANA, "wp_leliana");
                JumpToWp(EPI_CR_LOGHAIN, "wp_loghain");
                JumpToWp(EPI_CR_OGHREN, "wp_oghren");
                JumpToWp(EPI_CR_SHALE, "wp_shale");
                JumpToWp(EPI_CR_STEN, "wp_sten");
                JumpToWp(EPI_CR_WYNNE, "wp_wynne");
                JumpToWp(EPI_CR_ZEVRAN, "wp_zevran");
                JumpToWp(EPI_CR_ANORA, "wp_anora");
                JumpToWp(EPI_CR_ASHALLE, "wp_originchar");
                JumpToWp(EPI_CR_CYRION, "wp_originchar");
                JumpToWp(EPI_CR_FERGUS, "wp_originchar");
                JumpToWp(EPI_CR_GORIM, "wp_originchar");
                JumpToWp(EPI_CR_IRVING, "wp_originchar");
                JumpToWp(EPI_CR_RICA, "wp_originchar");
                JumpToWp(EPI_CR_EAMON, "wp_eamon");
                JumpToWp("epi_nobleman", "wp_noble_m");

                JumpToWp(GetTag(oPC), "epi300wp_start");

            break;
            }




        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            // Player failed to make the deal with Morrigan
            case EPI_PLAYER_IS_DEAD:
            {

                int bMorriganDeal = WR_GetPlotFlag(PLT_CLIPT_MORRIGAN_RITUAL,MORRIGAN_RITUAL_DONE,FALSE);
                int bKillingBlow = WR_GetPlotFlag(PLT_CLIPT_ARCHDEMON,CLIMAX_ARCHDEMON_PC_KILLS_ARCHDEMON,FALSE);

                if (!(bMorriganDeal) && bKillingBlow)
                    nResult = TRUE;
            break;
            }
            case EPI_ALISTAIR_DELIVER_SPEECH:
            {
                // Alistair in party AND
                // Sole King OR married to anora
                // OR Alstair married to player
                // AND Alistair was alive at the end.
                // Qwinn:  Simplifying.
                int bAlistairInParty            = WR_GetPlotFlag(PLT_GEN00PT_PARTY,GEN_ALISTAIR_RECRUITED);
                int bAlistairOnThrone           = WR_GetPlotFlag(PLT_DENPT_MAIN,LANDSMEET_ALISTAIR_ON_THRONE);
                /*
                int bAlistairSoleKing           = WR_GetPlotFlag(PLT_DENPT_MAIN,LANDSMEET_ALISTAIR_IS_KING);
                int bAlistairMarriedToPlayer    = WR_GetPlotFlag(PLT_DENPT_ALISTAIR,DEN_ALISTAIR_MARRYING_PLAYER,FALSE);
                int bAlistairMarriedToAnora     = WR_GetPlotFlag(PLT_DENPT_MAIN,LANDSMEET_ALISTAIR_ENGAGED_TO_ANORA);

                if ( (bAlistairInParty) &&
                   (IsAlistairDead() == FALSE) &&
                   (bAlistairSoleKing || bAlistairMarriedToAnora || bAlistairMarriedToPlayer) )
                        nResult = TRUE;
                */
                if ( bAlistairInParty && bAlistairOnThrone && !IsAlistairDead())
                     nResult = TRUE;

            break;
            }
            case EPI_ANORA_DELIVER_SPEECH:
            {
                // Qwinn:
                /*
                // Sole Queen OR...
                // Married to Alistair and Logain joined party
                // Alistair died killing archdemon
                int bAnoraQueen                 = WR_GetPlotFlag(PLT_DENPT_MAIN,LANDSMEET_ANORA_IS_QUEEN,FALSE);
                int bAnoraMarriedToAlistair     = WR_GetPlotFlag(PLT_DENPT_MAIN,LANDSMEET_ALISTAIR_ENGAGED_TO_ANORA,FALSE);
                int bLogainInParty              = WR_GetPlotFlag(PLT_GEN00PT_PARTY,GEN_LOGHAIN_IN_PARTY,FALSE);

                int bAlistairDied = IsAlistairDead();

                if (bAnoraQueen || (bAnoraMarriedToAlistair && bLogainInParty) || bLogainInParty)
                    nResult = TRUE;
                */
                nResult = !WR_GetPlotFlag(PLT_EPIPT_MAIN, EPI_ALISTAIR_DELIVER_SPEECH);

            break;
            }
            case EPI_ALISTAIR_HEROIC_DEATH:
            {
                // Alistair died killing the archdemon
                int bAlistairKillingBlow = WR_GetPlotFlag(PLT_CLIPT_ARCHDEMON, CLIMAX_ARCHDEMON_ALISTAIR_KILLS_ARCHDEMON,FALSE);

                if(bAlistairKillingBlow)
                    nResult = TRUE;
            break;
            }
            case EPI_ALISTAIR_ALIVE_AND_KING:
            {
                // Alistair is alive and sole king or married to anora
                /* Qwinn:  Simplifying
                int bAlistairSoleKing       = WR_GetPlotFlag(PLT_DENPT_MAIN,LANDSMEET_ALISTAIR_IS_KING);
                int bAlistairMarriedAnora   = WR_GetPlotFlag(PLT_DENPT_MAIN,LANDSMEET_ALISTAIR_ENGAGED_TO_ANORA);
                int bAlistairMarriedPC      = WR_GetPlotFlag(PLT_DENPT_ALISTAIR,DEN_ALISTAIR_MARRYING_PLAYER);
                */
                int bAlistairOnThrone           = WR_GetPlotFlag(PLT_DENPT_MAIN,LANDSMEET_ALISTAIR_ON_THRONE);

                // if ((bAlistairSoleKing || bAlistairMarriedAnora || bAlistairMarriedPC) && !(IsAlistairDead()))
                if (bAlistairOnThrone && !IsAlistairDead())
                    nResult = TRUE;
            break;
            }
            case EPI_PC_FEELINGS_FOR_MORRIGAN:
            {
                // The player had an active romance with Morrigan OR
                // the player performed the ritual with Morrigan
                int bMorriganRomance    = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_STILL_IN_LOVE,FALSE);
                int bMorriganRitual     = WR_GetPlotFlag(PLT_CLIPT_MORRIGAN_RITUAL, MORRIGAN_RITUAL_WITH_PLAYER,FALSE);

                if (bMorriganRomance || bMorriganRitual)
                    nResult = TRUE;
            break;
            }
            case EPI_ALISTAIR_KNOW_RITUAL_NOT_REASON:
            {
                // Alistair knows of the ritual but not what it does
                // int bRitualKnown = WR_GetPlotFlag(PLT_CLIPT_MORRIGAN_RITUAL, MORRIGAN_RITUAL_ALISTAIR_KNOWS_ABOUT_CHILD,FALSE);
                int bRitualKnown = WR_GetPlotFlag(PLT_CLIPT_MORRIGAN_RITUAL, MORRIGAN_RITUAL_KNOWN);
                int bAlistairRitual = WR_GetPlotFlag(PLT_CLIPT_MORRIGAN_RITUAL, MORRIGAN_RITUAL_WITH_ALISTAIR,FALSE);
                // Qwinn fixed, this was insufficient
                // int bRitualConvinced = WR_GetPlotFlag(PLT_CLIPT_MORRIGAN_RITUAL, MORRIGAN_RITUAL_CONVINCE_ALISTAIR,FALSE);
                int bRitualMentioned = WR_GetPlotFlag(PLT_QWINN,CLI_RITUAL_MENTIONED);                

                if (!bRitualKnown && (bRitualMentioned || bAlistairRitual))
                    nResult = TRUE;
            break;
            }

            case EPI_APP_WYNNE_WARM_OR_HIGHER:
            {
                // Wynne reaction to you is Warm or higher.
                if (Approval_GetApproval(APP_FOLLOWER_WYNNE) >= 4)
                    nResult = TRUE;
            break;
            }

            case EPI_LOGHAIN_IS_DEAD:
            {
                // Did Loghain kill the archdemon
                // Did Loghain partake in Morrigan's ritual

                int bKilledArchDemon = WR_GetPlotFlag(PLT_CLIPT_ARCHDEMON,CLIMAX_ARCHDEMON_LOGHAIN_KILLS_ARCHDEMON,FALSE);
                int bMorriganRitual  = WR_GetPlotFlag(PLT_CLIPT_MORRIGAN_RITUAL,MORRIGAN_RITUAL_WITH_LOGHAIN,FALSE);

                if (bKilledArchDemon && !bMorriganRitual)
                    nResult = TRUE;

            break;
            }

            case EPI_ALISTAIR_NEITHER_KING_NOR_EXILED:
            {
                // Alistair is King
                // Alistair has been exiled
                // ... and not executied

                int bExiled = WR_GetPlotFlag(PLT_DENPT_MAIN,LANDSMEET_ALISTAIR_LEAVES_FOREVER,FALSE);
                int bIsKing = WR_GetPlotFlag(PLT_EPIPT_MAIN,EPI_ALISTAIR_ALIVE_AND_KING,FALSE);

                if (!bExiled && !bIsKing && !(IsAlistairDead()))
                    nResult = TRUE;

            break;
            }
            case EPI_PC_LOVES_ALISTAIR_AND_NOT_EXILED:
            {
                // PC Loves Alistair
                // Alistair has been exiled

                // Qwinn:  This needs to check that he's not king either, as he is clearly just a Grey Warden
                // the epilogues this triggers. And InLove should be in love, not just romance active.

                int bExiled = WR_GetPlotFlag(PLT_DENPT_MAIN,LANDSMEET_ALISTAIR_LEAVES_FOREVER,FALSE);
                // int bInLove = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR,APP_ALISTAIR_ROMANCE_ACTIVE,FALSE);
                int bInLove = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR,APP_ALISTAIR_IS_IN_LOVE,FALSE);
                int bIsKing = WR_GetPlotFlag(PLT_DENPT_MAIN,LANDSMEET_ALISTAIR_ON_THRONE);
                int bAlistairDead = IsAlistairDead();

                if ((!bExiled) && (!bIsKing) && bInLove && !bAlistairDead)
                    nResult = TRUE;

            break;
            }
            case EPI_PC_CHANCELLOR_OR_CONSORT:
            {
                int bChancellor = WR_GetPlotFlag(PLT_EPIPT_MAIN, EPI_REWARD_CHANCELLOR,FALSE);
                int bConsort    = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_PLAYER_IS_KING,FALSE);

                if (bChancellor || bConsort)
                    nResult = TRUE;

                break;
            }
            case EPI_ALISTAIR_ALIVE_AND_ENGAGED_TO_ANORA:
            {
                if(WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_ENGAGED_TO_ANORA)
                    && !IsAlistairDead())
                    nResult = TRUE;
                break;
            }


        } // End switch(nFlag)

    } // End Else Statement

    return nResult;
}