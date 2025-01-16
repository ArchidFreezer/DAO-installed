#include "abi_templates"
#include "spell_constants_h"

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    effect eEffect;

    switch (stEvent.nAbility)
    {
        case ABILITY_SPELL_STONEFIST:
        {
            int bShatter = Combat_ShatterCheck(stEvent.oTarget, stEvent.oCaster);

            if (bShatter == FALSE)
            {
                // damage with impact vfx
                float fDamage = (100.0f + GetCreatureSpellPower(stEvent.oCaster)) * STONEFIST_DAMAGE_FACTOR;
                eEffect = EffectDamage(fDamage, DAMAGE_TYPE_NATURE, DAMAGE_EFFECT_FLAG_NONE, Ability_GetImpactObjectVfxId(stEvent.nAbility));
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, stEvent.oTarget, 0.0f, stEvent.oCaster, stEvent.nAbility);

                // knockdown
                eEffect = EffectKnockdown(stEvent.oCaster, 0, stEvent.nAbility);
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, RandomFloat(), stEvent.oCaster, stEvent.nAbility);
            }
            break;
        }

        case ABILITY_SPELL_WALKING_BOMB:
        {
            // remove stacking effects
            RemoveStackingEffects(stEvent.oTarget, stEvent.oCaster, ABILITY_SPELL_WALKING_BOMB);
            RemoveStackingEffects(stEvent.oTarget, stEvent.oCaster, ABILITY_SPELL_MASS_CORPSE_DETONATION);

            float fDamage = (100.0f + GetCreatureSpellPower(stEvent.oCaster)) * WALKING_BOMB_DAMAGE_FACTOR;

            eEffect = EffectWalkingBomb(stEvent.oCaster, FALSE, fDamage, WALKING_BOMB_DEATH_VFX);
            eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_VFX, Ability_GetImpactObjectVfxId(stEvent.nAbility));
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, WALKING_BOMB_DURATION, stEvent.oCaster, stEvent.nAbility);

            ApplyEffectDamageOverTime(stEvent.oTarget, stEvent.oCaster, ABILITY_SPELL_WALKING_BOMB, fDamage, WALKING_BOMB_DURATION, DAMAGE_TYPE_NATURE);
            break;
        }

        case ABILITY_SPELL_MASS_CORPSE_DETONATION:
        {
            // remove stacking effects
            RemoveStackingEffects(stEvent.oTarget, stEvent.oCaster, ABILITY_SPELL_WALKING_BOMB);
            RemoveStackingEffects(stEvent.oTarget, stEvent.oCaster, ABILITY_SPELL_MASS_CORPSE_DETONATION);

            float fDamage = (100.0f + GetCreatureSpellPower(stEvent.oCaster)) * VIRULENT_WALKING_BOMB_DAMAGE_FACTOR;

            eEffect = EffectWalkingBomb(stEvent.oCaster, TRUE, fDamage, VIRULENT_WALKING_BOMB_DEATH_VFX);
            eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_VFX, Ability_GetImpactObjectVfxId(stEvent.nAbility));
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, VIRULENT_WALKING_BOMB_DURATION, stEvent.oCaster, stEvent.nAbility);

            ApplyEffectDamageOverTime(stEvent.oTarget, stEvent.oCaster, ABILITY_SPELL_WALKING_BOMB, fDamage, WALKING_BOMB_DURATION, DAMAGE_TYPE_NATURE);
            break;
        }
    }
    SendEventOnCastAt(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility, TRUE);
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

            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_IMPACT",Log_GetAbilityNameById(stEvent.nAbility));

            // Handle impact
            if (CheckSpellResistance(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility) == FALSE)
            {
                _HandleImpact(stEvent);
            } else
            {
                UI_DisplayMessage(stEvent.oTarget, UI_MESSAGE_RESISTED);
            }

            break;
        }
    }
}