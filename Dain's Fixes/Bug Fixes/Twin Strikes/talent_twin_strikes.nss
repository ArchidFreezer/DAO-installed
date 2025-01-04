#include "log_h"
#include "abi_templates"
#include "combat_h"
#include "talent_constants_h"

const int GXA_TWIN_STRIKES = 402100;
const int GXA_FIND_VITALS = 402101;
const int GXA_LOW_BLOW = 402102;

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    int nWeaponSlot = stEvent.nHit == 1 ? INVENTORY_SLOT_MAIN : INVENTORY_SLOT_OFFHAND;

    object oWeapon = GetItemInEquipSlot(nWeaponSlot, stEvent.oCaster);

    // if the attack hit
    int nResult = Combat_GetAttackResult(stEvent.oCaster, stEvent.oTarget, oWeapon, 0.0f, stEvent.nAbility);
    if (IsCombatHit(nResult))
    {
        // automatic critical
        nResult = COMBAT_RESULT_CRITICALHIT;

        // normal damage
        float fDamage = Combat_Damage_GetAttackDamage(stEvent.oCaster, stEvent.oTarget, oWeapon, nResult);
        effect eEffect = EffectImpact(fDamage, oWeapon,0, stEvent.nAbility);
        Combat_HandleAttackImpact(stEvent.oCaster, stEvent.oTarget, nResult, eEffect);
        
        // dot if caster has find vitals
        if (HasAbility(stEvent.oCaster, GXA_FIND_VITALS))
            ApplyEffectDamageOverTime(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility, fDamage*2.0/3.0, 5.0, DAMAGE_TYPE_PHYSICAL);
        
        // drain if target is slowed by low blow
        if (GetHasEffects(stEvent.oTarget, EFFECT_TYPE_INVALID, GXA_LOW_BLOW) && !GetHasEffects(stEvent.oTarget, EFFECT_TYPE_DRAINING, stEvent.nAbility)) {
            effect ef = Effect(EFFECT_TYPE_DRAINING);
            float fDuration = GetRankAdjustedEffectDuration(stEvent.oTarget, 5.0);
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, ef, stEvent.oTarget, fDuration, stEvent.oCaster, stEvent.nAbility);
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
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_CAST",Log_GetAbilityNameById(stEvent.nAbility));
            #endif

            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            //--------------------------------------------------------------
            // Get a structure with the event parameters
            //--------------------------------------------------------------
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_IMPACT",Log_GetAbilityNameById(stEvent.nAbility));
            #endif

            _HandleImpact(stEvent);

            break;
        }
    }
}