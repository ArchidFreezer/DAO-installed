// -----------------------------------------------------------------------------
// Drain Life
// -----------------------------------------------------------------------------
/*

*/
// -----------------------------------------------------------------------------
//  petert
// -----------------------------------------------------------------------------

#include "log_h"
#include "abi_templates"
#include "sys_traps_h"
#include "spell_constants_h"
#include "plt_cod_aow_spellcombo6"

const int DRAIN_LIFE_PROJECTILE = 104;

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

            if (CheckSpellResistance(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility) == FALSE)
            {
                // damage
                float fDamage = 0.0f;
                effect eEffect;
                float fTargetHealth = GetCurrentHealth(stEvent.oTarget);
                float fTargetDmgScale = GetCreatureProperty(stEvent.oTarget, PROPERTY_ATTRIBUTE_DAMAGE_SCALE);
                if (stEvent.nAbility == ABILITY_SPELL_BLOOD_SACRIFICE)
                {
                    // if caster and target are party members, or if caster not a party member and target is of the same group
                    if (IsPartyMember(stEvent.oCaster) ? IsPartyMember(stEvent.oTarget) : GetGroupId(stEvent.oCaster) == GetGroupId(stEvent.oTarget))
                    {
                        // if creature has blood
                        int nAppearanceType = GetAppearanceType(stEvent.oTarget);
                        if (GetM2DAInt(TABLE_APPEARANCE, "bCanBleed", nAppearanceType) == TRUE)
                        {
                            // cap health based on how much caster is missing and target has
                            float fCasterMax = 0.5*(GetMaxHealth(stEvent.oCaster) - GetCurrentHealth(stEvent.oCaster));
                            float fTargetMax = fTargetHealth;
                            float fHealthMax = MinF(fTargetMax, fCasterMax) / fTargetDmgScale;
                            fDamage = MinF(BLOOD_SACRIFICE_MAX_HEALTH, fHealthMax);

                            // if there is health to drain
                            if (fHealthMax > 0.0f)
                                eEffect = EffectDamage(fDamage, DAMAGE_TYPE_PLOT, 0, Ability_GetImpactObjectVfxId(stEvent.nAbility));
                        }
                    } else
                    {
                        UI_DisplayMessage(stEvent.oTarget, 3518);
                    }
                } else
                {
                    // spell combo - vulnerability hex
                    if (GetHasEffects(stEvent.oTarget, EFFECT_TYPE_INVALID, ABILITY_SPELL_MASS_SLOW))
                    {
                        fDamage = (100.0f + GetCreatureSpellPower(stEvent.oCaster)) * IMPROVED_DRAIN_HEALTH_FACTOR;

                        eEffect = EffectVisualEffect(IMPROVED_DRAIN_HEALTH_VFX);
                        ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, stEvent.oTarget, 0.0f, stEvent.oCaster, stEvent.nAbility);

                        // combo effect codex - improved drain
                        if (IsFollower(stEvent.oCaster) == TRUE)
                        {
                            WR_SetPlotFlag(PLT_COD_AOW_SPELLCOMBO6, COD_AOW_SPELLCOMBO_6_STEAM_CLOUD, TRUE);
                        }
                    } else
                    {
                        fDamage = (100.0f + GetCreatureSpellPower(stEvent.oCaster)) * DRAIN_LIFE_DAMAGE_FACTOR;
                    }

                    eEffect = EffectDamage(fDamage, DAMAGE_TYPE_SPIRIT, DAMAGE_EFFECT_FLAG_NONE, Ability_GetImpactObjectVfxId(stEvent.nAbility));

                    // Account for immunity, resistance and damage bonus
                    if (DamageIsImmuneToType(stEvent.oTarget, DAMAGE_TYPE_SPIRIT))
                        fDamage *= 0.0f;
                    else {
                        fDamage = ResistDamage(stEvent.oCaster, stEvent.oTarget, stEvent.nAbility, fDamage, DAMAGE_TYPE_SPIRIT);
                        fDamage *= 1.0f + 0.01f * GetCreatureProperty(stEvent.oCaster, PROPERTY_ATTRIBUTE_SPIRIT_DAMAGE_BONUS);
                    }
                }

                // if we didn't abort early
                if (IsEffectValid(eEffect))
                {
                    // Sadly we can't just damage the target and check how much health it's got afterwards to determine healing
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, stEvent.oTarget, 0.0f, stEvent.oCaster, stEvent.nAbility);

                    // if we actually did any damage
                    if (GetHasEffects(stEvent.oTarget, EFFECT_TYPE_DAMAGE_WARD))
                        fDamage = 0.0f;
                    fDamage = MinF(fDamage, fTargetHealth);

                    if (fDamage > 0.0f) {
                        // create event
                        event ev = Event(90210);
                        ev = SetEventInteger(ev, 0, stEvent.nAbility);
                        ev = SetEventObject(ev, 0, stEvent.oCaster);
                        ev = SetEventObject(ev, 1, stEvent.oCaster);

                        // blood sacrifice gives damage x 2 back.
                        if (stEvent.nAbility == ABILITY_SPELL_BLOOD_SACRIFICE)
                            fDamage *= 2.0;

                        ev = SetEventFloat(ev, 0, fDamage);

                        // fire projectile
                        vector v = GetPosition(stEvent.oTarget);
                        v.z += 1.5f;
                        object oProjectile = FireHomingProjectile(DRAIN_LIFE_PROJECTILE, v, stEvent.oCaster, 0,  stEvent.oCaster);
                        SetProjectileImpactEvent(oProjectile, ev);
                    }
                }
            } else
            {
                UI_DisplayMessage(stEvent.oTarget, UI_MESSAGE_RESISTED);
            }

            break;
        }

        case 90210:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            int bHeal;
            int nVFX;

            if (stEvent.nAbility == ABILITY_SPELL_BLOOD_SACRIFICE)
            {
                bHeal = TRUE;
                nVFX = BLOOD_SACRIFICE_CASTER_VFX;
            } else
            {
                bHeal = FALSE;
                nVFX = DRAIN_LIFE_CASTER_VFX;
            }

            // heal
            float fHeal = GetEventFloat(ev, 0);
            effect eEffect = EffectHeal(fHeal, bHeal);
            eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_VFX, nVFX);
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, stEvent.oCaster, 0.0f, stEvent.oCaster, stEvent.nAbility);

            break;
        }
    }
}