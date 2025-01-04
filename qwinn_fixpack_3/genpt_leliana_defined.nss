//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events
*/
//:://////////////////////////////////////////////
//:: Created By: Yaron
//:: Created On: July 21st, 2006
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "plt_genpt_leliana_defined"
#include "plt_denpt_main"
#include "plt_denpt_alistair"
#include "plt_genpt_app_alistair"
#include "plt_genpt_app_leliana"
#include "plt_genpt_leliana_events"
#include "plt_genpt_leliana_main"
#include "plt_genpt_app_morrigan"
#include "plt_genpt_app_zevran"
#include "plt_gen00pt_class_race_gend"
// Qwinn:  No longer needed
// #include "plt_denpt_anora"
#include "cli_constants_h"

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
            case LELIANA_DEFINED_PC_GIVE_40_SILVER:
            {
                UT_MoneyTakeFromObject(oPC, 0, 40, 0);
                break;
            }
            case LELIANA_DEFINED_PC_GIVE_20_SILVER:
            {
                UT_MoneyTakeFromObject(oPC, 0, 20, 0);
                break;
            }
            case LELIANA_DEFINED_PC_GIVE_10_SILVER:
            {
                UT_MoneyTakeFromObject(oPC, 0, 10, 0);
                break;
            }
            case LELIANA_DEFINED_PC_GIVE_5_SILVER:
            {
                UT_MoneyTakeFromObject(oPC, 0, 5, 0);
                break;
            }


        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        switch(nFlag)
        {
            case LELIANA_DEFINED_ADORE_BUT_NOT_IN_LOVE:
            {
                //IF: APP_LELIANA_IS_ADORE
                //and IF (NOT): APP_LELIANA_IS_IN_LOVE
                int nAdore = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_IS_ADORE, TRUE);
                int nInLove = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_IS_IN_LOVE, TRUE);
                if((nAdore == TRUE) && (nInLove == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }

            case LELIANA_NOT_ROMANCED_BUT_PC_IN_LOVE_WITH_OTHER:
            {
                //IF: Alistair romance active
                //IF: Morrigan romance active
                //IF: Zevran romance active
                //and IF (NOT): Leliana in love
                int nAlistairRom = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_ACTIVE, TRUE);
                int nMorriganRom = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_ACTIVE, TRUE);
                int nZevranRom = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_ROMANCE_ACTIVE, TRUE);
                int nLelianaRom = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_ROMANCE_ACTIVE, TRUE);


                if((nAlistairRom || nMorriganRom || nZevranRom) && (!nLelianaRom))
                {
                    nResult = TRUE;
                }
                break;
            }
            case LELIANA_DEFINED_PC_HAS_40_SILVER:
            {
                //IF: PC Money >= 40 silver
                int nHasSilver = UT_MoneyCheck(oPC, 0, 40, 0);
                if(nHasSilver)
                {

                    nResult = TRUE;
                }
                break;
            }
            case LELIANA_DEFINED_PC_HAS_20_SILVER:
            {
                //IF: PC Money >= 20 silver
                int nHasSilver = UT_MoneyCheck(oPC, 0, 20, 0);
                if(nHasSilver)
                {
                    nResult = TRUE;
                }
                break;
            }
            case LELIANA_DEFINED_PC_HAS_10_SILVER:
            {
                //IF: PC Money >= 10 silver
                int nHasSilver = UT_MoneyCheck(oPC, 0, 10, 0);
                if(nHasSilver)
                {
                    nResult = TRUE;
                }
                break;
            }
            case LELIANA_DEFINED_PC_HAS_5_SILVER:
            {
                //IF: PC Money >= 5 silver
                int nHasSilver = UT_MoneyCheck(oPC, 0, 5, 0);
                if(nHasSilver)
                {
                    nResult = TRUE;
                }
                break;
            }
            case LELIANA_DEFINED_PC_HAS_NO_SILVER:
            {
                //IF: PC has less than 5 silver
                int nHasSilver = UT_MoneyCheck(oPC, 0, 5, 0);
                if(!nHasSilver)
                {
                    nResult = TRUE;
                }
                break;
            }
            case LELIANA_DEFINED_ROMANCE_AND_PC_MALE:
            {
                int nLelianaRom = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_ROMANCE_ACTIVE, TRUE);
                int nPCMale = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_MALE, TRUE);

                if((nLelianaRom == TRUE) && (nPCMale == TRUE))
                {
                    nResult = TRUE;
                }

                break;
            }
            case LELIANA_DEFINED_ADORE_AND_NOT_DUMPED:
            {
                int nAdore = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_IS_ADORE, TRUE);
                int nDumped = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_ROMANCE_DUMPED);
                if((nAdore == TRUE) && (nDumped == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case LELIANA_PC_IN_LOVE_WITH_OTHER:
            {
                int nAlistairRm = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_ACTIVE, TRUE);
                int nMorriganRm = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_ACTIVE, TRUE);
                int nZevranRm = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_ROMANCE_ACTIVE, TRUE);

                if((nAlistairRm == TRUE) || (nMorriganRm == TRUE) || (nZevranRm == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case LELIANA_DEFINED_PC_MARRIES_ROYALTY:
            {
                int nAlistairMarry  = WR_GetPlotFlag(PLT_DENPT_ALISTAIR, DEN_ALISTAIR_MARRYING_PLAYER, TRUE);
                // Qwinn replaced:
                // int nAnoraMarry     = WR_GetPlotFlag(PLT_DENPT_ANORA, DEN_ANORA_PC_MARRIAGE_ARRANGED);
                int nAnoraMarry = WR_GetPlotFlag(PLT_DENPT_MAIN,LANDSMEET_PLAYER_IS_KING);

                // Qwinn:  As this check is only used to see if Leliana should potentially break up with player,
                // adding check to make sure she's in a romance with player to begin with
                int nLelianaRom     = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_ROMANCE_ACTIVE, TRUE);

                if (nLelianaRom && (nAlistairMarry || nAnoraMarry))
                    nResult = TRUE;

                break;
            }
            case LELIANA_DEFINED_AT_DENERIM:
            {
                object oArea = GetArea(oPC);
                string sAreaTag = GetTag(oArea);
                string sPlotCode = SubString(sAreaTag, 0, 3);

                if((sPlotCode == "den")
                    || (sAreaTag == CLI_AR_FORT_MAIN_FLOOR)
                    || (sAreaTag == CLI_AR_FORT_SECOND_FLOOR)
                    || (sAreaTag == CLI_AR_FORT_ROOF_1)
                    || (sAreaTag == CLI_AR_CITY_GATES)
                    || (sAreaTag == CLI_AR_CITY_GATES_DEFEND)
                    || (sAreaTag == CLI_AR_CITY_GATES_CUTSCN)
                    || (sAreaTag == CLI_AR_ELVEN_ALIENAGE)
                    || (sAreaTag == CLI_AR_MARKETS)
                    || (sAreaTag == CLI_AR_PALACE_DISTRICT)
                    || (sAreaTag == CLI_AR_FORT_EXTERIOR))
                {
                    nResult = TRUE;
                }
                break;
            }
            case LELIANA_DEFINED_MARJOLAINE_SEARCH_QUEST_NOT_OVER:
            {
                int nMarjSearch     = WR_GetPlotFlag(PLT_GENPT_LELIANA_EVENTS, LELIANA_EVENT_MARJ_SEARCHING_REMINDER, TRUE);
                int nQuestOver      = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_MARJOLAINE_CONFRONTED ,TRUE);

                if (nMarjSearch && !nQuestOver)
                    nResult = TRUE;
                break;
            }
        }
    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}