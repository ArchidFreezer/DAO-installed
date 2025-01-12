//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    New plot events for Qwinn Fixpack version 3.0
*/
//:://////////////////////////////////////////////
//:: Created By: Paul Escalona
//:: Created On: February 20, 2017
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "plt_qwinn_approval"
#include "plt_genpt_app_alistair"
#include "plt_genpt_app_leliana"
#include "plt_genpt_app_morrigan"
#include "plt_genpt_app_zevran"
#include "plt_genpt_romance_triangles"
#include "plt_gen00pt_class_race_gend"

#include "approval_h"



int StartingConditional()
{
    event eParms = GetCurrentEvent();                // Contains all input parameters
    int nType = GetEventType(eParms);               // GET or SET call
    string strPlot = GetEventString(eParms, 0);         // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);          // The bit flag # being affected
    object oParty = GetEventCreator(eParms);      // The owner of the plot table for this script
    int nResult = FALSE; // used to return value for DEFINED GET events

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info
    object oPC = GetHero();

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);
            // On SET call, the value about to be written
            //(on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);
            // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
            // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case PRE_RECRUIT_MORRIGAN_TOGGLE:
            {
                object oMorrigan = Party_GetFollowerByTag(GEN_FL_MORRIGAN);
                if (nValue)
                {
                    int nStoredApproval = GetLocalInt(GetModule(),APP_APPROVAL_GIFT_COUNT_MORRIGAN);
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY,GEN_MORRIGAN_RECRUITED,TRUE,FALSE);
                    WR_SetFollowerState(oMorrigan, FOLLOWER_STATE_UNAVAILABLE, FALSE);
                    SetFollowerApprovalEnabled(oMorrigan, TRUE);
                    SetFollowerApprovalDescription(oMorrigan, 371487);
                    Approval_ChangeApproval(APP_FOLLOWER_MORRIGAN,nStoredApproval);
                    SetLocalInt(GetModule(),APP_APPROVAL_GIFT_COUNT_MORRIGAN,0);
                }
                else
                {
                    SetLocalInt(GetModule(),APP_APPROVAL_GIFT_COUNT_MORRIGAN,GetFollowerApproval(oMorrigan));
                    WR_SetFollowerState(oMorrigan, FOLLOWER_STATE_INVALID, FALSE);
                }
                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        switch(nFlag)
        {
            case QW_ROMANCE_ACTIVE_ALISTAIR:
            {
               if (WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_ACTIVE))
                  nResult = TRUE;
               break;
            }

            case QW_ROMANCE_ACTIVE_LELIANA:
            {
               if (WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_ROMANCE_ACTIVE))
                  nResult = TRUE;
               break;
            }

            case QW_ROMANCE_ACTIVE_MORRIGAN:
            {
               if (WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_ACTIVE))
                  nResult = TRUE;
               break;
            }

            case QW_ROMANCE_ACTIVE_ZEVRAN:
            {
               if (WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_ROMANCE_ACTIVE))
                  nResult = TRUE;
               break;
            }

            case QW_DUMPED_MORRIGAN_FOR_LELIANA_AND_IN_LOVE_LELIANA:
            {
                int nInLoveLeliana = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA,APP_LELIANA_IS_IN_LOVE);
                int nDumpedMorriganForLeliana =
                   (WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES, ROMANCE_PC_DUMPED_MORRIGAN_FOR_LELIANA) ||
                    WR_GetPlotFlag(PLT_QWINN_APPROVAL, MORRIGAN_ULTIMATUM_CHOSE_LELIANA));
                if (nInLoveLeliana && nDumpedMorriganForLeliana)
                    nResult = TRUE;
               break;
            }

            case QW_DUMPED_LELIANA_FOR_MORRIGAN_AND_IN_LOVE_MORRIGAN:
            {
               int nInLoveMorrigan = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN,APP_MORRIGAN_IS_IN_LOVE);
               int nDumpedLelianaForMorrigan =
                   (WR_GetPlotFlag(PLT_GENPT_ROMANCE_TRIANGLES, ROMANCE_PC_DUMPED_LELIANA_FOR_MORRIGAN) ||
                    WR_GetPlotFlag(PLT_QWINN_APPROVAL, LELIANA_ULTIMATUM_CHOSE_MORRIGAN));
               if (nInLoveMorrigan && nDumpedLelianaForMorrigan)
                   nResult = TRUE;

               break;
            }

            case QW_MORRIGAN_IN_LOVE_LELIANA_ROMANCE_NOT_ACTIVE:
            {
               int nLelianaRomance = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_ROMANCE_ACTIVE);
               int nMorriganInLove = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN,APP_MORRIGAN_IS_IN_LOVE);

               if (nMorriganInLove && !nLelianaRomance)
                  nResult = TRUE;

               break;
            }

            case QW_PC_MALE_MORRIGAN_ROMANCE_CAN_RESTART:
            {
               int nMale = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_MALE);
               int nCannotRestart = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_CAN_NOT_RESTART);
               if (nMale && !nCannotRestart)
                  nResult = TRUE;
               break;
            }

            case QW_ALISTAIR_NOT_ROMANCED_NOT_WARM:
            {
               int nWarm = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_WARM);
               int nRomanced = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_ACTIVE);
               if (!nWarm && !nRomanced)
                  nResult = TRUE;
               break;
            }

            case QW_FEMALE_LELIANA_IS_IN_LOVE:
            {
               int bFemale = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_FEMALE);
               int bLove = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_IS_IN_LOVE);
               if (bFemale && bLove)
                  nResult = TRUE;
               break;
            }

            case QW_ALISTAIR_ROMANCE_ACTIVE_DID_NOT_MAKE_LOVE:
            {
               int nRomance  = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_ACTIVE);
               int nMadeLove = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_MAKE_LOVE);
               if (nRomance && !nMadeLove)
                  nResult = TRUE;
               break;
            }

        }
    }

    return nResult;
}