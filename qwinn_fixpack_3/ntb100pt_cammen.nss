//::///////////////////////////////////////////////
//:: Plot Events
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for Cammen
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: 18/01/07
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "sys_achievements_h"
#include "plt_ntb220pt_danyla"
#include "plt_ntb100pt_varathorn"
#include "plt_ntb200pt_deygan"
#include "plt_ntb000pt_main"

#include "plt_ntb100pt_cammen"
#include "plt_ntb000pt_clan"
#include "ntb_constants_h"
#include "plt_gen00pt_skills"
#include "plt_gen00pt_class_race_gend"
#include "plt_gen00pt_random"
#include "plt_ntb000pt_plot_items"
#include "plt_cod_bks_dalish_history"

// Qwinn added
vector QwConvToVector(float x, float y, float z)
   { return Vector(x,y,z);     }


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
    object oCammen = UT_GetNearestCreatureByTag(oPC,NTB_CR_CAMMEN);
    object oGheyna = UT_GetNearestCreatureByTag(oPC,NTB_CR_GHEYNA);
    object oPelt = GetItemPossessedBy(oPC,GEN_IM_PELT_WOLF);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case NTB_CAMMEN_RUNS_AWAY:
            {
                // -----------------------------------------------------
                // Cammen runs away to the forest and disappears.
                // His dead body can be found later with wolves around it
                // along with any rewards he might have for this plot.
                // -----------------------------------------------------
                WR_SetObjectActive(oCammen,FALSE);
                break;
            }
            case NTB_CAMMEN_PC_PROMISED_REWARD:
            {
                // -----------------------------------------------------
                // Sets that the PC agreed to talk to Gheyna
                // -----------------------------------------------------
                WR_SetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_PC_AGREED_TO_TALK_TO_GHEYNA,TRUE,TRUE);
                break;
            }
            case NTB_CAMMEN_ANGRY_AT_PC:
            {
                // Qwinn:  Added this condition so we can clear the flag without lowering attitude even more
                if (nValue)
                {
                   // -----------------------------------------------------
                   // ACTION: lower clan attitude by one
                   // -----------------------------------------------------
                   WR_SetPlotFlag(PLT_NTB000PT_CLAN,NTB_CLAN_DECREMENT_ATTITUDE_BY_ONE,TRUE,TRUE);

                   //if Cammen has already told the plot to the PC - shut down the plot
                   int nStory = WR_GetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_TOLD_PC_STORY_OF_GHEYNA);
                   if (nStory == TRUE)
                   {
                      WR_SetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_ANGRY_SHUTDOWN_PLOT, TRUE, TRUE);
                   }
                }
                else
                {
                   // -----------------------------------------------------
                   // ACTION: Qwinn:  Cammen forgives, restore the lost attitude point
                   // -----------------------------------------------------
                   WR_SetPlotFlag(PLT_NTB000PT_CLAN,NTB_CLAN_INCREMENT_ATTITUDE_BY_ONE,TRUE,TRUE);
                }

                break;
            }
            case NTB_CAMMEN_PC_AGREED_TO_TALK_TO_GHEYNA:
            {
                // -----------------------------------------------------
                // clear refusal
                // -----------------------------------------------------
                WR_SetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_PC_REFUSED_TO_TALK_TO_GHEYNA,FALSE);
                //remove plotgiver
                SetPlotGiver(oCammen, FALSE);
                break;
            }
            case NTB_CAMMEN_PC_PROMISED_REWARD_FOR_PELT:
            {
                // -----------------------------------------------------
                // sets that the PC agreed to find the pelt and promised reward
                // -----------------------------------------------------
                WR_SetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_PC_AGREED_TO_FIND_PELT,TRUE,TRUE);
                WR_SetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_PC_PROMISED_REWARD,TRUE);
                break;
            }
            case NTB_CAMMEN_PC_AGREED_TO_FIND_PELT:
            {
                // -----------------------------------------------------
                // remove that the PC refused to find the pelt
                // -----------------------------------------------------
                WR_SetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_PC_REFUSED_TO_FIND_PELT,FALSE);
                //remove plotgiver
                SetPlotGiver(oCammen, FALSE);
                break;
            }
            case NTB_CAMMEN_PC_SLEEPS_WITH_CAMMEN:
            {
                // -----------------------------------------------------
                // CUTSCENE: sleeping with Cammen
                // ACTION: get rid of some of Cammen's clothes
                // ACTION: Init dialog after cutscene
                // -----------------------------------------------------
                UT_Talk(oCammen,oPC);
                break;
            }
            case NTB_CAMMEN_GHEYNA_CONVINCED_TO_ACCEPT_CAMMEN:
            {
                // -----------------------------------------------------
                // ACTION: Gheyna inits dialog with Cammen (pc can be present)
                // ACTION: increase clan attitude by one (CLAN_ATTITUDE_INC)
                // -----------------------------------------------------
                UT_Talk(oGheyna,oPC);
                WR_SetPlotFlag(PLT_NTB000PT_CLAN,NTB_CLAN_INCREMENT_ATTITUDE_BY_ONE,TRUE,TRUE);
                break;
            }
            case NTB_CAMMEN_GHEYNA_ANGRY_AT_PC:
            {
                // -----------------------------------------------------
                // SET: EVENT_GHEYNA_REFUSED (Cammen)
                // ACTION: lower clan attitude by 1 (CLAN_ATTITUDE_DEC)
                // -----------------------------------------------------
                WR_SetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_GHEYNA_REFUSED_CAMMEN,TRUE);
                WR_SetPlotFlag(PLT_NTB000PT_CLAN,NTB_CLAN_DECREMENT_ATTITUDE_BY_ONE,TRUE,TRUE);

                break;
            }
            case NTB_CAMMEN_GHEYNA_ANGRY_AT_CAMMEN:
            {
                // -----------------------------------------------------
                // ACTION: Gheyna inits dialog with Cammen (pc can be in it)
                // ACTION: decrease clan attitude by 1 (CLAN_ATTITUDE_DEC)
                // if pc slept with Cammen
                // -----------------------------------------------------
                UT_Talk(oGheyna,oPC);
                WR_SetPlotFlag(PLT_NTB000PT_CLAN,NTB_CLAN_DECREMENT_ATTITUDE_BY_ONE,TRUE,TRUE);
                break;
            }
            case NTB_CAMMEN_GHEYNA_LEAVES:
            {
                // -----------------------------------------------------
                //ACTION: Gheyna runs away and disappears permanently
                // -----------------------------------------------------
                WR_SetObjectActive(oGheyna,FALSE);
                break;
            }
            case NTB_CAMMEN_GIVES_PC_REWARD:
            {
                // -----------------------------------------------------
                //ACTION: give reward (in plot manager)
                //ACTION: increase clan attitude by 1 (CLAN_ATTITUDE_INC)
                //ACTION: Cammen and Gheyna disappear permanently
                // -----------------------------------------------------
                WR_SetPlotFlag(PLT_COD_BKS_DALISH_HISTORY,COD_BKS_DALISH_HISTORY,TRUE,TRUE);
                WR_SetPlotFlag(PLT_NTB000PT_CLAN,NTB_CLAN_INCREMENT_ATTITUDE_BY_ONE,TRUE,TRUE);
                //WR_SetObjectActive(oGheyna,FALSE);
                //WR_SetObjectActive(oCammen,FALSE);
                break;
            }
            case NTB_CAMMEN_GIVES_PC_SMALL_REWARD:
            {
                // -----------------------------------------------------
                //ACTION: give small reward (PLOT MANAGER)
                //ACTION: increase clan attitude by 1 (CLAN_ATTITUDE_INC)
                //ACTION: Cammen and Gheyna disappear permanently
                // -----------------------------------------------------
                WR_SetPlotFlag(PLT_COD_BKS_DALISH_HISTORY,COD_BKS_DALISH_HISTORY,TRUE,TRUE);
                WR_SetPlotFlag(PLT_NTB000PT_CLAN,NTB_CLAN_INCREMENT_ATTITUDE_BY_ONE,TRUE,TRUE);
                WR_SetObjectActive(oGheyna,FALSE);
                WR_SetObjectActive(oCammen,FALSE);
                break;
            }
            case NTB_CAMMEN_GHEYNA_LEAVES_IN_SHAME:
            {
                // -----------------------------------------------------
                //ACTION: Gheyna vanished permanently
                // -----------------------------------------------------
                WR_SetObjectActive(oGheyna,FALSE);
                break;
            }
            case NTB_CAMMEN_ANGRY_AT_GHEYNA:
            {
                // -----------------------------------------------------
                //ACTION: Cammen inits dialog with Gheyna (pc can be present)
                // -----------------------------------------------------
                UT_Talk(oCammen,oPC);
                break;
            }
            case NTB_CAMMEN_PC_GIVES_PELT:
            {
                // -----------------------------------------------------
                // If the PC has a pelt in his inventory
                // -----------------------------------------------------
                if(IsObjectValid(oPelt))
                {
                    // -----------------------------------------------------
                    //ACTION: give pelt to Cammen
                    // -----------------------------------------------------
                    // WR_DestroyObject(oPelt);
                    // Qwinn: This was originally WR_DestroyObject, which would remove the whole stack of pelts
                    RemoveItem(oPelt, 1);
                }
                break;
            }
            case NTB_CAMMEN_RECEIVED_PELT_FROM_PC:
            {
                // -----------------------------------------------------
                //ACTION: init dialog with Gheyna        ***don't think we need to do this now
                //ACTION: increase clan attitude by 1 (CLAN_ATTITUDE_INC)
                // -----------------------------------------------------
                //LogTrace(LOG_CHANNEL_TEMP, "Trying to start next Cammen dialog");
                //UT_Talk(oCammen,oPC);
                WR_SetPlotFlag(PLT_NTB000PT_CLAN,NTB_CLAN_INCREMENT_ATTITUDE_BY_ONE,TRUE,TRUE);
                break;
            }
            case NTB_CAMMEN_GIVES_PC_SMALL_REWARD_AFTER_SEPARATED:
            {
                // -----------------------------------------------------
                //ACTION: give reward (small magic item) (plot manager)
                // -----------------------------------------------------
                WR_SetPlotFlag(PLT_COD_BKS_DALISH_HISTORY,COD_BKS_DALISH_HISTORY,TRUE,TRUE);
                break;
            }
            case NTB_CAMMEN_LEAVES_AFTER_SEPARATED:
            {
                // -----------------------------------------------------
                //ACTION: Cammen leaves permanently
                // -----------------------------------------------------
                WR_SetObjectActive(oCammen,FALSE);
                break;
            }
            case NTB_CAMMEN_COUPLE_IN_LOVE:
            {
                //If PC ended plot by speaking with Gheyna - start reward conversation with Cammen
                if (WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_ENDPLOT_SPEAK) == TRUE)
                {
                    LogTrace(LOG_CHANNEL_TEMP, "Trying to speak with Cammen");
                    UT_Talk(oCammen, oPC);
                }
                else
                {
                    LogTrace(LOG_CHANNEL_TEMP, "FAILED: Endplot speak was FALSE");
                }

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BRECILIAN_7);

                break;
            }
            case NTB_CAMMEN_TOLD_PC_ABOUT_PELT:
            {
                //turn off plot giver
                SetPlotGiver(oCammen, FALSE);

                break;
            }   
            
            case NTB_CAMMEN_PC_SLEPT_WITH_GHEYNA:
            {
                SetPosition(oGheyna,QwConvToVector(290.1f,272.485f,5.83879f),FALSE);
                SetOrientation(oGheyna,QwConvToVector(-92.4,0.0,0.0));
                break;   
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        switch(nFlag)
        {
            case NTB_CAMMEN_PC_OFFER_POSSIBLE:
            {
                int nGheyna = WR_GetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_PC_SPOKE_TO_GHEYNA_ABOUT_CAMMEN);
                int nAgreed = WR_GetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_PC_AGREED_TO_TALK_TO_GHEYNA);
                int nPelt = WR_GetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_PC_AGREED_TO_FIND_PELT);
                int nSleep = WR_GetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_PC_SLEPT_WITH_GHEYNA);
                // -----------------------------------------------------
                //APPEARS WHEN (NOT): EVENT_PC_SPOKE_TO_GHEYNA (Cammen) *AND*
                //APPEARS WHEN (NOT): EVENT_PC_AGREED_TO_TALK_TO_GHYENA (Cammen) *AND*
                //APPEARS WHEN (NOT): EVENT_PC_AGREED_TO_FIND_PELT (Cammen) *AND*
                //APPEARS WHEN (NOT): EVENT_PC_SLEEP_WITH_GHEYNA (Cammen)
                // -----------------------------------------------------
                if((nGheyna == FALSE)
                    && (nAgreed == FALSE)
                    && (nPelt == FALSE)
                    && (nSleep == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_CAMMEN_SEDUCTION_POSSIBLE:
            {
                int nElven = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND,GEN_RACE_ELF,TRUE);
                int nPersuadeMed = WR_GetPlotFlag(PLT_GEN00PT_SKILLS,GEN_PERSUADE_MED,TRUE);
                int nPersuadeHigh = WR_GetPlotFlag(PLT_GEN00PT_SKILLS,GEN_PERSUADE_HIGH,TRUE);
                // -----------------------------------------------------
                //IF PC IS ELVEN AND HAS PERSUADE OF 3+
                // -----------------------------------------------------
                if((nElven == TRUE) && (nPersuadeMed == TRUE))
                {
                    nResult = TRUE;
                }
                // -----------------------------------------------------
                //IF PC IS HUMAN OR DWARVEN AND HAS PERSUADE OF 5+
                // -----------------------------------------------------
                else if(nPersuadeHigh == TRUE)
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_CAMMEN_PC_TOLD_GHEYNA_NAME_AND_STORY:
            {
                int nName = WR_GetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_TOLD_PC_GHEYNA_NAME,TRUE);
                int nStory = WR_GetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_TOLD_PC_STORY_OF_GHEYNA,TRUE);
                // -----------------------------------------------------
                // if Cammen told the PC Gheyna's name and their sad story
                // -----------------------------------------------------
                if((nName == TRUE) && (nStory == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_CAMMEN_PC_HAS_PELT_AND_NOT_SLEPT_WITH_GHEYNA:
            {
                int nSleep = WR_GetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_PC_SLEPT_WITH_GHEYNA);
                int nPelt = IsObjectValid(oPelt);
                // -----------------------------------------------------
                //  If the PC has a pelt for Cammen and hasn't slept with Gheyna
                // -----------------------------------------------------
                if((nPelt == TRUE) && (nSleep == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_CAMMEN_ANGRY_AT_PC_AND_TOLD_STORY_OF_GHEYNA:
            {
                int nAngry = WR_GetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_ANGRY_AT_PC,TRUE);
                int nStory = WR_GetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_TOLD_PC_STORY_OF_GHEYNA,TRUE);
                // -----------------------------------------------------
                // Cammen has told the PC his sad tale and gotten angry with the PC
                // -----------------------------------------------------
                if((nAngry == TRUE) && (nStory == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_CAMMEN_GHEYNA_CONVINCED_TO_TAKE_CAMMEN_AND_RANDOM:
            {
                int nGheyna = WR_GetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_GHEYNA_CONVINCED_TO_ACCEPT_CAMMEN,TRUE);
                int nRandom = WR_GetPlotFlag(PLT_GEN00PT_RANDOM,GEN_R50,TRUE);
                // -----------------------------------------------------
                //EVENT_GHEYNA_CONVINCED_TO_TAKE_CAMMEN (Cammen) AND* 50%
                // -----------------------------------------------------
                if((nGheyna == TRUE) && (nRandom == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_CAMMEN_RECEIVED_PELT_FROM_PC_AND_RANDOM:
            {
                int nPelt = WR_GetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_RECEIVED_PELT_FROM_PC,TRUE);
                int nRandom = WR_GetPlotFlag(PLT_GEN00PT_RANDOM,GEN_R50,TRUE);
                // -----------------------------------------------------
                //EVENT_CAMMEN_GOT_PELT_FROM_PC (Cammen) *AND* 50%
                // -----------------------------------------------------
                if((nPelt == TRUE) && (nRandom == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_CAMMEN_COUPLE_IN_LOVE_AND_RANDOM:
            {
                int nLove = WR_GetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_COUPLE_IN_LOVE,TRUE);
                int nRandom = WR_GetPlotFlag(PLT_GEN00PT_RANDOM,GEN_R50,TRUE);
                // -----------------------------------------------------
                //EVENT_COUPLE_IN_LOVE (Cammen) *AND* 50%
                // -----------------------------------------------------
                if((nLove == TRUE) && (nRandom == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_CAMMEN_COUPLE_SEPARATED_AND_RANDOM:
            {
                int nSeparated = WR_GetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_COUPLE_SEPARATED,TRUE);
                int nRandom = WR_GetPlotFlag(PLT_GEN00PT_RANDOM,GEN_R50,TRUE);
                // -----------------------------------------------------
                //EVENT_COUPLE_SEPARATED (Cammen) *AND* 50%
                // -----------------------------------------------------
                if((nSeparated == TRUE) && (nRandom == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_CAMMEN_PC_NOT_TALKED_TO_GHEYNA_ABOUT_CAMMEN_NOR_AGREED:
            {
                int nAgreed = WR_GetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_PC_AGREED_TO_TALK_TO_GHEYNA,TRUE);
                int nGheyna = WR_GetPlotFlag(PLT_NTB100PT_CAMMEN,NTB_CAMMEN_PC_SPOKE_TO_GHEYNA_ABOUT_CAMMEN,TRUE);
                // -----------------------------------------------------
                //This specifically checks if the pc has talked to gheyna about cammen
                // without agreeing to do so
                // -----------------------------------------------------
                if((nAgreed == FALSE) && (nGheyna == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_CAMMEN_COUPLE_IN_LOVE:
            {
                // -----------------------------------------------------
                // FAB 7/2: Adding achievement for NotB
                // -----------------------------------------------------
                int bCondition1 = WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_WEREWOLVES_PROMISED_ALLIANCE);
                int bCondition2 = WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_ELVES_PROMISED_ALLIANCE);
                if ( !bCondition1 && !bCondition2 ) break;

                int nCounter;
                if ( WR_GetPlotFlag(PLT_NTB100PT_VARATHORN, NTB_VARATHORN_IRONBARK_PLOT_DONE) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB200PT_DEYGAN, NTB_DEYGAN_PC_RETURNED_BODY) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB200PT_DEYGAN, NTB_DEYGAN_HEALED_BY_PC) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB200PT_DEYGAN, NTB_DEYGAN_RETURNED_ALIVE_WITH_PC) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB220PT_DANYLA, NTB_DANYLA_PC_TOLD_ATHRAS) ) nCounter++;

                if ( nCounter >= 1 ) Acv_Grant(30);
                // End achievement code

                break;
            }
        }
    }

    return nResult;
}