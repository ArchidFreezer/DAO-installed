// -----------------------------------------------------------------------------
// Grease Override spell script based on code from Dheuster
// Modified by Archid to reduce code duplication and generally improve readability
// -----------------------------------------------------------------------------
/*
    Area of effect that slows all creatures in it and gives them a small increase
    in mana regeneration. This version is a duplicate of the 1.01 version
    with additional checking for the Skill SpellShaping.
*/

#include "log_h"
#include "aoe_effects_h"
#include "spell_constants_h"
#include "effect_dot2_h"
#include "af_spellshaping_h"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev); // CAST (directly from engine) or COMMAND_PENDING (re-directed by rules_core)

    switch(nEventType)
    {
        case EVENT_TYPE_SPELLSCRIPT_CAST: {
            //PrintToLog("Spell Shaping : EVENT_TYPE_SPELLSCRIPT_CAST (af_grease_override) caught");
            // Get a structure with the event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + " EVENT_TYPE_SPELLSCRIPT_CAST");

            // we just hand this through to cast_impact
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);
            break;
        }

        case EVENT_TYPE_ENTER: {
            //PrintToLog("Spell Shaping : EVENT_TYPE_ENTER (af_grease_override) caught");
            int nAbility = GetEventInteger(ev,0);
            object oTarget = GetEventTarget(ev);
            object oCreator = GetEventCreator(ev);

            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + " EVENT_TYPE_ENTER " + ToString(oTarget));

            DEBUG_PrintToScreen("Entering Grease: " + ToString(oTarget));

            if (IsSpellShapingTarget(oCreator, oTarget)) {
                if (!CheckSpellResistance(oTarget, oCreator, nAbility)) {
                    if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
                        ApplyAOEEffect_Grease(oTarget, oCreator, nAbility, OBJECT_SELF);
                } else {
                    UI_DisplayMessage(oTarget, UI_MESSAGE_RESISTED);
                }
            }
            break;
        }

        case EVENT_TYPE_AOE_HEARTBEAT: {
            //PrintToLog("Spell Shaping : EVENT_TYPE_AOE_HEARTBEAT (af_grease_override) caught");
            int nAbility = GetEventInteger(ev,0);
            object oCreator = GetEventCreator(ev);

            int nFlag = GetAOEFlags(OBJECT_SELF);
            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + " - Grease EVENT_TYPE_HEARTBEAT " + ToString(oCreator));


            if ((nFlag & AOE_FLAG_DESTRUCTION_PENDING) == AOE_FLAG_DESTRUCTION_PENDING) {
                Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + " EVENT_TYPE_HEARTBEAT aborted, flagged for deletion");
                return;
            }

            object[] oTargets = GetCreaturesInAOE(OBJECT_SELF);
            int i;
            int nSize = GetArraySize(oTargets);
            for (i= 0; i < nSize && i < 10 /*max targets for performance reasons*/; i++) {
                if (HasDotEffectOfType(oTargets[i], DAMAGE_TYPE_FIRE)) {
                    object oIgniter = oTargets[i];

                    // Now try to figure out who created the fire in the first place
                    effect[] dot = GetDotEffectByDamageType(oTargets[i], DAMAGE_TYPE_FIRE);
                    if (GetArraySize(dot))
                        oIgniter = GetEffectCreator(dot[0]);

                    Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + " EVENT_TYPE_HEARTBEAT: Igniting grease");
                    IgniteGreaseAoe(OBJECT_SELF, oTargets[i]);

                    break;
                }
            }

            if (IsObjectValid(OBJECT_SELF))
                DelayEvent(GREASE_INTERVAL_DURATION, OBJECT_SELF, ev); // signal next heartbeat

            break;
        }
        case EVENT_TYPE_EXIT: {
            //PrintToLog("Spell Shaping : EVENT_TYPE_EXIT (af_grease_override) caught");

            int nAbility = GetEventInteger(ev,0);
            object oTarget = GetEventTarget(ev);
            object oCreator = GetEventCreator(ev);

            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + " EVENT_TYPE_EXIT " + ToString(oTarget));

            if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
                RemoveStackingEffects(oTarget, oCreator, nAbility);

            break;
        }
    }
}