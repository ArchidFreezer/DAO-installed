//==============================================================================
/*
    den220tr_thief_pick4.nss

*/
//==============================================================================
//  Created By: Kaelin
//  Created On: 01/09/2009
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"

#include "den_lc_constants_h"
#include "plt_den200pt_thief_pick4"
#include "plt_gen00pt_skills"

//------------------------------------------------------------------------------

void main()
{
    event   ev              =   GetCurrentEvent();

    int     nEventType      =   GetEventType(ev);
    int     nEventHandled   =   FALSE;

    string  sDebug;

    object  oPC             =   GetHero();
    object  oParty          =   GetParty(oPC);


    switch(nEventType)
    {

        //----------------------------------------------------------------------
        // Sent by: The engine
        // When: A creature enters the trigger
        //----------------------------------------------------------------------
        case EVENT_TYPE_ENTER:
        {

            object  oCreature   =   GetEventCreator(ev);

            int bCondition1 = GetHasSkill(SKILL_STEALTH, UT_SKILL_CHECK_VERY_HIGH, oCreature);
            // Qwinn: This should be oCreature, not oPC
            // int bCondition2 = IsStealthy(oPC);
            int bCondition2 = IsStealthy(oCreature);
            int bCondition3 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, THIEF_PICK4_ACTIVE);

            //Qwinn: Added bDisabled, set below if guards are unconscious/drunk/distracted
            //If they are any of the three, initiate dialogue one more time, then disable trigger check
            int bDisabled   = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, GUARDS_DISABLED);

            if (!bDisabled)
            {
               if(IsFollower(oCreature) && bCondition1 && bCondition2 && bCondition3)
               {
                   break;
               }
               else if(IsFollower(oCreature) && bCondition3 && !(WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, THIEF_PICK4_PC_WENT_TOO_FAR)))
               {

                   object  oGuard  =   UT_GetNearestObjectByTag(oCreature, "den220cr_pick4_seneshal_grd");

                   // Qwinn: Added checks for unconscious/drunk/distracted guards. If any, set new plot var Disabled, to only trigger dialogue once.
                   int bUnconscious = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, GUARDS_KNOCKED_UNCONSCIOUS);
                   int bDrunk       = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, GUARDS_ARE_DRUNK);
                   int bDistracted  = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, GUARDS_DISTRACTED_BY_WAITRESS);

                   if((bUnconscious||bDrunk||bDistracted) && !bDisabled)
                   {
                       UT_Talk(oGuard, oCreature);
                   }
                   else if(!bDisabled)
                   {
                       WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK4, THIEF_PICK4_PC_WENT_TOO_FAR, TRUE, TRUE);
                       UT_Talk(oGuard, oCreature);
                   }
               }
            }
            break;
        }
    }

    if (!nEventHandled)
    {

        HandleEvent(ev, RESOURCE_SCRIPT_TRIGGER_CORE);

    }
}