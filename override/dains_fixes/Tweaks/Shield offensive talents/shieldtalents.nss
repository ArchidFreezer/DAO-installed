#include "log_h"
#include "abi_templates"
#include "combat_h"
#include "talent_constants_h"

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    // -------------------------------------------------------------------------
    // VAR BLOCK
    // -------------------------------------------------------------------------
    int    nScalingVector   = SCALING_VECTOR_DURATION;
    int    nAttackingValue  = PROPERTY_ATTRIBUTE_SPELLPOWER;
    int    nResistance      = RESISTANCE_INVALID;
    float  fDuration        = 0.0f;
    float  fScaledValue     = 0.0f;
    int    nEffect          = 0;
    int    nHandler         = SPELL_HANDLER_CUSTOM;
    effect eDamage;

    effect eEffect;
    object[] oTargets;

    // make sure there is a location, just in case
    if (IsObjectValid(stEvent.oTarget) == TRUE)
    {
        stEvent.lTarget = GetLocation(stEvent.oTarget);
    }

    int bSignalHostileEvent = FALSE;

    // -------------------------------------------------------------------------
    // Handle Talents
    // -------------------------------------------------------------------------
    switch (stEvent.nAbility)
    {
        case ABILITY_TALENT_SHIELD_BASH:
        {
            object oWeapon  = GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND, stEvent.oCaster);

            // if the attack hit
            int nResult = Combat_GetAttackResult(stEvent.oCaster, stEvent.oTarget, oWeapon, 10.0f, stEvent.nAbility);
            if (IsCombatHit(nResult) == TRUE)
            {
                // Check if shield mastery doubles attribute bonus
                int bDoubleAttBonus = FALSE;
                if (HasAbility(stEvent.oCaster, ABILITY_TALENT_SHIELD_MASTERY) == TRUE)
                {
                    bDoubleAttBonus = TRUE;
                }

                // normal damage
                float fDamage = Combat_Damage_GetAttackDamage(stEvent.oCaster, stEvent.oTarget, oWeapon, nResult, 0.0, FALSE, bDoubleAttBonus);

                // apply impact
                eEffect = EffectImpact(fDamage, oWeapon,0, stEvent.nAbility);
                Combat_HandleAttackImpact(stEvent.oCaster, stEvent.oTarget, nResult, eEffect);

                // physical resistance
                if (ResistanceCheck(stEvent.oCaster, stEvent.oTarget, PROPERTY_ATTRIBUTE_STRENGTH, RESISTANCE_PHYSICAL) == FALSE)
                {
                    // knockdown
                    eEffect = EffectKnockdown(stEvent.oCaster, 0, stEvent.nAbility);
                    if (IsHumanoid(stEvent.oTarget) == TRUE)
                    {
                        eEffect = SetEffectEngineFloat(eEffect, EFFECT_FLOAT_KNOCKBACK_DISTANCE, -0.05f);
                    } else
                    {
                        eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_DONT_INTERPOLATE, TRUE);
                    }
                    ApplyEffectVisualEffect(stEvent.oCaster, stEvent.oTarget, 1014, EFFECT_DURATION_TYPE_INSTANT, 0.0f, stEvent.nAbility);
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, RandomFloat(), stEvent.oCaster, stEvent.nAbility);
                }
            }

            break;
        }

        case ABILITY_TALENT_SHIELD_PUMMEL:
        {
            // weapon on first hit, shield on subsequent
            object oWeapon;
            float fAPBonus = 0.0f;
            if (stEvent.nHit == 1)
            {
                oWeapon  = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, stEvent.oCaster);
            } else
            {
                oWeapon  = GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND, stEvent.oCaster);
                fAPBonus = 2.0f;
            }

            // if the attack hit
            int nResult = Combat_GetAttackResult(stEvent.oCaster, stEvent.oTarget, oWeapon, 10.0f, stEvent.nAbility);
            if (IsCombatHit(nResult) == TRUE || stEvent.nHit>1)
            {
                // Check if shield mastery doubles attribute bonus
                int bDoubleAttBonus = FALSE;
                if (stEvent.nHit > 1) //shield strike only
                {
                    if (HasAbility(stEvent.oCaster, ABILITY_TALENT_SHIELD_MASTERY) == TRUE)
                    {
                        bDoubleAttBonus = TRUE;
                    }
                }

                // normal damage
                float fDamage = Combat_Damage_GetAttackDamage(stEvent.oCaster, stEvent.oTarget, oWeapon, nResult, fAPBonus, FALSE, bDoubleAttBonus);

                // apply impact
                eEffect = EffectImpact(fDamage, oWeapon,0, stEvent.nAbility);
                Combat_HandleAttackImpact(stEvent.oCaster, stEvent.oTarget, nResult, eEffect);

                // final hit stuns
                if (stEvent.nHit == 3)
                {
                    // physical resistance
                    if (ResistanceCheck(stEvent.oCaster, stEvent.oTarget, PROPERTY_ATTRIBUTE_STRENGTH, RESISTANCE_PHYSICAL) == FALSE)
                    {
                        float fDuration = GetRankAdjustedEffectDuration(stEvent.oTarget, SHIELD_PUMMEL_DURATION);

                        // remove stacking effects
                        RemoveStackingEffects(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility);

                        // stun
                        eEffect = EffectStun();
                        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, fDuration, stEvent.oCaster, stEvent.nAbility);
                    }
                }
            }

            break;
        }

        case ABILITY_TALENT_ASSAULT:
        {
            object oWeapon  = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, stEvent.oCaster);

            // if the attack hit
            int nResult = Combat_GetAttackResult(stEvent.oCaster, stEvent.oTarget, oWeapon, ASSAULT_ATTACK_BONUS, stEvent.nAbility );
            if (IsCombatHit(nResult) == TRUE)
            {
                // shield mastery bonus
                int bMaximum = HasAbility(stEvent.oCaster, ABILITY_TALENT_SHIELD_MASTERY);

                // normal damage
                float fDamage = Combat_Damage_GetAttackDamage(stEvent.oCaster, stEvent.oTarget, oWeapon, nResult, ASSAULT_AP_BONUS, bMaximum);
                fDamage *= ASSAULT_DAMAGE_MULTIPLIER;
                eEffect = EffectImpact(fDamage, oWeapon, 0, stEvent.nAbility);
                Combat_HandleAttackImpact(stEvent.oCaster, stEvent.oTarget, nResult, eEffect);
            }

            break;
        }

        case ABILITY_TALENT_OVERPOWER:
        {
            object oWeapon  = GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND, stEvent.oCaster);

            // if the attack hit
            int nResult = Combat_GetAttackResult(stEvent.oCaster, stEvent.oTarget, oWeapon, 0.0f, stEvent.nAbility);
            if (IsCombatHit(nResult) == TRUE)
            {
                // automatic critical
                nResult = COMBAT_RESULT_CRITICALHIT;

                // shield mastery bonus
                int bMaximum = HasAbility(stEvent.oCaster, ABILITY_TALENT_SHIELD_MASTERY);

                // normal damage
                float fDamage = Combat_Damage_GetAttackDamage(stEvent.oCaster, stEvent.oTarget, oWeapon, nResult, 0.0, bMaximum);
                eEffect = EffectImpact(fDamage, oWeapon,0, stEvent.nAbility);
                Combat_HandleAttackImpact(stEvent.oCaster, stEvent.oTarget, nResult, eEffect);

                if (stEvent.nHit == 3)
                {
                    // physical resistance
                    if (ResistanceCheck(stEvent.oCaster, stEvent.oTarget, PROPERTY_ATTRIBUTE_STRENGTH, RESISTANCE_PHYSICAL) == FALSE)
                    {
                        // remove stacking effects
                        RemoveStackingEffects(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility);

                        // knockdown
                        eEffect = EffectKnockdown(stEvent.oCaster, 0, stEvent.nAbility);
                        if (IsHumanoid(stEvent.oTarget) == TRUE)
                        {
                            eEffect = SetEffectEngineFloat(eEffect, EFFECT_FLOAT_KNOCKBACK_DISTANCE, -0.05f);
                        } else
                        {
                            eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_DONT_INTERPOLATE, TRUE);
                        }
                        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, RandomFloat(), stEvent.oCaster, stEvent.nAbility);

                        // daze
                        eEffect = EffectDaze();
                        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, OVERPOWER_DURATION, stEvent.oCaster, stEvent.nAbility);
                    }
                }
            }

            break;
        }
    }

    if (bSignalHostileEvent)
    {
        SendEventOnCastAt(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility, TRUE);
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

            // we just hand this through to cast_impact
            int nTarget = PROJECTILE_TARGET_INVALID;

            if (stEvent.nAbility ==  ABILITY_TALENT_PINNING_SHOT)
            {
                nTarget = Random(2)==0? PROJECTILE_TARGET_LOWERLEG_L :PROJECTILE_TARGET_LOWERLEG_R;
            }

            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult, nTarget);

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