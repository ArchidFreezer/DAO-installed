// Zevran defined flags plot script

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "plt_genpt_zevran_defined"
#include "plt_genpt_app_zevran"
#include "plt_genpt_app_morrigan"
#include "plt_genpt_app_leliana"
#include "plt_genpt_app_alistair"
#include "plt_gen00pt_class_race_gend"
#include "plt_genpt_zevran_main"
#include "plt_denpt_alistair"
#include "plt_denpt_main"
#include "plt_genpt_zevran_main"

// Qwinn added PLT_MNP000PT_GENERIC
#include "plt_mnp000pt_generic"

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
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case ZEVRAN_DEFINED_IN_LOVE_OR_FRIENDLY:
            {
                if(WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_IS_FRIENDLY, TRUE) ||
                    WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_IS_IN_LOVE))
                   nResult = TRUE;
                break;
            }
            case ZEVRAN_DEFINED_ADORE_NOT_DUMPED:
            {
                int nAdore = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_IS_ADORE, TRUE);
                int nDumped = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_ROMANCE_DUMPED);
                if((nAdore == TRUE) && (nDumped == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ZEVRAN_DEFINED_ROMANCE_ACTIVE_AND_PC_FEMALE:
            {
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN,APP_ZEVRAN_ROMANCE_ACTIVE,TRUE);
                int nFemale = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND,GEN_GENDER_FEMALE,TRUE);

                if((nRomance == TRUE) &&
                    (nFemale == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ZEVRAN_DEFINED_IS_NEITHER_WARM_NOR_INTERESTED:
            {
                //IFNOT: APP_ZEVRAN_IS_WARM
                //and IFNOT: APP_ZEVRAN_IS_INTERESTED
                int nWarm = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN,APP_ZEVRAN_IS_WARM,TRUE);
                int nInterested = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN,APP_ZEVRAN_IS_INTERESTED,TRUE);
                if((nWarm == FALSE) && (nInterested == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ZEVRAN_DEFINED_MENTIONED_ASSASSIN_AND_NOT_AGREED_TO_TEACH:
            {
                //IF: ZEVRAN_MAIN_MENTIONED_ASSASSIN
                //and IFNOT: ZEVRAN_MAIN_AGREED_TO_TEACH_ASSASSIN
                int nMentioned = WR_GetPlotFlag(PLT_GENPT_ZEVRAN_MAIN,ZEVRAN_MAIN_MENTIONED_ASSASSIN,TRUE);
                int nAgreed = WR_GetPlotFlag(PLT_GENPT_ZEVRAN_MAIN,ZEVRAN_MAIN_AGREED_TO_TEACH_ASSASSIN,TRUE);
                if((nMentioned == TRUE) && (nAgreed == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ZEVRAN_DEFINED_ROMANCE_ACTIVE_PC_MARRYING_ANORA_OR_ALISTAIR:
            {
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN,APP_ZEVRAN_ROMANCE_ACTIVE);
                int nAnora = WR_GetPlotFlag(PLT_DENPT_MAIN,LANDSMEET_PLAYER_IS_KING);
                int nAlistair = WR_GetPlotFlag(PLT_DENPT_ALISTAIR,DEN_ALISTAIR_MARRYING_PLAYER);
                int nAtCamp = WR_GetPlotFlag(PLT_MNP000PT_GENERIC, MAIN_PLOT_GENERIC_PARTY_AT_CAMP);
                if(((nAnora == TRUE) || (nAlistair == TRUE)) && (nRomance == TRUE) && nAtCamp)
                {
                    nResult = TRUE;
                }
                break;
            }
            case ZEVRAN_DEFINED_ADORE_AND_NOT_TALKED_ABOUT_ADORE:
            {
                int nAdore = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_IS_ADORE, TRUE);
                int nAlistairAdore = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_ADORE, TRUE);
                int nLelianaAdore = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_IS_ADORE, TRUE);
                int nMorriganAdore = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_IS_ADORE, TRUE);
                int nTalked = WR_GetPlotFlag(PLT_GENPT_ZEVRAN_MAIN, ZEVRAN_MAIN_TALKED_ABOUT_ADORE);
                if(nAdore == TRUE)
                {
                    if((nAlistairAdore == TRUE) || (nLelianaAdore == TRUE) || (nMorriganAdore == TRUE) || (nTalked == FALSE))
                    {
                        nResult = TRUE;
                    }
                }
                break;
            }
        }

    }

    return nResult;
}