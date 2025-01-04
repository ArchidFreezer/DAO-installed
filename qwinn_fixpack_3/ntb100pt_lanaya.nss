//::///////////////////////////////////////////////
//:: Plot Events
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for Lanaya
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: Jan 22/07
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "plt_ntb100pt_lanaya"
#include "plt_gen00pt_skills"
#include "ntb_constants_h"

#include "plt_cod_hst_dalish1"

#include "plt_qwinn"

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
    object oLanaya = UT_GetNearestCreatureByTag(oPC,NTB_CR_LANAYA);


    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            // Qwinn:  Replaced the logic in the next two cases.
            case NTB_LANAYA_SPEAKS_TO_ZATHRIAN:
            {
                // -----------------------------------------------------
                //ACTION: Lanaya walks towards Zath and inits "elf01_lana_zath" dialog.
                //At that point Lanaya would return to her old spot.
                //If anyone tries to speak to her en route,
                //she will simply say "I'm sorry, but I cannot speak now."
                //If she sees the player taking anything out of the chest
                //(this may be tricky scripting,
                //alter this to whatever you can do if need be)
                //then she will initiate a seperate 'angry' dialogue
                //and a global will be set on her that she is angry with the PC
                //and will no longer talk to him. ***
                // -----------------------------------------------------
                // UT_LocalJump(oLanaya,NTB_WP_WOUNDED_TENTS);
                // UT_Talk(oLanaya,oPC);

                if(nValue)
                {
                    object oZathrian = UT_GetNearestCreatureByTag(oPC,NTB_CR_ZATHRIAN);
                    if(IsObjectValid(oZathrian))
                    {
                       SetObjectInteractive(oLanaya, FALSE);
                       command cMove = CommandMoveToObject(oZathrian,TRUE,3.0);
                       AddCommand(oLanaya,cMove,TRUE,TRUE);
                    }
                }

                break;
            }
            case NTB_LANAYA_RETURNS_TO_POST_AFTER_ZATHRIAN:
            {
                // -----------------------------------------------------
                //ACTION: Lanaya returns to her spot
                // -----------------------------------------------------
                // UT_LocalJump(oLanaya,NTB_WP_LANAYA_POST);\
                WR_SetPlotFlag(PLT_QWINN, NTB_LANAYA_PC_CAN_OPEN_CHEST, FALSE);
                UT_QuickMoveObject(oLanaya, NTB_WP_LANAYA_POST);
                break;
            }
            case NTB_LANAYA_CODEX_HISTORY_1:
            {
                // -----------------------------------------------------
                //ACTION: Give out the First Dalish History codex
                // -----------------------------------------------------
                WR_SetPlotFlag(PLT_COD_HST_DALISH1, COD_HST_DALISH1_MAIN,TRUE,TRUE);

                break;
            }
            //for each of the following cases - if one variable is set - make sure the rest are unset
            case NTB_LANAYA_PERSONAL_ATTITUDE_1:
            {
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_PERSONAL_ATTITUDE_2, FALSE);
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_PERSONAL_ATTITUDE_3, FALSE);
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_PERSONAL_ATTITUDE_4, FALSE);
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_PERSONAL_ATTITUDE_5, FALSE);
                break;
            }
            case NTB_LANAYA_PERSONAL_ATTITUDE_2:
            {
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_PERSONAL_ATTITUDE_1, FALSE);
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_PERSONAL_ATTITUDE_3, FALSE);
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_PERSONAL_ATTITUDE_4, FALSE);
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_PERSONAL_ATTITUDE_5, FALSE);
                break;
            }
            case NTB_LANAYA_PERSONAL_ATTITUDE_3:
            {
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_PERSONAL_ATTITUDE_1, FALSE);
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_PERSONAL_ATTITUDE_2, FALSE);
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_PERSONAL_ATTITUDE_4, FALSE);
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_PERSONAL_ATTITUDE_5, FALSE);
                break;
            }
            case NTB_LANAYA_PERSONAL_ATTITUDE_4:
            {
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_PERSONAL_ATTITUDE_1, FALSE);
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_PERSONAL_ATTITUDE_2, FALSE);
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_PERSONAL_ATTITUDE_3, FALSE);
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_PERSONAL_ATTITUDE_5, FALSE);
                break;
            }
            case NTB_LANAYA_PERSONAL_ATTITUDE_5:
            {
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_PERSONAL_ATTITUDE_1, FALSE);
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_PERSONAL_ATTITUDE_2, FALSE);
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_PERSONAL_ATTITUDE_3, FALSE);
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_PERSONAL_ATTITUDE_4, FALSE);
                break;
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        switch(nFlag)
        {
            case NTB_LANAYA_ATTITUDE_AND_PERSUADE_CHECK:
            {
                int nAttitude = WR_GetPlotFlag(PLT_NTB100PT_LANAYA,NTB_LANAYA_PERSONAL_ATTITUDE_5,TRUE);
                int nPersuadeLow = WR_GetPlotFlag(PLT_GEN00PT_SKILLS,GEN_PERSUADE_LOW,TRUE);
                int nPersuadeHigh = WR_GetPlotFlag(PLT_GEN00PT_SKILLS,GEN_PERSUADE_HIGH,TRUE);
                 // -----------------------------------------------------
                //IF THE LANAYA GLOBAL IS 5+, PERSUADE LEVEL OF 2 NEEDED
                // -----------------------------------------------------
               if((nAttitude == TRUE) && (nPersuadeLow == TRUE))
                {
                    nResult = TRUE;
                }
                // -----------------------------------------------------
                //IF LANAYA GLOBAL IS 4-, PERSUADE LEVEL OF 6 NEEDED
                // -----------------------------------------------------
                else if(nPersuadeHigh == TRUE)
                {
                    nResult = TRUE;
                }
                break;
            }
        }
    }

    return nResult;
}