// -----------------------------------------------------------------------------
// spell_modalsingletarget.nss
// -----------------------------------------------------------------------------
/*
    Generic Ability Script for modal single target abilities
*/
// -----------------------------------------------------------------------------
// PeterT
// -----------------------------------------------------------------------------

#include "log_h"
#include "abi_templates"
#include "spell_constants_h"

// add effects
void _ActivateModalAbility(struct EventSpellScriptImpactStruct stEvent)
{
    // effects
    effect eEffect;
    effect[] eEffects;
    int bPartywide = FALSE;
    int bEffectValid = TRUE;

    // Glowing Aura while effect is active
    //effect eEffect_WynneGlow = Effect(1008);

    if (IsObjectValid(stEvent.oTarget) == TRUE)
    {
        stEvent.lTarget = GetLocation(stEvent.oTarget);
    }

    // determine if wynne is wearing her trinket
    int bTrinket = GetTag(GetItemInEquipSlot(INVENTORY_SLOT_NECK)) == "gen_im_acc_amu_am11";

    // determine radius
    float fRadius = bTrinket ? WYNNE_POST_TRINKET_RADIUS : WYNNE_PRE_TRINKET_RADIUS;

    // play impact vfx
    Ability_ApplyLocationImpactVFX(stEvent.nAbility, stEvent.lTarget);

    // area effect on nearby creatures
    object[] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, stEvent.lTarget, fRadius);
    int nCount = 0;
    int nMax = GetArraySize(oTargets);
    for (nCount = 0; nCount < nMax; nCount++)
    {
        // effects everyone except the caster
        if (oTargets[nCount] != stEvent.oCaster)
        {
            if (CheckSpellResistance(oTargets[nCount], stEvent.oCaster, stEvent.nAbility) == FALSE)
            {
                if (bTrinket == TRUE)
                {
                    // physical resistance
                    if (ResistanceCheck(stEvent.oCaster, oTargets[nCount], PROPERTY_ATTRIBUTE_SPELLPOWER, RESISTANCE_PHYSICAL) == FALSE)
                    {
                        // knockdown
                        eEffect = EffectKnockdown(stEvent.oCaster, 0, stEvent.nAbility);
                        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTargets[nCount], RandomFloat(), stEvent.oCaster, stEvent.nAbility);
                    } else
                    {
                        // remove stacking effects
                        RemoveStackingEffects(oTargets[nCount], stEvent.oCaster, stEvent.nAbility);

                        // daze
                        eEffect = EffectDaze();
                        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTargets[nCount], WYNNE_PRE_TRINKET_DAZE_DURATION, stEvent.oCaster, stEvent.nAbility);
                    }
                } else
                {
                    // remove stacking effects
                    RemoveStackingEffects(oTargets[nCount], stEvent.oCaster, stEvent.nAbility);

                    // daze
                    eEffect = EffectDaze();
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTargets[nCount], WYNNE_PRE_TRINKET_DAZE_DURATION, stEvent.oCaster, stEvent.nAbility);
                }
            } else
            {
                UI_DisplayMessage(oTargets[nCount], UI_MESSAGE_RESISTED);
            }
        }
    }

    // trinket alterations
    float fHealth;
    float fMana;
    float fSpellpower;
    float fManaRegeneration;
    if (bTrinket == TRUE)
    {
        fHealth = (GetMaxHealth(stEvent.oCaster) * WYNNE_POST_TRINKET_HEALTH_FACTOR);
        fMana = (GetCreatureMaxMana(stEvent.oCaster) * WYNNE_POST_TRINKET_MANA_FACTOR);
        fSpellpower = (WYNNE_POST_TRINKET_SPELLPOWER_BONUS + GetLevel(stEvent.oCaster) * WYNNE_POST_TRINKET_SPELLPOWER_LEVEL_FACTOR);
        fManaRegeneration = WYNNE_POST_TRINKET_MANA_REGENERATION_BONUS;
    } else
    {
        fHealth = (GetMaxHealth(stEvent.oCaster) * WYNNE_PRE_TRINKET_HEALTH_FACTOR);
        fMana = (GetCreatureMaxMana(stEvent.oCaster) * WYNNE_PRE_TRINKET_MANA_FACTOR);
        fSpellpower = (WYNNE_PRE_TRINKET_SPELLPOWER_BONUS + GetLevel(stEvent.oCaster) * WYNNE_PRE_TRINKET_SPELLPOWER_LEVEL_FACTOR);
        fManaRegeneration = WYNNE_PRE_TRINKET_MANA_REGENERATION_BONUS;
    }

    // effects
    eEffects[0] = EffectHeal(fHealth);
    eEffects[1] = EffectModifyManaStamina(fMana);
    eEffects[2] = EffectModifyProperty(PROPERTY_ATTRIBUTE_SPELLPOWER, fSpellpower);
    eEffects[2] = SetEffectEngineInteger(eEffects[2], EFFECT_INTEGER_VFX, Ability_GetImpactObjectVfxId(stEvent.nAbility));
    eEffects[3] = EffectModifyProperty(PROPERTY_ATTRIBUTE_REGENERATION_STAMINA, fManaRegeneration,
                                       PROPERTY_ATTRIBUTE_REGENERATION_STAMINA_COMBAT, fManaRegeneration);

    Log_Trace_Spell("_ActivateModalAbility", "Activating modal ability.", stEvent.nAbility, OBJECT_INVALID);

    Ability_ApplyUpkeepEffects(stEvent.oCaster, stEvent.nAbility, eEffects, stEvent.oTarget, bPartywide);

    Log_Trace_Spell("_ActivateModalAbility", "Modal ability activated.", stEvent.nAbility, OBJECT_INVALID);


    // Create the "Glowing" Effect on Wynne for the Duration
    ApplyEffectVisualEffect(OBJECT_SELF, OBJECT_SELF, 1093, EFFECT_DURATION_TYPE_TEMPORARY, WYNNE_DURATION, stEvent.nAbility);
    ApplyEffectVisualEffect(OBJECT_SELF, OBJECT_SELF, 3007, EFFECT_DURATION_TYPE_TEMPORARY, WYNNE_DURATION, stEvent.nAbility);

    // apply auto-ending effect
    eEffect = Effect(EFFECT_TYPE_WYNNE_REMOVAL);
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oCaster, WYNNE_DURATION, stEvent.oCaster, stEvent.nAbility);
}

// remove effects
void _DeactivateModalAbility(object oCaster, int nAbility)
{
    Log_Trace_Spell("_DeactivateModalAbility", "Deactivate modal ability.", nAbility, OBJECT_INVALID);

    // remove effects
    RemoveStackingEffects(oCaster, oCaster, nAbility);
}

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    switch(nEventType)
    {
        case EVENT_TYPE_SPELLSCRIPT_PENDING:
        {
            // hand through
            Ability_SetSpellscriptPendingEventResult(COMMAND_RESULT_SUCCESS);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            // we just hand this through to cast_impact
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_IMPACT",Log_GetAbilityNameById(stEvent.nAbility));

            // Remove any previously existing effects from same spellid to avoid stacking
            Ability_PreventAbilityEffectStacking(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility);

            // activate ability
            _ActivateModalAbility(stEvent);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_DEACTIVATE:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptDeactivateStruct stEvent = Events_GetEventSpellScriptDeactivateParameters(ev);

            // is ability active?
            if (IsModalAbilityActive(stEvent.oCaster, stEvent.nAbility) == TRUE)
            {
                _DeactivateModalAbility(stEvent.oCaster, stEvent.nAbility);
            }

            // Setting Return Value (abort means we aborted the ability)
            Ability_SetSpellscriptPendingEventResult(COMMAND_RESULT_INVALID);

            break;
        }
    }
}