//------------------------------------------------------------------------------
// cir34otr_inferno
// Copyright (c) 2003 Bioware Corp.
//------------------------------------------------------------------------------
/*
    Event handling for the inferno triggers in the Templar's Nightmare area of
    the Broken Circle. The area the trigger defines is on fire, causing damage
    to contained creatures (start with player only). Handled through  custom
    event callback. Trigger can be activated/deactivated via local variable.
    Activation has associated visual effects.

    TRIGGER_COUNTER_1 is used flag the trigger as active or inactive

    TRIGGER_COUNTER_2 is used to keep a count of the number of creatures within
                      the trigger's boundries.
*/
//------------------------------------------------------------------------------
// July 2008 - Owner: Gary Stewart
//------------------------------------------------------------------------------


#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "effect_dot2_h"
#include "plt_bhm600pt_harrowing"
#include "bhm_constants_h"

//------------------------------------------------------------------------------
// MAIN
//------------------------------------------------------------------------------


void main()
{


    event   evCurEvent  = GetCurrentEvent();           // Event parameters
    int     nEventType  = GetEventType(evCurEvent);    // Event type triggered
    object  oEventOwner = GetEventCreator(evCurEvent); // Triggering character
    object  oThis       = OBJECT_SELF;                 // The trigger


    switch(nEventType)
    {

        //----------------------------------------------------------------------
        // Sent by: The engine
        // When: A creature enters the trigger
        //----------------------------------------------------------------------
        case EVENT_TYPE_ENTER:
        {

            if(IsPartyMember(oEventOwner))
            {

                // WR_SetPlotFlag(PLT_BHM600PT_HARROWING, MOUSE_DEMON_SHOUT_ACTIVE, TRUE);
                // Qwinn:  This line being here caused Mouse to shout "And there is the spirit of rage prematurely.
                // Moved to the else if below.

                object oMouse;
                //First time, mouse barks a string
                if(WR_GetPlotFlag(PLT_BHM600PT_HARROWING, MOUSE_DEMON_SITE_SEEN) == FALSE
                    && WR_GetPlotFlag(PLT_BHM600PT_HARROWING, PC_HAS_WEAPON_AND_BEAR) == FALSE)
                {
                    //They have now seen the site.
                   WR_SetPlotFlag(PLT_BHM600PT_HARROWING, MOUSE_DEMON_SITE_SEEN, TRUE);

                    //Start conversation between mouse and player, depends on current stage as to which mouse we get
                    if(WR_GetPlotFlag(PLT_BHM600PT_HARROWING, SLOTH_TAUGHT_BEAR_SHAPECHANGE) == TRUE)
                    {
                       oMouse = GetObjectByTag(BHM_CR_MOUSE_BEAR);
                    }
                    else
                    {
                        oMouse = GetObjectByTag(BHM_CR_MOUSE);
                    }
                    UT_Talk(oMouse, GetHero());
                }
                else if(WR_GetPlotFlag(PLT_BHM600PT_HARROWING, PC_HAS_WEAPON_AND_BEAR) == TRUE
                    && WR_GetPlotFlag(PLT_BHM600PT_HARROWING, DEMON_HAS_SPAWNED) == FALSE)
                {
                    // Qwinn:  Moved to here.
                    WR_SetPlotFlag(PLT_BHM600PT_HARROWING, MOUSE_DEMON_SHOUT_ACTIVE, TRUE);

                    object oDemon = GetObjectByTag(BHM_CR_DEMON);

                    //Set the demon as active
                    WR_SetObjectActive(oDemon, TRUE);

                    //Start conversation bark with mouse (bear form)
                    oMouse = GetObjectByTag(BHM_CR_MOUSE_BEAR);
                    WR_SetPlotFlag(PLT_BHM600PT_HARROWING, DEMON_HAS_SPAWNED, TRUE);
                    UT_Talk(oMouse, GetHero());
                    DoAutoSave(); //Save the game.
                }

            }



            break;

        }
    }

    HandleEvent(evCurEvent, RESOURCE_SCRIPT_TRIGGER_CORE);
}