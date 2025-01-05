//==============================================================================
/*

     Dwarven Noble
        -> Dwarven Noble Proving Event Script

     Events for Arena Matches:
     ---------------------------------------------------------------------------
     ENTER
     START
     WIN
     LOSE
     EXIT

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: October 17, 2007
//==============================================================================

#include "gen00pt_proving"
#include "proving_h"

// Custom Includes
#include "plt_bdc140pt_everd"
#include "bdc_constants_h"

void main()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evCurEvent  = GetCurrentEvent();           // Event parameters
    int     nEventType  = GetEventType(evCurEvent);    // Event type triggered
    object  oEventOwner = GetEventCreator(evCurEvent); // Triggering character
    object  oPC         = GetHero();
    int     bEvHandled  = FALSE;

    //--------------------------------------------------------------------------
    // Events
    //--------------------------------------------------------------------------

    switch(nEventType)
    {

        //----------------------------------------------------------------------
        // EVENT_TYPE_PROVING_ENTER
        //----------------------------------------------------------------------

        case EVENT_TYPE_PROVING_ENTER:
        {

            //------------------------------------------------------------------
            // This event is sent when the PC enters the Proving Arena. This
            // event should be used to set up what happens when the PC enters.
            //------------------------------------------------------------------

            // Get the current Fight
            int nFightID = Proving_GetCurrentFightId();

            // Dectivate the fighters in the area to avoid stage conflict.
            UT_TeamAppears( PROVING_TEAM_NON_COMBATANT, FALSE );

            if (nFightID == PROVING_FIGHT_001_BDC_MAINAR)
            {
                //Make Everd's armor and helmet irremovable.
                object oArmor = GetItemInEquipSlot(INVENTORY_SLOT_CHEST, oPC);
                object oHelmet = GetItemInEquipSlot(INVENTORY_SLOT_HEAD, oPC);
                // No way due to no helmet hack
                // SetItemIrremovable(oArmor, TRUE);
                // SetItemIrremovable(oHelmet, TRUE);
            }

            object oDuncan = UT_GetNearestObjectByTag(oPC, BDC_CR_DUNCAN);
            SetPhysicsController(oDuncan, FALSE);
            WR_SetObjectActive(oDuncan, TRUE);

            break;

        }

        //----------------------------------------------------------------------
        // EVENT_TYPE_PROVING_START
        //----------------------------------------------------------------------

        case EVENT_TYPE_PROVING_START:
        {

            //------------------------------------------------------------------
            // This event is sent when combat starts for the PC
            //------------------------------------------------------------------

            int nFightID = Proving_GetCurrentFightId();
            int bDrugged = WR_GetPlotFlag(PLT_BDC140PT_EVERD, BDC_EVERD_DRUG_USED_BY_SOMEONE, TRUE);

            if ((nFightID == PROVING_FIGHT_001_BDC_MAINAR) && (bDrugged == TRUE))
            {
                object oMainar = UT_GetNearestObjectByTag(oPC, BDC_CR_MAINAR);
                AddAbility(oMainar, ABILITY_TRAIT_CLUMSY);
                AddAbility(oMainar, ABILITY_TRAIT_WEAKLY);
            }



            // Pass the rest of the work onto proving_core
            // bEvHandled = TRUE;

            break;

        }

        //----------------------------------------------------------------------
        // EVENT_TYPE_PROVING_WIN
        //----------------------------------------------------------------------

        case EVENT_TYPE_PROVING_WIN:
        {

            //------------------------------------------------------------------
            // This event is sent when the PC Wins.
            //------------------------------------------------------------------

            // Pass the rest of the work onto proving_core
            // bEvHandled = TRUE;

            break;

        }

        //----------------------------------------------------------------------
        // EVENT_TYPE_PROVING_LOSE
        //----------------------------------------------------------------------

        case EVENT_TYPE_PROVING_LOSE:
        {

            //------------------------------------------------------------------
            // This event is sent when the PC Loses.
            //------------------------------------------------------------------

            // Pass the rest of the work onto proving_core
            // bEvHandled = TRUE;

            break;

        }

        //----------------------------------------------------------------------
        // EVENT_TYPE_PROVING_EXIT
        //----------------------------------------------------------------------

        case EVENT_TYPE_PROVING_EXIT:
        {

            //------------------------------------------------------------------
            // This event is sent when the PC exits the Proving Arena. This
            // event should be used to set up what happens after the PC exits.
            //------------------------------------------------------------------

            int nFightID = Proving_GetCurrentFightId();

            // Activate the non-fighter versions in the area to avoid stage conflict.
            UT_TeamAppears( PROVING_TEAM_NON_COMBATANT, TRUE );

            // Pass the rest of the work onto proving_core
            // bEvHandled = TRUE;

            break;

        }

    }

    //--------------------------------------------------------------------------
    // If we did not handle this event, use proving_core
    //--------------------------------------------------------------------------

    if (!bEvHandled)
        HandleEvent( evCurEvent, RESOURCE_SCRIPT_PROVING_CORE );

}