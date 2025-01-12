#include "abi_templates"
#include "spell_constants_h"

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    float fDamage = (100.0f + GetCreatureSpellPower(stEvent.oCaster)) * 0.3f;
    effect eEffect = EffectDamage(fDamage, DAMAGE_TYPE_SPIRIT, 0, 100004);
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, stEvent.oTarget, 0.0f, stEvent.oCaster, stEvent.nAbility);
    if (GetM2DAInt(TABLE_APPEARANCE,"creature_type",GetAppearanceType(stEvent.oTarget)) == CREATURE_TYPE_DARKSPAWN)
        ApplyEffectDamageOverTime(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility, fDamage, 6.0, DAMAGE_TYPE_SPIRIT, 100004);

    SendEventOnCastAt(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility);
}

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    switch(nEventType)
    {
        case EVENT_TYPE_SPELLSCRIPT_PENDING:
        {
            object oCaster = GetEventObject(ev, 0);
            int bResult = GetCreatureProperty(oCaster, PROPERTY_DEPLETABLE_HEALTH, PROPERTY_VALUE_CURRENT) > 21.0f;
            if (bResult) {
                effect eEffect = EffectDamage(20.0, DAMAGE_TYPE_PLOT, DAMAGE_EFFECT_FLAG_UNRESISTABLE);
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oCaster, 0.0f, oCaster, 310011);
            }

            Ability_SetSpellscriptPendingEventResult(bResult ? COMMAND_RESULT_SUCCESS : COMMAND_RESULT_FAILED_NO_RESOURCES);

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

            // Handle impact
            if (CheckSpellResistance(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility) == FALSE)
                _HandleImpact(stEvent);
            else
                UI_DisplayMessage(stEvent.oTarget, UI_MESSAGE_RESISTED);

            break;
        }
    }
}