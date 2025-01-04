//::///////////////////////////////////////////////
//:: Plot Events
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for Dairren
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: Oct. 5, 2006
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "var_constants_h"

#include "plt_bhn100pt_dairren"
#include "bhn_constants_h"
#include "plt_bhn100pt_dog"
#include "plt_gen00pt_party"
#include "plt_gen00pt_class_race_gend"

int StartingConditional()
{
    event eParms = GetCurrentEvent();                // Contains all input parameters
    int nType = GetEventType(eParms);               // GET or SET call
    string strPlot = GetEventString(eParms, 0);         // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);          // The bit flag # being affected
    object oParty = GetEventCreator(eParms);      // The owner of the plot table for this script
    int nResult = FALSE; // used to return value for DEFINED GET events
    //CREATURE_COUNTER_1 = Flirt variable
    object oDairren = UT_GetNearestCreatureByTag(OBJECT_SELF,BHN_CR_DAIRREN);
    object oHowePC = UT_GetNearestCreatureByTag(OBJECT_SELF,BHN_CR_HOWE_PC_BEDROOM);
    object oDoor = UT_GetNearestObjectByTag(OBJECT_SELF,BHN_IP_DOOR_PC);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

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
            case BHN_DAIRREN_INCREMENT_FLIRT_ONE:
            {
                int nFlirt = GetLocalInt(oDairren,CREATURE_COUNTER_1)+1;
                // -----------------------------------------------------
                // increment flirt variable
                // -----------------------------------------------------
                // Qwinn - no more stealth restart of quest, added condition
                if(WR_GetPlotFlag(PLT_BHN100PT_DAIRREN,BHN_DAIRREN_END_FLIRT) == FALSE)
                    SetLocalInt(oDairren,CREATURE_COUNTER_1,nFlirt);                
//                Log_Plot("Dairren flirt incremented: " + IntToString(nFlirt),LOG_LEVEL_DEBUG);
                break;
            }
            case BHN_DAIRREN_END_FLIRT:
            {
                //set BHN_DAIRREN_FLIRT to 0
                // -----------------------------------------------------
                // stops the flirting with Dairren
                // -----------------------------------------------------
               SetLocalInt(oDairren,CREATURE_COUNTER_1,0);
//               Log_Plot("Dairren flirt ended.",LOG_LEVEL_DEBUG);
               break;
            }
            case BHN_DAIRREN_KILLED:
            {
                // soldiers appear
                UT_TeamAppears(BHN_TEAM_HOWE_PC);

                // door opens
                SetPlaceableState(oDoor, PLC_STATE_DOOR_OPEN_2);

                // dairren dies
                KillCreature(oDairren,oHowePC);

                // add dog to party
                WR_SetPlotFlag(PLT_BHN100PT_DOG, BHN_DOG_IN_PARTY, TRUE, TRUE);

                // soldiers move into room
                UT_TeamMove(BHN_TEAM_HOWE_PC, BHN_WP_SERVANT_WARNING);

                DoAutoSave();

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BHN_2);

                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case BHN_DAIRREN_CHECK_FLIRT_OVER_ONE:
            {
                int nFlirt = GetLocalInt(oDairren,CREATURE_COUNTER_1);
//                Log_Plot("Dairren flirt level: " + IntToString(nFlirt),LOG_LEVEL_DEBUG);
                // -----------------------------------------------------
                // if some flirting has happened
                // -----------------------------------------------------
                if(nFlirt > 1)
                {
                    nResult = TRUE;
                }
                break;
            }
            case BHN_DAIRREN_CHECK_FLIRT_OVER_ZERO:
            {
                int nFlirt = GetLocalInt(oDairren,CREATURE_COUNTER_1);
//                Log_Plot("Dairren flirt level: " + IntToString(nFlirt),LOG_LEVEL_DEBUG);
                // -----------------------------------------------------
                // if any flirting has happened
                // -----------------------------------------------------
                if(nFlirt > 0)
                {
                    nResult = TRUE;
                }
                break;
            }
            case BHN_DAIRREN_COMING_TO_ROOM_AND_PC_MALE:
            {
                int nDairren = WR_GetPlotFlag(PLT_BHN100PT_DAIRREN,BHN_DAIRREN_COMING_TO_ROOM,TRUE);
                int nGender = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND,GEN_GENDER_MALE,TRUE);
                // -----------------------------------------------------
                // if Dairren has agreed to meet you in your room at night and the PC is male
                // -----------------------------------------------------
                if((nGender == TRUE) && (nDairren == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case BHN_DAIRREN_COMING_TO_ROOM_AND_PC_FEMALE:
            {
                int nDairren = WR_GetPlotFlag(PLT_BHN100PT_DAIRREN,BHN_DAIRREN_COMING_TO_ROOM,TRUE);
                int nGender = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND,GEN_GENDER_FEMALE,TRUE);
                // -----------------------------------------------------
                //  if Dairren has agreed to meet you in your room at night and the PC is female
                // -----------------------------------------------------
                if((nGender == TRUE) && (nDairren == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
        }
    }

    return nResult;
}