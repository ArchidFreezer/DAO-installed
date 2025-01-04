//==============================================================================
/*
    den300cr_otto.nss

    Script to make Otto "surrender" during the fight with the first demon in the
    Abandoned Orphanage.
*/
//==============================================================================
//  Created By: Kaelin
//  Created On: 01/06/09
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"

#include "sys_ambient_h"
#include "den_constants_h"

#include "plt_den300pt_some_wicked"

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
        // Sent by: AI scripts
        // When: The current creatures suffered 1 or more points of damage in a
        //       single attack
        //----------------------------------------------------------------------
        case EVENT_TYPE_DAMAGED:
        {

            object  oDamager    =   GetEventCreator(ev);

            int     nDamage     =   GetEventInteger(ev, 0);
            int     nDamageType =   GetEventInteger(ev, 1);
            int     bDemonFight =   WR_GetPlotFlag(PLT_DEN300PT_SOME_WICKED, WICKED_ORPHANAGE_DEMON_APPEARS);
            // Qwinn:  Added this here as this code seems meant just for the orphanage fight, and may mess things up if
            // it happens in the slum house, since the "right conversation" referred to can't happen after that point.
            int     bDemonFightOver =   WR_GetPlotFlag(PLT_DEN300PT_SOME_WICKED, OTTO_GOES_TO_SLUM_HOUSE);

            float   fCurrentHP  =   GetCurrentHealth(OBJECT_SELF);

            if((fCurrentHP <= 2.0f)  && (bDemonFight) && (!bDemonFightOver))
            {
                // Set Otto to neutral to end combat.
                SetGroupId(OBJECT_SELF, GROUP_NEUTRAL);

                WR_ClearAllCommands(OBJECT_SELF);

                int nWounded    =   946;
                int nContinue   =   948;

                command cDying  =   CommandPlayAnimation(nWounded, nContinue, 1);

                // Have him play the wounded animation.
                WR_AddCommand(OBJECT_SELF, cDying, TRUE, TRUE);

                // Set the plot flag for the right conversation to initiate.
                WR_SetPlotFlag(PLT_DEN300PT_SOME_WICKED, OTTO_DYING_AT_ORPHANAGE, TRUE, TRUE);

            }

            break;

        }

        //----------------------------------------------------------------------
        // Sent by: AI scripts
        // When: The current creature dies
        //----------------------------------------------------------------------
        case EVENT_TYPE_DEATH:
        {

            object oKiller = GetEventCreator(ev);

            break;

        }


    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_CREATURE_CORE);
    }
}