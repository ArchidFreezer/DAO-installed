//*=============================================================================
// AB: script for Shale's new talent Stone Will
//*=============================================================================

#include "abi_templates"
#include "combat_h"

const int EVENT_TYPE_SHALE_STONE_WILL = 90000; // custom event - resets ms

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    // damage shield effects, scaling with CON
    float fConMod = GetAttributeModifier(stEvent.oCaster, PROPERTY_ATTRIBUTE_CONSTITUTION);
    float fShldPts = 40.0 + 3.5 * fConMod;
    float fShldStr = MaxF(1.0, 0.6 * fConMod);
    float fResist = MaxF(1.0, 0.5 * fConMod);

    // VFX - for the extra cool factor
    ApplyEffectVisualEffect(stEvent.oCaster, stEvent.oCaster, 105407, EFFECT_DURATION_TYPE_INSTANT, 0.0f, stEvent.nAbility);
    // have to use this instead of ModifyProperty...
    UpdateCreatureProperty(stEvent.oCaster, PROPERTY_ATTRIBUTE_DAMAGE_SHIELD_POINTS, fShldPts, PROPERTY_VALUE_MODIFIER);

    effect eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_DAMAGE_SHIELD_STRENGTH, fShldStr);
    eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_VFX, 105430); // VFX - persistent glow
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oCaster, 20.0, stEvent.oCaster, stEvent.nAbility);

    // dummy effect, only serves as flag
    eEffect = Effect(300202);
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oCaster, 20.0, stEvent.oCaster, stEvent.nAbility);

    // bonus physical/mental resistance
    eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_RESISTANCE_PHYSICAL, fResist,
                                   PROPERTY_ATTRIBUTE_RESISTANCE_MENTAL, fResist);
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oCaster, 20.0, stEvent.oCaster, stEvent.nAbility);

    // remove all movement speed modifiers
    RemoveEffectsByParameters(stEvent.oCaster, EFFECT_TYPE_MOVEMENT_RATE);
    RemoveEffectsByParameters(stEvent.oCaster, EFFECT_TYPE_MOVEMENT_RATE_DEBUFF);

    // -20% movement speed
    eEffect = EffectModifyMovementSpeed(0.8);
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oCaster, 20.0, stEvent.oCaster, stEvent.nAbility);

    // heartbeat effect on self, resets movement speed to 80%
    // this has to be done because immunity to movement speed modifiers
    // can't be implemented the same way as knockdown or slip
    event evResetMS = Event(EVENT_TYPE_SHALE_STONE_WILL);
    evResetMS = SetEventObject(evResetMS, 1, stEvent.oCaster);
    DelayEvent(0.6, stEvent.oCaster, evResetMS, "shl_stone_will");
}

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    switch(nEventType)
    {
        case EVENT_TYPE_SPELLSCRIPT_PENDING:
        {
            Ability_SetSpellscriptPendingEventResult(COMMAND_RESULT_SUCCESS);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            // VFX - activation
            ApplyEffectVisualEffect(stEvent.oCaster, stEvent.oCaster, 105405, EFFECT_DURATION_TYPE_INSTANT, 0.0f, stEvent.nAbility);

            // we just hand this through to cast_impact
            int nTarget = PROJECTILE_TARGET_INVALID;
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult, nTarget);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            //--------------------------------------------------------------
            // Get a structure with the event parameters
            //--------------------------------------------------------------
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            _HandleImpact(stEvent);

            break;
        }

        case EVENT_TYPE_SHALE_STONE_WILL: // heartbeat effect, resets movement speed
        {
            object oCaster = GetEventCreator(ev);

            // only when duration hasn't expired
            if (GetHasEffects(oCaster, 300202, 300202))
            {
                effect[] eBuff = GetEffects(oCaster, EFFECT_TYPE_MOVEMENT_RATE);
                effect[] eDebuff = GetEffects(oCaster, EFFECT_TYPE_MOVEMENT_RATE_DEBUFF);

                // and only if there is some external movement speed modifier
                if (GetArraySize(eBuff) > 1 || GetArraySize(eDebuff) > 0)
                {
                    RemoveEffectsByParameters(oCaster, EFFECT_TYPE_MOVEMENT_RATE);
                    RemoveEffectsByParameters(oCaster, EFFECT_TYPE_MOVEMENT_RATE_DEBUFF);

                    effect eEffect = EffectModifyMovementSpeed(0.8);
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oCaster, 20.0, oCaster, 300202);
                }

                ev = SetEventObject(ev, 1, oCaster);
                DelayEvent(0.5, oCaster, ev, "shl_stone_will"); // 0.5s delay interval
            }
            else
            {
                // clear all effects when duration expires
                RemoveEffectsByParameters(oCaster, EFFECT_TYPE_INVALID, 300202);
                SetCreatureProperty(oCaster, PROPERTY_ATTRIBUTE_DAMAGE_SHIELD_POINTS, 0.0, PROPERTY_VALUE_MODIFIER);
            }

            break;
        }
    }
}