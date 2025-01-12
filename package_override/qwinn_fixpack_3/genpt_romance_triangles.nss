//::///////////////////////////////////////////////
//:: Plot Events
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events: keeps track of the person who has asked
    the PC to dump another follower for them
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: March 2, 2009
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "plt_genpt_romance_triangles"
#include "plt_genpt_app_alistair"
#include "plt_genpt_alistair_main"
#include "plt_genpt_app_zevran"
#include "plt_genpt_app_leliana"
#include "plt_genpt_app_morrigan"
#include "plt_genpt_alistair_talked"
#include "plt_genpt_zevran_main"

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
            case ROMANCE_PC_DUMPED_ALISTAIR_FOR_LELIANA:
            {
                //if you dumped Alistair at Leliana's request
                WR_SetPlotFlag(PLT_GENPT_APP_ALISTAIR,APP_ALISTAIR_ROMANCE_DUMPED,TRUE,TRUE);
                break;
            }
            case ROMANCE_PC_DUMPED_ALISTAIR_FOR_ZEVRAN:
            {
                //if you dumped Alistair at Zevran's request
                WR_SetPlotFlag(PLT_GENPT_APP_ALISTAIR,APP_ALISTAIR_ROMANCE_DUMPED,TRUE,TRUE);
                break;
            }
            case ROMANCE_PC_DUMPED_LELIANA_FOR_ALISTAIR:
            {
                //if you dumped Leliana at Alistair's request
                WR_SetPlotFlag(PLT_GENPT_APP_LELIANA,APP_LELIANA_ROMANCE_DUMPED,TRUE,TRUE);
                break;
            }
            case ROMANCE_PC_DUMPED_LELIANA_FOR_MORRIGAN:
            {
                //if you dumped Leliana at Morrigan's request
                // Qwinn - the following didn't work.  nFlag should be nValue
                // Also making sure to reactivate romance if value is being cleared.
                // if(nFlag == TRUE)
                if(nValue == TRUE)
                {
                    WR_SetPlotFlag(PLT_GENPT_APP_LELIANA,APP_LELIANA_ROMANCE_DUMPED,TRUE,TRUE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_GENPT_APP_LELIANA,APP_LELIANA_ROMANCE_DUMPED,FALSE,TRUE);
                    WR_SetPlotFlag(PLT_GENPT_APP_LELIANA,APP_LELIANA_ROMANCE_ACTIVE,TRUE,TRUE);
                }
                break;
            }
            case ROMANCE_PC_DUMPED_LELIANA_FOR_ZEVRAN:
            {
                //if you dumped Leliana at Zevran's request
                WR_SetPlotFlag(PLT_GENPT_APP_LELIANA,APP_LELIANA_ROMANCE_DUMPED,TRUE,TRUE);
                break;
            }
            case ROMANCE_PC_DUMPED_MORRIGAN_FOR_ZEVRAN:
            {
                //if you dumped Morrigan at Zevran's request
                WR_SetPlotFlag(PLT_GENPT_APP_MORRIGAN,APP_MORRIGAN_ROMANCE_DUMPED,TRUE,TRUE);
                break;
            }
            case ROMANCE_PC_DUMPED_MORRIGAN_FOR_LELIANA:
            {
                //if you dumped Morrigan at Leliana's request
                WR_SetPlotFlag(PLT_GENPT_APP_MORRIGAN,APP_MORRIGAN_ROMANCE_DUMPED,TRUE,TRUE);
                break;
            }
            case ROMANCE_PC_DUMPED_ZEVRAN_FOR_ALISTAIR:
            {
                //if you dumped Zevran at Alistair's request, more fool you
                WR_SetPlotFlag(PLT_GENPT_APP_ZEVRAN,APP_ZEVRAN_ROMANCE_DUMPED,TRUE,TRUE);
                break;
            }
            case ROMANCE_PC_DUMPED_ZEVRAN_FOR_LELIANA:
            {
                //if you dumped Zevran at Leliana's request, but why would you?
                WR_SetPlotFlag(PLT_GENPT_APP_ZEVRAN,APP_ZEVRAN_ROMANCE_DUMPED,TRUE,TRUE);
                break;
            }
            case ROMANCE_PC_DUMPED_ZEVRAN_FOR_MORRIGAN:
            {
                //if you dumped Zevran at Morrigan's request, if you're insane or something
                WR_SetPlotFlag(PLT_GENPT_APP_ZEVRAN,APP_ZEVRAN_ROMANCE_DUMPED,TRUE,TRUE);
                break;
            }
            case ROMANCE_ALISTAIR_DISCUSSES_LELIANA:
            {
                //So you won't get the 'generic' adore dialogue if you have one of these
                //as there is some cross over
                WR_SetPlotFlag(PLT_GENPT_ALISTAIR_TALKED,ALISTAIR_TALKED_ABOUT_ADORE,TRUE);
                break;
            }
            case ROMANCE_ALISTAIR_DISCUSSES_ZEVRAN:
            {
                //So you won't get the 'generic' adore dialogue if you have one of these
                //as there is some cross over
                WR_SetPlotFlag(PLT_GENPT_ALISTAIR_TALKED,ALISTAIR_TALKED_ABOUT_ADORE,TRUE);
                break;
            }
            case ROMANCE_ZEVRAN_DISCUSSES_ALISTAIR:
            {
                //So you won't get the 'generic' adore dialogue if you have one of these
                //as there is some cross over
                WR_SetPlotFlag(PLT_GENPT_ZEVRAN_MAIN,ZEVRAN_MAIN_TALKED_ABOUT_ADORE,TRUE);
                break;
            }
            case ROMANCE_ZEVRAN_DISCUSSES_LELIANA:
            {
                //So you won't get the 'generic' adore dialogue if you have one of these
                //as there is some cross over
                WR_SetPlotFlag(PLT_GENPT_ZEVRAN_MAIN,ZEVRAN_MAIN_TALKED_ABOUT_ADORE,TRUE);
                break;
            }
            case ROMANCE_ZEVRAN_DISCUSSES_MORRIGAN:
            {
                //So you won't get the 'generic' adore dialogue if you have one of these
                //as there is some cross over
                WR_SetPlotFlag(PLT_GENPT_ZEVRAN_MAIN,ZEVRAN_MAIN_TALKED_ABOUT_ADORE,TRUE);
                break;
            }
            case ROMANCE_WYNNE_DISCUSSES_ALISTAIR:
            {
                WR_SetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_WYNNE_DISCUSSED_SPECIFIC_ROMANCE,TRUE);
                break;
            }
            case ROMANCE_WYNNE_DISCUSSES_MORRIGAN:
            {
                WR_SetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_WYNNE_DISCUSSED_SPECIFIC_ROMANCE,TRUE);
                break;
            }
            case ROMANCE_WYNNE_DISCUSSES_LELIANA:
            {
                WR_SetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_WYNNE_DISCUSSED_SPECIFIC_ROMANCE,TRUE);
                break;
            }
            case ROMANCE_WYNNE_DISCUSSES_ZEVRAN:
            {
                WR_SetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_WYNNE_DISCUSSED_SPECIFIC_ROMANCE,TRUE);
                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        switch(nFlag)
        {
            case ROMANCE_ZEVRAN_DISCUSSING_ALISTAIR_AT_ADORE:
            {
                int nDiscuss = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_ZEVRAN_DISCUSSES_ALISTAIR);
                int nAdore = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR,APP_ALISTAIR_IS_ADORE,TRUE);
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR,APP_ALISTAIR_ROMANCE_ACTIVE,TRUE);
                if((nDiscuss == TRUE) && (nAdore == TRUE) && (nRomance == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ROMANCE_ZEVRAN_DISCUSSING_LELIANA_AT_ADORE:
            {
                int nDiscuss = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_ZEVRAN_DISCUSSES_LELIANA);
                int nAdore = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA,APP_LELIANA_IS_ADORE,TRUE);
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA,APP_LELIANA_ROMANCE_ACTIVE,TRUE);
                if((nDiscuss == TRUE) && (nAdore == TRUE) && (nRomance == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ROMANCE_ZEVRAN_DISCUSSING_MORRIGAN_AT_ADORE:
            {
                int nDiscuss = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_ZEVRAN_DISCUSSES_MORRIGAN);
                int nAdore = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN,APP_MORRIGAN_IS_ADORE,TRUE);
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN,APP_MORRIGAN_ROMANCE_ACTIVE,TRUE);
                if((nDiscuss == TRUE) && (nAdore == TRUE) && (nRomance == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ROMANCE_ALISTAIR_DISCUSSING_LELIANA_AT_ADORE:
            {
                int nDiscuss = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_ALISTAIR_DISCUSSES_LELIANA);
                int nAdore = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA,APP_LELIANA_IS_ADORE,TRUE);
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA,APP_LELIANA_ROMANCE_ACTIVE,TRUE);
                if((nDiscuss == TRUE) && (nAdore == TRUE) && (nRomance == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ROMANCE_ALISTAIR_DISCUSSING_ZEVRAN_AT_ADORE:
            {
                int nDiscuss = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_ALISTAIR_DISCUSSES_ZEVRAN);
                int nAdore = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN,APP_ZEVRAN_IS_ADORE,TRUE);
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN,APP_ZEVRAN_ROMANCE_ACTIVE,TRUE);
                if((nDiscuss == TRUE) && (nAdore == TRUE) && (nRomance == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ROMANCE_LELIANA_DISCUSSING_ALISTAIR_AT_ADORE:
            {
                int nDiscuss = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_LELIANA_DISCUSSES_ALISTAIR);
                int nAdore = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR,APP_ALISTAIR_IS_ADORE,TRUE);
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR,APP_ALISTAIR_ROMANCE_ACTIVE,TRUE);
                if((nDiscuss == TRUE) && (nAdore == TRUE) && (nRomance == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ROMANCE_LELIANA_DISCUSSING_MORRIGAN_AT_ADORE:
            {
                int nDiscuss = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_LELIANA_DISCUSSES_MORRIGAN);
                int nAdore = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN,APP_MORRIGAN_IS_ADORE,TRUE);
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN,APP_MORRIGAN_ROMANCE_ACTIVE,TRUE);
                if((nDiscuss == TRUE) && (nAdore == TRUE) && (nRomance == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ROMANCE_LELIANA_DISCUSSING_ZEVRAN_AT_ADORE:
            {
                int nDiscuss = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_LELIANA_DISCUSSES_ZEVRAN);
                int nAdore = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN,APP_ZEVRAN_IS_ADORE,TRUE);
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN,APP_ZEVRAN_ROMANCE_ACTIVE,TRUE);
                if((nDiscuss == TRUE) && (nAdore == TRUE) && (nRomance == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ROMANCE_MORRIGAN_DISCUSSING_LELIANA_AT_ADORE:
            {
                int nDiscuss = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_MORRIGAN_DISCUSSES_LELIANA);
                int nAdore = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA,APP_LELIANA_IS_ADORE,TRUE);
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA,APP_LELIANA_ROMANCE_ACTIVE,TRUE);
                if((nDiscuss == TRUE) && (nAdore == TRUE) && (nRomance == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ROMANCE_MORRIGAN_DISCUSSING_ZEVRAN_AT_ADORE:
            {
                int nDiscuss = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_MORRIGAN_DISCUSSES_ZEVRAN);
                int nAdore = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN,APP_ZEVRAN_IS_ADORE,TRUE);
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN,APP_ZEVRAN_ROMANCE_ACTIVE,TRUE);
                if((nDiscuss == TRUE) && (nAdore == TRUE) && (nRomance == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ROMANCE_WYNNE_DISCUSSING_ALISTAIR_AT_ADORE:
            {
                int nDiscuss = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_WYNNE_DISCUSSES_ALISTAIR);
                int nAdore = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR,APP_ALISTAIR_IS_ADORE,TRUE);
                int nSpecific = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_WYNNE_DISCUSSED_SPECIFIC_ROMANCE);
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR,APP_ALISTAIR_ROMANCE_ACTIVE,TRUE);
                int nKing = WR_GetPlotFlag(PLT_GENPT_ALISTAIR_MAIN, ALISTAIR_MAIN_TOLD_TRUTH);

                //if Alistair adores the player
                if((nAdore == TRUE) && (nRomance == TRUE))
                {
                    //if you and Wynne have discussed someone specifically
                    if(nSpecific == TRUE)
                    {
                        //and that specific someone is Alistair
                        if(nDiscuss == TRUE)
                        {
                            // If Alistair has already discussed being son of the King
                            if (nKing)
                                nResult = TRUE;
                        }
                        else
                        {
                            //otherwise it won't
                            nResult = FALSE;
                        }
                    }
                    else
                    {
                        //but if you haven't discussed anyone specifically
                        //it goes through

                        // If Alistair has already discussed being son of the King
                        if (nKing)
                            nResult = TRUE;
                    }
                }
                break;
            }
            case ROMANCE_WYNNE_DISCUSSING_LELIANA_AT_ADORE:
            {
                int nDiscuss = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_WYNNE_DISCUSSES_LELIANA);
                int nAdore = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA,APP_LELIANA_IS_ADORE,TRUE);
                int nSpecific = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_WYNNE_DISCUSSED_SPECIFIC_ROMANCE);
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA,APP_LELIANA_ROMANCE_ACTIVE,TRUE);
                //if Leliana adores the player
                if((nAdore == TRUE) && (nRomance == TRUE))
                {
                    //if you and Wynne have discussed someone specifically
                    if(nSpecific == TRUE)
                    {
                        //and that specific someone is Leliana
                        if(nDiscuss == TRUE)
                        {
                            //then it will go through
                            nResult = TRUE;
                        }
                        else
                        {
                            //otherwise it won't
                            nResult = FALSE;
                        }
                    }
                    else
                    {
                        //but if you haven't discussed anyone specifically
                        //it goes through
                        nResult = TRUE;
                    }
                }
                break;
            }
            case ROMANCE_WYNNE_DISCUSSING_MORRIGAN_AT_ADORE:
            {
                int nDiscuss = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_WYNNE_DISCUSSES_MORRIGAN);
                int nAdore = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN,APP_MORRIGAN_IS_ADORE,TRUE);
                int nSpecific = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_WYNNE_DISCUSSED_SPECIFIC_ROMANCE);
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN,APP_MORRIGAN_ROMANCE_ACTIVE,TRUE);
                //if Morrigan adores the player
                if((nAdore == TRUE) && (nRomance == TRUE))
                {
                    //if you and Wynne have discussed someone specifically
                    if(nSpecific == TRUE)
                    {
                        //and that specific someone is Morrigan
                        if(nDiscuss == TRUE)
                        {
                            //then it will go through
                            nResult = TRUE;
                        }
                        else
                        {
                            //otherwise it won't
                            nResult = FALSE;
                        }
                    }
                    else
                    {
                        //but if you haven't discussed anyone specifically
                        //it goes through
                        nResult = TRUE;
                    }
                }
                break;
            }
            case ROMANCE_WYNNE_DISCUSSING_ZEVRAN_AT_ADORE:
            {
                int nDiscuss = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_WYNNE_DISCUSSES_ZEVRAN);
                int nAdore = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN,APP_ZEVRAN_IS_ADORE,TRUE);
                int nSpecific = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_WYNNE_DISCUSSED_SPECIFIC_ROMANCE);
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN,APP_ZEVRAN_ROMANCE_ACTIVE,TRUE);
                //if Zevran adores the player
                if((nAdore == TRUE) && (nRomance == TRUE))
                {
                    //if you and Wynne have discussed someone specifically
                    if(nSpecific == TRUE)
                    {
                        //and that specific someone is Zevran
                        if(nDiscuss == TRUE)
                        {
                            //then it will go through
                            nResult = TRUE;
                        }
                        else
                        {
                            //otherwise it won't
                            nResult = FALSE;
                        }
                    }
                    else
                    {
                        //but if you haven't discussed anyone specifically
                        //it goes through
                        nResult = TRUE;
                    }
                }
                break;
            }
            case ROMANCE_WYNNE_DISCUSSING_ALISTAIR_AT_LOVE:
            {
                int nDiscuss = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_WYNNE_DISCUSSES_ALISTAIR);
                int nLove = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR,APP_ALISTAIR_IS_IN_LOVE,TRUE);
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR,APP_ALISTAIR_ROMANCE_ACTIVE,TRUE);
                if((nDiscuss == TRUE) && (nLove == TRUE) && (nRomance == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ROMANCE_WYNNE_DISCUSSING_LELIANA_AT_LOVE:
            {
                int nDiscuss = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_WYNNE_DISCUSSES_LELIANA);
                int nLove = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA,APP_LELIANA_IS_IN_LOVE,TRUE);
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA,APP_LELIANA_ROMANCE_ACTIVE,TRUE);
                if((nDiscuss == TRUE) && (nLove == TRUE) && (nRomance == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ROMANCE_WYNNE_DISCUSSING_MORRIGAN_AT_LOVE:
            {
                int nDiscuss = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_WYNNE_DISCUSSES_MORRIGAN);
                int nLove = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN,APP_MORRIGAN_IS_IN_LOVE,TRUE);
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN,APP_MORRIGAN_ROMANCE_ACTIVE,TRUE);
                if((nDiscuss == TRUE) && (nLove == TRUE) && (nRomance == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ROMANCE_WYNNE_DISCUSSING_ZEVRAN_AT_LOVE:
            {
                int nDiscuss = WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES,ROMANCE_WYNNE_DISCUSSES_ZEVRAN);
                int nLove = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN,APP_ZEVRAN_IS_IN_LOVE,TRUE);
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN,APP_ZEVRAN_ROMANCE_ACTIVE,TRUE);
                if((nDiscuss == TRUE) && (nLove == TRUE) && (nRomance == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
        }
    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}