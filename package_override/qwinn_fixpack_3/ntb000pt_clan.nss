//::///////////////////////////////////////////////
//:: Plot Events
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for Clan
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: Jan 18/2007
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "plt_ntb000pt_clan"
#include "plt_ntb100pt_mithra"
#include "ntb_constants_h"
#include "plt_gen00pt_class_race_gend"
#include "plt_gen00pt_backgrounds"

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
    object oModule = GetModule();

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case NTB_CLAN_DECREMENT_ATTITUDE_BY_ONE:
            {
                int nAttitude = GetLocalInt(oModule,NTB_CLAN_ATTITUDE_COUNTER)-1;
                //----------------------------------------------------------------------
                //decrement attitude counter by one
                //----------------------------------------------------------------------
                SetLocalInt(oModule,NTB_CLAN_ATTITUDE_COUNTER,nAttitude);
                break;
            }
            case NTB_CLAN_SET_STARTING_ATTITUDE:
            {
                //----------------------------------------------------------------------
                //NOTE: There should be a "Dalish Attitude" global
                //that gets tracked throughout the module which
                //determines the attitude of the Dalish towards the player.
                //This won't affect Zathrian's dialogue but it will affect others.
                //----------------------------------------------------------------------
                int nDalish = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS,GEN_BACK_ELF_DALISH,TRUE);
                int nElven = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND,GEN_RACE_ELF,TRUE);
                //----------------------------------------------------------------------
                //If the PC is Dalish, start it at +3.
                //----------------------------------------------------------------------
                if(nDalish == TRUE)
                {
                    SetLocalInt(oModule,NTB_CLAN_ATTITUDE_COUNTER,NTB_INT_CLAN_DALISH);
                }
                //----------------------------------------------------------------------
                //If the PC is elven but not Dalish, start it at +1.
                //----------------------------------------------------------------------
                else if(nElven == TRUE)
                {
                    SetLocalInt(oModule,NTB_CLAN_ATTITUDE_COUNTER,NTB_INT_CLAN_ELF);
                }
                //----------------------------------------------------------------------
                //If the PC is human, the global should start at -1.
                //----------------------------------------------------------------------
                else
                {
                    SetLocalInt(oModule,NTB_CLAN_ATTITUDE_COUNTER,NTB_INT_CLAN_OUTSIDER);
                }
                break;
            }
            case NTB_CLAN_INCREMENT_ATTITUDE_BY_ONE:
            {
                int nAttitude = GetLocalInt(oModule,NTB_CLAN_ATTITUDE_COUNTER)+1;
                //----------------------------------------------------------------------
                //increment the clan attitude by one
                //----------------------------------------------------------------------
                SetLocalInt(oModule,NTB_CLAN_ATTITUDE_COUNTER,nAttitude);
                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        switch(nFlag)
        {
            case NTB_CLAN_ATTITUDE_HIGH:
            {
                int nAttitude = GetLocalInt(oModule,NTB_CLAN_ATTITUDE_COUNTER);
                //----------------------------------------------------------------------
                //check the incremental variable; if high
                //----------------------------------------------------------------------
                if(nAttitude > NTB_INT_CLAN_ATTITUDE_HIGH)
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_CLAN_ATTITUDE_LOW:
            {
                int nAttitude = GetLocalInt(oModule,NTB_CLAN_ATTITUDE_COUNTER);
                //----------------------------------------------------------------------
                //check the incremental variable
                //(if clan global is -2 or lower)
                //----------------------------------------------------------------------
                if(nAttitude < NTB_INT_CLAN_ATTITUDE_MED)
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_CLAN_ATTITUDE_LOW_OR_MITHRA_DISLIKES_PC:
            {
                int nAttitude = WR_GetPlotFlag(PLT_NTB000PT_CLAN,NTB_CLAN_ATTITUDE_LOW,TRUE);
                int nMithra = WR_GetPlotFlag(PLT_NTB100PT_MITHRA,NTB_MITHRA_DISLIKES_PC,TRUE);
                //----------------------------------------------------------------------
                //if the clan attitude is low
                //or Mithra already dislikes the PC
                //----------------------------------------------------------------------
                if((nAttitude == TRUE) || (nMithra == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }

            // Qwinn:  The next two conditions are checked in ntb100cr_varathorn.dlg when asking for 2 items
            // But if the player is not Dalish and attitude is high, both return true, giving two similar
            // response choices with different persuade checks.  Fixing so only one can be returned as true.
            case NTB_CLAN_PC_DALISH_OR_ATTITUDE_HIGH:
            {
                int nDalish = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS,GEN_BACK_ELF_DALISH,TRUE);
                int nAttitude = WR_GetPlotFlag(PLT_NTB000PT_CLAN,NTB_CLAN_ATTITUDE_HIGH,TRUE);
                //----------------------------------------------------------------------
                //if the PC is dalish
                //or the clan attitude is high
                //----------------------------------------------------------------------
                if((nDalish == TRUE) || (nAttitude == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_CLAN_PC_NOT_DALISH_AND_ATTITUDE_MED:
            {
                //
                int nDalish = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS,GEN_BACK_ELF_DALISH,TRUE);
                int nAttitudeMed = WR_GetPlotFlag(PLT_NTB000PT_CLAN,NTB_CLAN_ATTITUDE_MED,TRUE);
                int nAttitudeHigh = WR_GetPlotFlag(PLT_NTB000PT_CLAN,NTB_CLAN_ATTITUDE_HIGH,TRUE);
                //----------------------------------------------------------------------
                //if the PC isn't dalish
                //and the clan attitude is medium
                //----------------------------------------------------------------------
                if ((nDalish == FALSE) && (nAttitudeMed == TRUE) && (nAttitudeHigh == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_CLAN_ATTITUDE_MED:
            {
                int nAttitude = GetLocalInt(oModule,NTB_CLAN_ATTITUDE_COUNTER);
                //----------------------------------------------------------------------
                //if the clan attitude is medium
                //----------------------------------------------------------------------
                if(nAttitude > NTB_INT_CLAN_ATTITUDE_LOW)
                {
                    nResult = TRUE;
                }
                break;
            }
        }
    }

    return nResult;
}