//::///////////////////////////////////////////////
//:: Plot Events
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for Scribe
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: October 10, 2006
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "bhn_constants_h"

#include "plt_bhn100pt_scribe"

int StartingConditional()
{
    event eParms = GetCurrentEvent();                // Contains all input parameters
    int nType = GetEventType(eParms);               // GET or SET call
    string strPlot = GetEventString(eParms, 0);         // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);          // The bit flag # being affected
    object oParty = GetEventCreator(eParms);      // The owner of the plot table for this script
    int nGetResult = FALSE; // used to return value for DEFINED GET events
    object oPlayer = GetHero();
    object oScribe = UT_GetNearestCreatureByTag(oPlayer, BHN_CR_SCRIBE);

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
            case BHN_SCRIBE_NAPS:
            {
                effect eSleep = EffectSleep(EFFECT_TYPE_SLEEP);
                RemoveEffect(oScribe,eSleep);
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT,eSleep,oScribe,0.0f,oScribe,ABILITY_SPELL_SLEEP);
//                RemoveVisualEffect(oScribe,BHN_SLEEPING_VISUAL_EFFECT);
//                effect eSleep = EffectSleep(EFFECT_TYPE_SLEEP);
//                ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT,eSleep,oScribe,0.0f,oScribe);
//                ApplyEffectVisualEffect(oScribe,oScribe,BHN_SLEEPING_VISUAL_EFFECT,EFFECT_DURATION_TYPE_PERMANENT,6.0);
                break;
            }
            case BHN_SCRIBE_MOVES_AWAY:
            {   
                // Qwinn - no longer needed
                // object oWP = UT_GetNearestObjectByTag(oPlayer, BHN_WP_SCRIBE_AFTER_TALK);
                // -----------------------------------------------------
                // ACTION: Aldous goes to a chair and sits down, taking a nap.
                // -----------------------------------------------------
                // Qwinn:  The movetoobject doesn't work following dialogue.  LocalJump does.
                // WR_AddCommand(oScribe, CommandMoveToObject(oWP, FALSE));
                UT_LocalJump(oScribe, BHN_WP_SCRIBE_AFTER_TALK, TRUE, TRUE, TRUE);                
/*
                object oSquire1 = UT_GetNearestCreatureByTag(oPlayer, BHN_CR_SQUIRE1);
                object oSquire2 = UT_GetNearestCreatureByTag(oPlayer, BHN_CR_SQUIRE2);
                // -----------------------------------------------------
                // The two squires will be reading.
                // -----------------------------------------------------
                AMB_StartAmbientAI(oSquire1);
                AMB_StartAmbientAI(oSquire2);
*/              SetLocalInt(oScribe,AMBIENT_ANIM_PATTERN,0);
                SetLookAtEnabled(oScribe,FALSE);
                //ApplyEffectVisualEffect(oScribe,oScribe,BHN_SLEEPING_VISUAL_EFFECT,EFFECT_DURATION_TYPE_PERMANENT,6.0);
                break;
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        switch(nFlag)
        {
        }
    }

    return nGetResult;
}