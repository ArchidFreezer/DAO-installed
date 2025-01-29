// -----------------------------------------------------------------------------
// item_unique_power
// -----------------------------------------------------------------------------
/*
    Plot item power

    fires an event to the module.

*/
// -----------------------------------------------------------------------------
// georg zoeller
// -----------------------------------------------------------------------------

#include "log_h"
#include "abi_templates"
#include "af_eds_constants_h"
#include "af_logging_h"

void main() {
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev); // CAST (directly from engine) or COMMAND_PENDING (re-directed by rules_core)


    switch(nEventType) {
        case EVENT_TYPE_SPELLSCRIPT_PENDING: {
            //--------------------------------------------------------------
            // Get a structure with the event parameters
            //--------------------------------------------------------------
            struct EventSpellScriptPendingStruct stEvent = Events_GetEventSpellScriptPendingParameters(ev);

            afLogDebug("EVENT_TYPE_SPELLSCRIPT_PENDING: " + Log_GetAbilityNameById(stEvent.nAbility), AF_LOGGROUP_EDS);

            //--------------------------------------------------------------
            // Setting Return Value
            //--------------------------------------------------------------

            Ability_SetSpellscriptPendingEventResult(COMMAND_RESULT_SUCCESS);

            break;

        }

        case EVENT_TYPE_SPELLSCRIPT_CAST: {

            //--------------------------------------------------------------
            // Get a structure with the event parameters
            //--------------------------------------------------------------
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            afLogDebug("EVENT_TYPE_SPELLSCRIPT_CAST: " + Log_GetAbilityNameById(stEvent.nAbility), AF_LOGGROUP_EDS);
            //------------------------------------------------------------------
            // we just hand this through to cast_impact
            //------------------------------------------------------------------
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);

            break;

        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT: {
            //--------------------------------------------------------------
            // Get a structure with the event parameters
            //--------------------------------------------------------------
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);


            afLogDebug("EVENT_TYPE_SPELLSCRIPT_IMPACT: " + Log_GetAbilityNameById(stEvent.nAbility), AF_LOGGROUP_EDS);

            event ev = Event(EVENT_TYPE_UNIQUE_POWER);
            ev = SetEventInteger(ev,0, stEvent.nAbility);
            ev = SetEventObject(ev,0, stEvent.oItem);
            ev = SetEventObject(ev,1, stEvent.oCaster);
            ev = SetEventObject(ev,2, stEvent.oTarget);

            CreateItemOnObject(AF_ITR_EDS_WHISTLE ,stEvent.oCaster,1);
            DelayEvent(0.0, GetModule(), ev);


            break;

        }
    }
}