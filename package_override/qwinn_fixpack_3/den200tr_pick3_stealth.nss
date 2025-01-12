//:://////////////////////////////////////////////
/*
    Talk Trigger events
    This trigger handles automatic triggering of dialog.
    The following parameter can be set on the trigger: (using the var_trigger_talk table)

    TRIG_TALK_SPEAKER - NPC initiating the dialog - this is the only mandatory field
    TRIG_TALK_REPEAT - 1 so the trigger can re-fire, 0 - the trigger fires only once
    TRIG_TALK_DIALOG_OVERRIDE - a dialog file to override the default one for the NPC.
        Type it in the format of "gen000_example.dlg" (without the quotes).
    TRIG_TALK_SET_PLOT - sets the plot and flag when triggered, works with TRIG_TALK_SET_FLAG
    TRIG_TALK_SET_FLAG - sets the plot and flag when triggered, works with TRIG_TALK_SET_PLOT
    TRIG_TALK_SET_PLOT2 - sets the plot and flag when triggered, works with TRIG_TALK_SET_FLAG2
    TRIG_TALK_SET_FLAG2 - sets the plot and flag when triggered, works with TRIG_TALK_SET_PLOT2
    TRIG_TALK_ACTIVE_FOR_PLOT - triggers only if a specific plot/flag is active - works with TRIG_TALK_ACTIVE_FOR_FLAG
    TRIG_TALK_ACTIVE_FOR_FLAG - triggers only if a specific plot/flag is active - works with TRIG_TALK_ACTIVE_FOR_PLOT
    TRIG_TALK_INACTIVE_FOR_PLOT - triggers only if a specific plot/flag is inactive - works with TRIG_TALK_ACTIVE_FOR_FLAG
    TRIG_TALK_INACTIVE_FOR_FLAG - triggers only if a specific plot/flag is inactive - works with TRIG_TALK_ACTIVE_FOR_PLOT
    TRIG_TALK_LISTENER - a string for an NPC listener. Should be used for ambient conversations
    TRIG_TALK_NO_TALK_IF_STEALTH - if the entering party member is stealthed, do not fire the converstion, but do deactivate the trigger as if it had been fired.
*/
//:://////////////////////////////////////////////
//:: Created By: Yaron Jakobs
//:: Created On: Sep 28th, 2006
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"

#include "plt_qwinn"
#include "plt_den200pt_thief_pick3"

const string NONE = "NONE";

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;

    switch(nEventType)
    {
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature enters the trigger
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_ENTER:
        {
            object oCreature = GetEventCreator(ev);
            if(oCreature != GetMainControlled()) return;
            if (!WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3,PICK3_SILVERSMITH_IS_PRESENT)) return;
            object oSpeaker = UT_GetNearestObjectByTag(oCreature,"den200cr_pick3_silversmith");
            if (!IsObjectValid(oSpeaker)) return;
            
            // Check stealth and guards present
            int bCondition2, bCondition4 = FALSE;
            int nInactiveForFlag = GetLocalInt(OBJECT_SELF, TRIG_TALK_INACTIVE_FOR_FLAG);
            int bCondition1 = IsStealthy(GetMainControlled());
            if ((nInactiveForFlag == 258) || (nInactiveForFlag == 261))
               bCondition2 = HasAbility(oCreature,ABILITY_SKILL_STEALTH_2);
            else
               bCondition2 = HasAbility(oCreature,ABILITY_SKILL_STEALTH_3);
            int bCondition3 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_GUARDS_CHASE_MESSENGER);
            if ((nInactiveForFlag == 261) || (nInactiveForFlag == 262))
               bCondition4 = WR_GetPlotFlag(PLT_QWINN,DEN_PICK3_GUARDS_TALKING);

            if ((bCondition1 && bCondition2) || bCondition3 || bCondition4) return;

            if (bCondition1 && !bCondition2)
                WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_GUARDS_CAUGHT_PC_STEALTHING, TRUE, TRUE);

            UT_Talk(oSpeaker, oCreature);

            break;
        }
    }
}