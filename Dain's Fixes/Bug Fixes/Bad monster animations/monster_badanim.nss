#include "talent_constants_h"                                                                                                                        #include "abi_templates"
#include "spell_constants_h"
#include "2da_constants_h"

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    effect eEffect;
    switch (stEvent.nAbility) {
        // Mark of Death
        case 378231138: {
            // remove stacking effects
            RemoveStackingEffects(stEvent.oTarget, stEvent.oCaster, 3060);

            // apply mark on target
            eEffect = EffectModifyPropertyHostile(PROPERTY_ATTRIBUTE_DAMAGE_SCALE, MARK_OF_DEATH_DAMAGE_SCALE);
            eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_VFX, Ability_GetImpactObjectVfxId(3060));
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, MARK_OF_DEATH_DURATION, stEvent.oCaster, 3060);

            break;
        }
        // Misdirection Hex
        case 899000133: {
            if (CheckSpellResistance(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility)) {
                UI_DisplayMessage(stEvent.oTarget, UI_MESSAGE_RESISTED);
            } else {
                // remove stacking effects
                RemoveStackingEffects(stEvent.oTarget, stEvent.oCaster, 11114);

                eEffect = Effect(EFFECT_TYPE_MISDIRECTION_HEX);
                eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_VFX, Ability_GetImpactObjectVfxId(11114));
                eEffect = SetEffectEngineFloat(eEffect, EFFECT_FLOAT_SCALE, 0.6f);
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, MISDIRECTION_HEX_DURATION, stEvent.oCaster, 11114);

                SendEventOnCastAt(stEvent.oTarget, stEvent.oCaster, 11114, TRUE);
            }

            break;
        }
    }
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

            // Hand this through to cast_impact
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            _HandleImpact(stEvent);

            break;
        }
    }
}