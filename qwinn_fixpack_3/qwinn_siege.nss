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

#include "plt_qwinn_siege"
#include "arl_constants_h"

int QwinnGetWoundedPlot(int nFlag);
int QwinnGetWoundedPlot(int nFlag)
{
   switch(nFlag)
   {
      case KNIGHT_1_NEEDS_TO_CALL:   return KNIGHT_1_WOUNDED;
      case KNIGHT_2_NEEDS_TO_CALL:   return KNIGHT_2_WOUNDED;
      case KNIGHT_3_NEEDS_TO_CALL:   return KNIGHT_3_WOUNDED;
      case MILITIA_1_NEEDS_TO_CALL:  return MILITIA_1_WOUNDED;
      case MILITIA_2_NEEDS_TO_CALL:  return MILITIA_2_WOUNDED;
      case MILITIA_3_NEEDS_TO_CALL:  return MILITIA_3_WOUNDED;
      case MILITIA_4_NEEDS_TO_CALL:  return MILITIA_4_WOUNDED;
      case MILITIA_5_NEEDS_TO_CALL:  return MILITIA_5_WOUNDED;
      case DRUNK_1_NEEDS_TO_CALL:    return DRUNK_1_WOUNDED;
      case DRUNK_2_NEEDS_TO_CALL:    return DRUNK_2_WOUNDED;
      case DRUNK_3_NEEDS_TO_CALL:    return DRUNK_3_WOUNDED;
      case LLOYD_NEEDS_TO_CALL:      return LLOYD_WOUNDED;
      case DWYN_NEEDS_TO_CALL:       return DWYN_WOUNDED;
      case THUG_1_NEEDS_TO_CALL:     return THUG_1_WOUNDED;
      case THUG_2_NEEDS_TO_CALL:     return THUG_2_WOUNDED;
      case BERWICK_NEEDS_TO_CALL:    return BERWICK_WOUNDED;
   }
   return -1;
}

int QwinnGetCalledPlot(int nFlag);
int QwinnGetCalledPlot(int nFlag)
{
   switch(nFlag)
   {
      case KNIGHT_1_NEEDS_TO_CALL:    return KNIGHT_1_CALLED_FOR_HELP;
      case KNIGHT_2_NEEDS_TO_CALL:    return KNIGHT_2_CALLED_FOR_HELP;
      case KNIGHT_3_NEEDS_TO_CALL:    return KNIGHT_3_CALLED_FOR_HELP;
      case MILITIA_1_NEEDS_TO_CALL:   return MILITIA_1_CALLED_FOR_HELP;
      case MILITIA_2_NEEDS_TO_CALL:   return MILITIA_2_CALLED_FOR_HELP;
      case MILITIA_3_NEEDS_TO_CALL:   return MILITIA_3_CALLED_FOR_HELP;
      case MILITIA_4_NEEDS_TO_CALL:   return MILITIA_4_CALLED_FOR_HELP;
      case MILITIA_5_NEEDS_TO_CALL:   return MILITIA_5_CALLED_FOR_HELP;
      case DRUNK_1_NEEDS_TO_CALL:     return DRUNK_1_CALLED_FOR_HELP;
      case DRUNK_2_NEEDS_TO_CALL:     return DRUNK_2_CALLED_FOR_HELP;
      case DRUNK_3_NEEDS_TO_CALL:     return DRUNK_3_CALLED_FOR_HELP;
      case LLOYD_NEEDS_TO_CALL:       return LLOYD_CALLED_FOR_HELP;
      case DWYN_NEEDS_TO_CALL:        return DWYN_CALLED_FOR_HELP;
      case THUG_1_NEEDS_TO_CALL:      return THUG_1_CALLED_FOR_HELP;
      case THUG_2_NEEDS_TO_CALL:      return THUG_2_CALLED_FOR_HELP;
      case BERWICK_NEEDS_TO_CALL:     return BERWICK_CALLED_FOR_HELP;

   }
   return -1;
}

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
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        int nWoundedFlag = QwinnGetWoundedPlot(nFlag);
        if (nWoundedFlag < 0) return FALSE;
        int nCalledFlag  = QwinnGetCalledPlot(nFlag);
        int nWounded = WR_GetPlotFlag(PLT_QWINN_SIEGE, nWoundedFlag);
        int nCalled  = WR_GetPlotFlag(PLT_QWINN_SIEGE, nCalledFlag);
        if (nWounded && !nCalled) nResult = TRUE;
     }

    return nResult;
}