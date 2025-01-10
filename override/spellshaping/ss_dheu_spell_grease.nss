// -----------------------------------------------------------------------------
// spell_grease.ncs - Grease spell script
// -----------------------------------------------------------------------------
/*
    Area of effect that slows all creatures in it and gives them a small increase
    in mana regeneration.
*/
// -----------------------------------------------------------------------------
// PeterT - 15/1/2008
// -----------------------------------------------------------------------------

#include "log_h"
#include "aoe_effects_h"
#include "spell_constants_h"
#include "effect_dot2_h"

//------------------------------------------------------------------------------
// Spellscript Impact Damage and Effects
//------------------------------------------------------------------------------
void _ApplyImpactDamageAndEffects(struct EventSpellScriptImpactStruct stEvent)
{
    // if target is an object
    if (IsObjectValid(stEvent.oTarget))
    {
        stEvent.lTarget = GetLocation(stEvent.oTarget);
    }

    // apply AoE effect on target
    effect eAoE = EffectAreaOfEffect(GREASE_AOE, GetCurrentScriptResource(), GREASE_AOE_VFX);
    Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_TEMPORARY, eAoE, stEvent.lTarget, GREASE_DURATION, stEvent.oCaster, stEvent.nAbility);
}

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev); // CAST (directly from engine) or COMMAND_PENDING (re-directed by rules_core)

    switch(nEventType)
    {
        case EVENT_TYPE_SPELLSCRIPT_PENDING:
        {
            //--------------------------------------------------------------
            // Get a structure with the event parameters
            //--------------------------------------------------------------
            struct EventSpellScriptPendingStruct stEvent = Events_GetEventSpellScriptPendingParameters(ev);

            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + " EVENT_TYPE_SPELLSCRIPT_PENDING");

            // Setting Return Value
            Ability_SetSpellscriptPendingEventResult(COMMAND_RESULT_SUCCESS);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + " EVENT_TYPE_SPELLSCRIPT_CAST");

            // we just hand this through to cast_impact
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + " EVENT_TYPE_SPELLSCRIPT_IMPACT");

            // create AoE object
            _ApplyImpactDamageAndEffects(stEvent);

            // Tell the targeted creature that it has been cast at
            SendEventOnCastAt(stEvent.oTarget,stEvent.oCaster, stEvent.nAbility, TRUE);

            break;
        }

        case EVENT_TYPE_ENTER:
        {
            int nAbility = GetEventInteger(ev,0);
            object oTarget = GetEventTarget(ev);
            object oCreator = GetEventCreator(ev);

            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + " EVENT_TYPE_ENTER " + ToString(oTarget));

            DEBUG_PrintToScreen("Entering Grease: " + ToString(oTarget));

            if (CheckSpellResistance(oTarget, oCreator, nAbility) == FALSE)
            {
                if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
                {
                    ApplyAOEEffect_Grease(oTarget, oCreator, nAbility, OBJECT_SELF);
                }
            } else
            {
                UI_DisplayMessage(oTarget, UI_MESSAGE_RESISTED);
            }

            break;
        }

        case EVENT_TYPE_AOE_HEARTBEAT:
        {
            int nAbility = GetEventInteger(ev,0);
            object oCreator = GetEventCreator(ev);

             int nFlag = GetAOEFlags(OBJECT_SELF);
            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + " - Grease EVENT_TYPE_HEARTBEAT " + ToString(oCreator));


            if ((nFlag & AOE_FLAG_DESTRUCTION_PENDING) == AOE_FLAG_DESTRUCTION_PENDING)
            {
                Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + " EVENT_TYPE_HEARTBEAT aborted, flagged for deletion");
                return;
            }


            object[] targets = GetCreaturesInAOE(OBJECT_SELF);
            int nSize = GetArraySize(targets);
            int i;

            for (i= 0; i < nSize && i < 10 /*max targets for performance reasons*/; i++)
            {

                if (HasDotEffectOfType(targets[i], DAMAGE_TYPE_FIRE))
                {

                    object oIgniter =targets[i];

                    // Now try to figure out who created the fire in the first place
                    effect[] dot = GetDotEffectByDamageType(targets[i], DAMAGE_TYPE_FIRE);
                    if (GetArraySize(dot))
                    {
                        oIgniter = GetEffectCreator(dot[0]);
                    }

                    Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + " EVENT_TYPE_HEARTBEAT: Igniting grease");
                    IgniteGreaseAoe(OBJECT_SELF, targets[i]);

                    break;
                }
            }


            if (IsObjectValid(OBJECT_SELF))
            {
                // signal next heartbeat
                DelayEvent(GREASE_INTERVAL_DURATION, OBJECT_SELF, ev);
            }


            break;
        }

        case EVENT_TYPE_EXIT:
        {
            int nAbility = GetEventInteger(ev,0);
            object oTarget = GetEventTarget(ev);
            object oCreator = GetEventCreator(ev);

            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + " EVENT_TYPE_EXIT " + ToString(oTarget));

            if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
            {
                RemoveStackingEffects(oTarget, oCreator, nAbility);
            }

            break;
        }
    }
}