#include "log_h"
#include "abi_templates"
#include "spell_constants_h"

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    int nAppearanceType = GetAppearanceType(stEvent.oTarget);
    if (GetM2DAInt(TABLE_APPEARANCE, "bCanBleed", nAppearanceType) == TRUE)
    {
        int bResisted = TRUE;

        // does not work on PCs
        if (IsPartyMember(stEvent.oTarget) == FALSE)
        {
            // creatures with conversations are not charmed
            // this is to prevent creatures that talk then turn hostile from talking again
            if (HasConversation(stEvent.oTarget) == FALSE)
            {
                // mental resistance
                if (ResistanceCheck(stEvent.oCaster, stEvent.oTarget, PROPERTY_ATTRIBUTE_SPELLPOWER, RESISTANCE_MENTAL) == FALSE)
                {
                    // remove stacking effects
                    RemoveStackingEffects(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility);

                    float fDuration = GetRankAdjustedEffectDuration(stEvent.oTarget, BLOOD_CONTROL_DURATION);
                    effect eEffect = EffectCharm(stEvent.oCaster, stEvent.oTarget);
                    eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_VFX, Ability_GetImpactObjectVfxId(stEvent.nAbility));
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, fDuration, stEvent.oCaster, stEvent.nAbility);
                    bResisted = FALSE;

                    // Add shitty heartbeat to end if combat does
                    event evi = Event(EVENT_TYPE_INVALID);
                    evi = SetEventObject(evi, 0, stEvent.oCaster);
                    DelayEvent(1.5, stEvent.oTarget, evi, "spell_blood_control_extra");
                }
            }
        }

        if (bResisted) {
            // damage
            float fScaledValue = (100.0f + GetCreatureSpellPower(stEvent.oCaster)) * BLOOD_CONTROL_DAMAGE_FACTOR;
            ApplyEffectDamageOverTime(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility, fScaledValue, BLOOD_CONTROL_DURATION, DAMAGE_TYPE_SPIRIT, Ability_GetImpactObjectVfxId(stEvent.nAbility));
        }
    } else
    {
        UI_DisplayMessage(stEvent.oTarget, UI_MESSAGE_IMMUNE);
    }

    SendEventOnCastAt(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility);
}

// Check to see if combat has ended, in which case end the spell
void _HandleHeartbeat(event ev) {
    if (GetHasEffects(OBJECT_SELF, EFFECT_TYPE_INVALID, ABILITY_SPELL_BLOOD_CONTROL)) {
        if (GetGameMode() == GM_COMBAT) {
            DelayEvent(1.5, OBJECT_SELF, ev, "spell_blood_control_extra");
        } else {
            object oCreator = GetEventObject(ev, 0);
            RemoveStackingEffects(OBJECT_SELF, oCreator, ABILITY_SPELL_BLOOD_CONTROL);
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

        case EVENT_TYPE_INVALID:
        {
            _HandleHeartbeat(ev);

            break;
        }
    }
}