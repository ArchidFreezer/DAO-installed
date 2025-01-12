// -----------------------------------------------------------------------------
// spell_aoe_duration.ncs
// -----------------------------------------------------------------------------
/*

*/
// -----------------------------------------------------------------------------
// petert
// -----------------------------------------------------------------------------

#include "log_h"
#include "ability_h"
#include "combat_damage_h"
#include "events_h"
#include "talent_constants_h"

const resource SCRIPT_RESOURCE = R"talent_aoe_duration.ncs";

void _ApplySpellHeartbeatEffects(int nAbility, object oTarget, object oCreator)
{
    float fScaledValue;
    effect eEffect;

    // spell-specific heartbeat
    switch (nAbility)
    {
        case ABILITY_TALENT_CAPTIVATE:
        {
            // if hostile
            if (IsObjectHostile(oCreator, oTarget) == TRUE)
            {
                // mental resistance
                if (ResistanceCheck(oCreator, oTarget, PROPERTY_ATTRIBUTE_INTELLIGENCE, RESISTANCE_MENTAL) == FALSE)
                {
                    float fDuration = GetRankAdjustedEffectDuration(oTarget, CAPTIVATE_DURATION);

                    eEffect = EffectStun();
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTarget, fDuration, oCreator, nAbility);
                }
            }

            break;
        }

        case ABILITY_TALENT_PAIN:
        {
            // if hostile
            if (IsObjectHostile(oCreator, oTarget) == TRUE)
            {
                ApplyEffectDamageOverTime(oTarget, oCreator, nAbility, PAIN_INTERVAL_DAMAGE, PAIN_INTERVAL_DURATION, DAMAGE_TYPE_SPIRIT, Ability_GetImpactObjectVfxId(nAbility));
            }

            break;
        }
    }
}

// Spellscript Impact Damage and Effects
void _ApplyImpactDamageAndEffects(struct EventSpellScriptImpactStruct stEvent)
{
    // make sure location is valid
    if (IsObjectValid(stEvent.oTarget) == TRUE)
    {
        stEvent.lTarget = GetLocation(stEvent.oTarget);
    }

    effect eEffect;

    // spell-specific AoE
    int nAoE = -1;
    int nAoEVFX = 0;
    float fAoEDuration = 0.0f;
    switch (stEvent.nAbility)
    {
    }

    if (nAoE > 0)
    {
        effect eAoE = EffectAreaOfEffect(nAoE, SCRIPT_RESOURCE, nAoEVFX);
        Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_TEMPORARY, eAoE, stEvent.lTarget, fAoEDuration, stEvent.oCaster, stEvent.nAbility);

        // spell-specific additional effects
        switch (stEvent.nAbility)
        {
        }
    }
}

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev); // CAST (directly from engine) or COMMAND_PENDING (re-directed by rules_core)

    switch(nEventType)
    {
        case EVENT_TYPE_SPELLSCRIPT_PENDING:
        {
            // Get structure containing event parameters
            struct EventSpellScriptPendingStruct stEvent = Events_GetEventSpellScriptPendingParameters(ev);

            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + "EVENT_TYPE_SPELLSCRIPT_PENDING");
            #endif

            // Setting return value
            Ability_SetSpellscriptPendingEventResult(COMMAND_RESULT_SUCCESS);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {
            // Get a structure containing event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + "EVENT_TYPE_SPELLSCRIPT_CAST");
            #endif

            // Hand through to cast_impact
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            // Get structure containing event parameters
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + "EVENT_TYPE_SPELLSCRIPT_IMPACT");
            #endif

            _ApplyImpactDamageAndEffects(stEvent);

            break;
        }

        case EVENT_TYPE_ENTER:
        {
            int nAbility = GetEventInteger(ev,0);
            object oTarget = GetEventTarget(ev);
            object oCreator = GetEventCreator(ev);

            float fScaledValue;
            effect eEffect;

            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "Entering Ability " + ToString(nAbility) + " AoE: " + ToString(oTarget));
            #endif
            if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
            {
                // spell-specific on enter event
                switch (nAbility)
                {
                    case ABILITY_TALENT_CAPTIVATE:
                    {
                        _ApplySpellHeartbeatEffects(nAbility, oTarget, oCreator);

                        break;
                    }

                    case ABILITY_TALENT_RALLY:
                    {
                        // if the same group
                        if (GetGroupId(oTarget) == GetGroupId(oCreator) && oTarget != oCreator)
                        {
                            // defense buff
                            eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_DEFENSE, RALLY_DEFENSE_BONUS);
                            eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_VFX, Ability_GetImpactObjectVfxId(nAbility));
                            ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oTarget, 0.0f, oCreator, nAbility);

                            // motivate bonus
                            if (HasAbility(oCreator, ABILITY_TALENT_MOTIVATE) == TRUE)
                            {
                                // attack buff
                                eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_ATTACK, MOTIVATE_RALLY_ATTACK_BONUS);
                                ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oTarget, 0.0f, oCreator, nAbility);
                            }
                        }

                        break;
                    }
                }

                SendEventOnCastAt(oTarget, OBJECT_SELF, nAbility);
            }

            break;
        }

        case EVENT_TYPE_AOE_HEARTBEAT:
        {
            int nAbility = GetEventInteger(ev,0);
            object oCreator = GetEventCreator(ev);
            float fInterval = 0.0f;

            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "Ability " + ToString(nAbility) + " Heartbeat");
            #endif

            object[] oTargets = GetCreaturesInAOE(OBJECT_SELF);

            // run through all creatures in AoE
            int nCount = 0;
            int nMax = GetArraySize(oTargets);
            for (nCount = 0; nCount < nMax; nCount++)
            {
                _ApplySpellHeartbeatEffects(nAbility, oTargets[nCount], oCreator);
            }

            // spell-specific heartbeat duration
            switch (nAbility)
            {
                case ABILITY_TALENT_CAPTIVATE:
                {
                    fInterval = CAPTIVATE_INTERVAL_DURATION;

                    break;
                }

                case ABILITY_TALENT_PAIN:
                {
                    // apply damage to caster
                    ApplyEffectDamageOverTime(oCreator, oCreator, nAbility, PAIN_INTERVAL_DAMAGE, PAIN_INTERVAL_DURATION, DAMAGE_TYPE_PLOT, Ability_GetImpactObjectVfxId(nAbility));

                    fInterval = PAIN_INTERVAL_DURATION;

                    break;
                }
            }

            if (fInterval > 0.0f)
            {
                if (IsObjectValid(OBJECT_SELF) && (IsModalAbilityActive(oCreator,nAbility) || !Ability_IsModalAbility(nAbility)))
                {
                    // signal next heartbeat
                    DelayEvent(fInterval + 0.05f, OBJECT_SELF, ev);
                }
            }

            break;
        }

        case EVENT_TYPE_EXIT:
        {
            int nAbility = GetEventInteger(ev,0);
            object oTarget = GetEventTarget(ev);
            object oCreator = GetEventCreator(ev);

            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "Exiting Ability " + ToString(nAbility) + " AoE: " + ToString(oTarget));
            #endif
            if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
            {
                // spell-specific heartbeat duration
                switch (nAbility)
                {
                    case ABILITY_TALENT_CAPTIVATE:
                    {
                        RemoveStackingEffects(oTarget, oCreator, nAbility);

                        break;
                    }

                    case ABILITY_TALENT_RALLY:
                    {
                        if (oTarget != oCreator)
                        {
                            RemoveStackingEffects(oTarget, oCreator, nAbility);
                        }

                        break;
                    }

                    case ABILITY_TALENT_PAIN:
                    {
                        RemoveStackingEffects(oTarget, oCreator, nAbility);

                        break;
                    }
                }
            }

            break;
        }
    }
}