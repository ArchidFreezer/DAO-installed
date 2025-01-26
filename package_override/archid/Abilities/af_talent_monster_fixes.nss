// -----------------------------------------------------------------------------
// talent_single_target.nss
// -----------------------------------------------------------------------------
/*
    Generic Ability Script for single target abilities
*/
// -----------------------------------------------------------------------------
// georg / petert
// -----------------------------------------------------------------------------

#include "abi_templates"
#include "sys_traps_h"
#include "monster_constants_h"
#include "spell_constants_h"


const int PRIDE_DEMON_MANA_WAVE_DISPEL_VFX = 1012;
const float RAGE_DEMON_SLAM_ARMOR_PENATRATION = 5.0;
const float ASHWRAITH_DRAIN_MANA_SLAM = 5.0;

const resource SCRIPT_MONSTER_AOE_DURATION = R"monster_aoe_duration.ncs";

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    // -------------------------------------------------------------------------
    // Handle Spells
    // -------------------------------------------------------------------------
    switch (stEvent.nAbility)
    {
        case ABILITY_TALENT_MONSTER_ABOMINATION_TRIPLESTRIKE_SLOTH:
        {
            // normal combat damage
            object oWeapon  = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, stEvent.oCaster);
            int nResult     = Combat_GetAttackResult(stEvent.oCaster, stEvent.oTarget, oWeapon, 0.0f, stEvent.nAbility);

            float fDamage   = Combat_Damage_GetAttackDamage(stEvent.oCaster, stEvent.oTarget, oWeapon, nResult, 0.0);

            effect eImpactEffect = EffectImpact(fDamage, oWeapon, 0, stEvent.nAbility);
            Combat_HandleAttackImpact(stEvent.oCaster, stEvent.oTarget, nResult, eImpactEffect);

            // debuf attack/defense
            if(stEvent.nHit == 3)
            {
                // remove stacking effects
                RemoveStackingEffects(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility);

                effect eEffect = EffectDecreaseProperty(PROPERTY_ATTRIBUTE_ATTACK, ABOMINATION_ATTACK_PENALTY, PROPERTY_ATTRIBUTE_DEFENSE, ABOMINATION_DEFENSE_PENALTY);
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, ABOMINATION_DEBUF_DURATION, stEvent.oCaster, stEvent.nAbility);
            }

            break;
        }
        case ABILITY_TALENT_MONSTER_ABOMINATION_TRIPLESTRIKE_DESIRE:
        {
            // normal combat damage
            object oWeapon  = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, stEvent.oCaster);
            int nResult     = Combat_GetAttackResult(stEvent.oCaster, stEvent.oTarget, oWeapon, 0.0f, stEvent.nAbility);

            float fDamage   = Combat_Damage_GetAttackDamage(stEvent.oCaster, stEvent.oTarget, oWeapon, nResult, 0.0);

            effect eImpactEffect = EffectImpact(fDamage, oWeapon, 0, stEvent.nAbility);
            Combat_HandleAttackImpact(stEvent.oCaster, stEvent.oTarget, nResult, eImpactEffect);

            // debuf resistances
            if(stEvent.nHit == 3)
            {
                // remove stacking effects
                RemoveStackingEffects(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility);

                effect eEffect = EffectDecreaseProperty(PROPERTY_ATTRIBUTE_RESISTANCE_MENTAL, ABOMINATION_RESISTANCE_PENALTY, PROPERTY_ATTRIBUTE_RESISTANCE_PHYSICAL, ABOMINATION_RESISTANCE_PENALTY);
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, ABOMINATION_DEBUF_DURATION, stEvent.oCaster, stEvent.nAbility);
            }

            break;
        }

        case MONSTER_SUCCUBUS_SCREAM:
        {
            float fDamage = GetLevel(stEvent.oCaster) * MONSTER_SUCCUBUS_SCREAM_BASE_DAMAGE;

            effect eStun = EffectStun();
            ApplyEffectVisualEffect(stEvent.oCaster, stEvent.oCaster, MONSTER_SUCCUBUS_SCREAM_AOE_VFX, EFFECT_DURATION_TYPE_INSTANT, 0.0, stEvent.nAbility);

            // apply damage to targets
            object [] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, GetLocation(stEvent.oCaster), MONSTER_SUCCUBUS_SCREAM_RADIUS);
            int nCount = 0;
            int nNum = GetArraySize(oTargets);
            for (nCount = 0; nCount < nNum; nCount++)
            {
                // aoe doesn't harm itself or allies
                if (GetGroupId(oTargets[nCount]) != GetGroupId(stEvent.oCaster))
                {
                    Effects_ApplyInstantEffectDamage(oTargets[nCount], stEvent.oCaster, fDamage, DAMAGE_TYPE_SPIRIT, DAMAGE_EFFECT_FLAG_NONE, stEvent.nAbility);
                    ApplyEffectVisualEffect(stEvent.oCaster, oTargets[nCount], MONSTER_SUCCUBUS_SCREAM_CRUST_VFX, EFFECT_DURATION_TYPE_INSTANT, 0.0);

                    // mental resistance
                    if (ResistanceCheck(stEvent.oCaster, stEvent.oTarget, PROPERTY_ATTRIBUTE_SPELLPOWER, RESISTANCE_MENTAL) == FALSE)
                    {
                        float fDuration = GetRankAdjustedEffectDuration(oTargets[nCount], MONSTER_SUCCUBUS_SCREAM_STUN_DURATION);

                        // remove stacking effects
                        RemoveStackingEffects(oTargets[nCount], stEvent.oCaster, stEvent.nAbility);

                        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eStun, oTargets[nCount], fDuration, stEvent.oCaster, stEvent.nAbility);
                    }
                }
            }
            break;
        }
        case MONSTER_SUCCUBUS_DANCE:
        {
            ApplyEffectVisualEffect(stEvent.oCaster, stEvent.oCaster, MONSTER_SUCCUBUS_DANCE_AOE_VFX, EFFECT_DURATION_TYPE_INSTANT, 0.0, stEvent.nAbility);

            // apply damage to targets
            object [] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, GetLocation(stEvent.oCaster), MONSTER_SUCCUBUS_DANCE_RADIUS);
            int nCount = 0;
            int nNum = GetArraySize(oTargets);
            object oTarget;
            for (nCount = 0; nCount < nNum; nCount++)
            {
                oTarget = oTargets[nCount];
                // aoe doesn't harm itself or allies
                if (GetGroupId(oTarget) != GetGroupId(stEvent.oCaster))
                {
                    // remove stacking effects
                    RemoveStackingEffects(oTarget, stEvent.oCaster, stEvent.nAbility);

                    ApplyEffectVisualEffect(stEvent.oCaster, oTarget, MONSTER_SUCCUBUS_DANCE_IMPACT_VFX, EFFECT_DURATION_TYPE_INSTANT, 0.0);

                    if(GetCreatureGender(oTarget) == GENDER_FEMALE) // Vulnerability hex
                    {
                        effect eEffect;
                        eEffect = EffectDecreaseProperty(PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_FIRE, MONSTER_SUCCUBUS_DEBUF_RESIST_PENALTY,
                                                         PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_COLD, MONSTER_SUCCUBUS_DEBUF_RESIST_PENALTY,
                                                         PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_ELEC, MONSTER_SUCCUBUS_DEBUF_RESIST_PENALTY);
                        eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_VFX, Ability_GetImpactObjectVfxId(stEvent.nAbility));
                        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTarget, MONSTER_SUCCUBUS_DEBUF_DURATION, stEvent.oCaster, stEvent.nAbility);

                        eEffect = EffectDecreaseProperty(PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_NATURE, MONSTER_SUCCUBUS_DEBUF_RESIST_PENALTY,
                                                         PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_SPIRIT, MONSTER_SUCCUBUS_DEBUF_RESIST_PENALTY);
                        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTarget, MONSTER_SUCCUBUS_DEBUF_DURATION, stEvent.oCaster, stEvent.nAbility);

                        eEffect = EffectDecreaseProperty(PROPERTY_ATTRIBUTE_RESISTANCE_PHYSICAL, MONSTER_SUCCUBUS_DEBUF_RESIST_PENALTY,
                                                         PROPERTY_ATTRIBUTE_RESISTANCE_MENTAL, MONSTER_SUCCUBUS_DEBUF_RESIST_PENALTY);
                        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTarget, MONSTER_SUCCUBUS_DEBUF_DURATION, stEvent.oCaster, stEvent.nAbility);

                        eEffect = EffectKnockdown(stEvent.oCaster, 0, stEvent.nAbility);
                        ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oTarget, 0.0, stEvent.oCaster, stEvent.nAbility);
                    }
                    else // male/neutral -> sleep + curse of mortality
                    {
                        // mental resistance
                        if (ResistanceCheck(stEvent.oCaster, stEvent.oTarget, PROPERTY_ATTRIBUTE_SPELLPOWER, RESISTANCE_MENTAL) == FALSE)
                        {
                            float fDuration = GetRankAdjustedEffectDuration(oTarget, MONSTER_SUCCUBUS_SLEEP_DURATION);
                            ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, EffectSleep(), oTarget, fDuration, stEvent.oCaster, stEvent.nAbility);
                        }

                        effect eEffect = Effect(EFFECT_TYPE_CURSE_OF_MORTALITY);
                        eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_VFX, Ability_GetImpactObjectVfxId(stEvent.nAbility));
                        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTarget, MONSTER_SUCCUBUS_SLEEP_DURATION, stEvent.oCaster, stEvent.nAbility);

                        // health regeneration
                        eEffect = EffectDecreaseProperty(PROPERTY_ATTRIBUTE_REGENERATION_HEALTH, MONSTER_SUCCUBUS_HEALTH_DEGEN_PENALTY,
                                                         PROPERTY_ATTRIBUTE_REGENERATION_HEALTH_COMBAT, MONSTER_SUCCUBUS_HEALTH_DEGEN_PENALTY);
                        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTarget, MONSTER_SUCCUBUS_SLEEP_DURATION, stEvent.oCaster, stEvent.nAbility);
                        
                        // spirit dot
                        ApplyEffectDamageOverTime(oTarget, stEvent.oCaster, stEvent.nAbility, MONSTER_SUCCUBUS_CURSE_DAMAGE_TOTAL, MONSTER_SUCCUBUS_SLEEP_DURATION, DAMAGE_TYPE_SPIRIT);

                    }
                }
            }
            break;
        }
        case ABILITY_TALENT_MONSTER_STALKER_SCARE:
        {
            // remove stacking effects
            RemoveStackingEffects(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility);

            // damage bonus, attack bonus
            effect eEffect = EffectDecreaseProperty(PROPERTY_ATTRIBUTE_ATTACK, STALKER_SCARE_ATTACK_PENALTY, PROPERTY_ATTRIBUTE_DEFENSE, STALKER_SCARE_DEFENSE_PENALTY);
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, STALKER_SCARE_DURATION, stEvent.oCaster, stEvent.nAbility);

            break;
        }

        case ABILITY_TALENT_MONSTER_CANINE_HOWL:
        {
            //get the rank of the creature - bosses do special howl stuff
            if (GetCreatureRank(stEvent.oCaster) == CREATURE_RANK_BOSS)
            {
                // impact damage
                float fDamage = 3.0 * GetLevel(stEvent.oCaster);
                // defense penalty
                effect eEffectPen = EffectDecreaseProperty(PROPERTY_ATTRIBUTE_DEFENSE, CANINE_HOWL_DEFENSE_PENALTY);
                // knockdown
                effect eEffectKnockdown = EffectKnockdown(stEvent.oCaster, 0, stEvent.nAbility);
                eEffectKnockdown = SetEffectEngineInteger(eEffectKnockdown, EFFECT_INTEGER_USE_INTERPOLATION_ANGLE, 2);
                eEffectKnockdown = SetEffectEngineVector(eEffectKnockdown, EFFECT_VECTOR_ORIGIN, GetPosition(stEvent.oCaster));
                // get creatures in range
                object[] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, GetLocation(stEvent.oCaster), CANINE_HOWL_RADIUS);
                int nCount = 0;
                int nMax = GetArraySize(oTargets);
                for (nCount = 0; nCount < nMax; nCount++)
                {
                    object oTarget = oTargets[nCount];
                    if (IsObjectHostile(stEvent.oCaster, oTarget))
                    {
                        // mental resistance
                        if (ResistanceCheck(stEvent.oCaster, oTarget, PROPERTY_ATTRIBUTE_STRENGTH, RESISTANCE_MENTAL) == FALSE)
                        {
                            // remove stacking effects
                            RemoveStackingEffects(oTarget, stEvent.oCaster, stEvent.nAbility);

                            // apply defense penalty
                            ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffectPen, oTarget, CANINE_HOWL_DEFENSE_PENALTY_DURATION, stEvent.oCaster, stEvent.nAbility);
                        }
                        // physical resistance
                        if (ResistanceCheck(stEvent.oCaster, oTarget, PROPERTY_ATTRIBUTE_ATTACK, RESISTANCE_PHYSICAL) == FALSE)
                        {
                            ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffectKnockdown, oTarget, RandomFloat(), stEvent.oCaster, stEvent.nAbility);
                            //damage
                            Effects_ApplyInstantEffectDamage(oTarget, stEvent.oCaster, fDamage, DAMAGE_TYPE_PHYSICAL, DAMAGE_EFFECT_FLAG_NONE, stEvent.nAbility);

                        }
                        else // half damage
                        {
                            //damage
                            Effects_ApplyInstantEffectDamage(oTarget, stEvent.oCaster, fDamage * 0.5, DAMAGE_TYPE_PHYSICAL, DAMAGE_EFFECT_FLAG_NONE, stEvent.nAbility);

                        }
                    }
                }
            }
            else
            {
                // apply attack bonus
                effect eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_ATTACK, CANINE_HOWL_ATTACK_BONUS);
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oCaster, CANINE_HOWL_ATTACK_BONUS_DURATION, stEvent.oCaster, stEvent.nAbility);

                // defense penalty
                eEffect = EffectDecreaseProperty(PROPERTY_ATTRIBUTE_DEFENSE, CANINE_HOWL_DEFENSE_PENALTY);

                // get creatures in range
                object[] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, GetLocation(stEvent.oCaster), CANINE_HOWL_RADIUS);
                int nCount = 0;
                int nMax = GetArraySize(oTargets);
                for (nCount = 0; nCount < nMax; nCount++)
                {
                    if (IsObjectHostile(stEvent.oCaster, oTargets[nCount]))
                    {
                        // mental resistance
                        if (ResistanceCheck(stEvent.oCaster, oTargets[nCount], PROPERTY_ATTRIBUTE_STRENGTH, RESISTANCE_MENTAL) == FALSE)
                        {
                            // remove stacking effects
                            RemoveStackingEffects(oTargets[nCount], stEvent.oCaster, stEvent.nAbility);

                            // apply defense penalty
                            ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTargets[nCount], CANINE_HOWL_DEFENSE_PENALTY_DURATION, stEvent.oCaster, stEvent.nAbility);
                        }
                    }
                }
            }
            break;
        }

        case ABILITY_TALENT_MONSTER_OGRE_STOMP:
        {
            // Apply impact vfx and screen shake
            Ability_ApplyLocationImpactVFX(stEvent.nAbility, GetLocation(stEvent.oCaster));
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, EffectScreenShake(SCREEN_SHAKE_TYPE_OGRE_STOMP), stEvent.oTarget, 1.0f, stEvent.oCaster, stEvent.nAbility);

            //effect   eDamage    = EffectDamage(fDamage, DAMAGE_TYPE_PHYSICAL, DAMAGE_EFFECT_FLAG_UPDATE_GORE);
            object   oWeapon    = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, stEvent.oCaster);
            effect   eKnockdown = EffectKnockdown(stEvent.oCaster, OGRE_STOMP_KNOCKDOWN_DEFENSE_PENALTY, stEvent.nAbility);
            object[] arTargets  = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, GetLocation(stEvent.oCaster), OGRE_STOMP_RADIUS);

            int i, nSize = GetArraySize(arTargets);
            for (i = 0; i < nSize; i++) {
                object oTarget = arTargets[i];
                if (oTarget == stEvent.oCaster)
                    continue;

                float fDamage = 0.75 * Combat_Damage_GetAttackDamage(stEvent.oCaster, oTarget, oWeapon, COMBAT_RESULT_HIT, 0.0);
                effect eDamage = EffectDamage(fDamage, DAMAGE_TYPE_PHYSICAL, DAMAGE_EFFECT_FLAG_UPDATE_GORE);
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eDamage, oTarget, 0.0, stEvent.oCaster, stEvent.nAbility);

                if (ResistanceCheck(stEvent.oCaster, oTarget, PROPERTY_ATTRIBUTE_STRENGTH, RESISTANCE_PHYSICAL) == FALSE) {
                    // 1-4 second knockdown
                    float fDuration = RandFF(3.0, 1.0);
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eKnockdown, oTarget, RandFF(3.0, 1.0), stEvent.oCaster, stEvent.nAbility);
                }
            }

            break;
        }

        case ABILITY_TALENT_BROODMOTHER_CHARGE_LEFT:
        case ABILITY_TALENT_BROODMOTHER_CHARGE_RIGHT:
        {
            float fRange = CHARGE_LEFT_RANGE;
            float fArcMin = CHARGE_LEFT_ARC_MIN;
            float fArcMax = CHARGE_LEFT_ARC_MAX;
            if (stEvent.nAbility == ABILITY_TALENT_BROODMOTHER_CHARGE_RIGHT) {
                fRange = CHARGE_RIGHT_RANGE;
                fArcMin = CHARGE_RIGHT_ARC_MIN;
                fArcMax = CHARGE_RIGHT_ARC_MAX;
            }

            // get all creatures within range
            object [] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, GetLocation(stEvent.oCaster), fRange);
            object oWeapon = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, stEvent.oCaster);

            int i, nSize = GetArraySize(oTargets);
            for (i = 0; i < nSize; i++)
            {
                object oTarget = oTargets[i];
                int nAppearance = GetAppearanceType(oTarget);
                // target isn't broodmother or tentacle
                if (nAppearance != APPEARANCE_BROODMOTHER && nAppearance != APPEARANCE_BROODMOTHER_TENTACLE)
                {
                    float fAngle = GetAngleBetweenObjects(stEvent.oCaster, oTarget);
                    if ((fAngle > fArcMin) && (fAngle <= fArcMax))
                    {
                        float fDamage = Combat_Damage_GetAttackDamage(stEvent.oCaster, oTarget, oWeapon, COMBAT_RESULT_HIT, 0.0);
                        effect eImpactEffect = EffectImpact(fDamage, oWeapon, 0, stEvent.nAbility);
                        Combat_HandleAttackImpact(stEvent.oCaster, oTarget, COMBAT_RESULT_HIT, eImpactEffect);

                        // phyiscal resistance
                        if (ResistanceCheck(stEvent.oCaster, oTarget, PROPERTY_ATTRIBUTE_STRENGTH, RESISTANCE_PHYSICAL) == FALSE)
                        {
                            effect eKnockdown = EffectKnockdown(stEvent.oCaster, 0, stEvent.nAbility);
                            ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eKnockdown, oTarget, 0.0f, stEvent.oCaster, stEvent.nAbility);
                        }
                    }
                }
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
            struct EventSpellScriptPendingStruct stEvent = Events_GetEventSpellScriptPendingParameters(ev);

            Ability_SetSpellscriptPendingEventResult(COMMAND_RESULT_SUCCESS);

            switch(stEvent.nAbility)
            {
                case ABILITY_TALENT_MONSTER_ABOMINATION_TRIPLESTRIKE_DESIRE:
                case ABILITY_TALENT_MONSTER_ABOMINATION_TRIPLESTRIKE_SLOTH:
                {
                    effect eEffect = EffectVisualEffect(ABOMINATION_TRIPPLESTRIKE_VFX);
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oCaster, ABOMINATION_TRIPPLESTRIKE_DURATION, stEvent.oCaster, stEvent.nAbility);

                    break;
                }
            }

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            // determine if attack hits
            object oMainWeapon = GetItemInEquipSlot(INVENTORY_SLOT_MAIN);
            struct CombatAttackResultStruct stAttack = Combat_PerformAttack(stEvent.oCaster, stEvent.oTarget, oMainWeapon,0.0f,stEvent.nAbility);

            // Hand this through to cast_impact
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);

            switch(stEvent.nAbility)
            {
                case MONSTER_SUCCUBUS_DANCE:
                case ABILITY_TALENT_MONSTER_STALKER_SCARE:
                case ABILITY_TALENT_MONSTER_CANINE_HOWL:
                {
                    Ability_ApplyObjectImpactVFX(stEvent.nAbility, stEvent.oCaster);

                    break;
                }

                case ABILITY_TALENT_MONSTER_OGRE_STOMP:
                {
                    PlaySoundSet(stEvent.oCaster, SS_COMBAT_ATTACK_GRUNT);

                    break;
                }
            }

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_IMPACT",Log_GetAbilityNameById(stEvent.nAbility));

            // Handle impact
            _HandleImpact(stEvent);

            SendEventOnCastAt(stEvent.oTarget,stEvent.oCaster, stEvent.nAbility, TRUE);

            switch(stEvent.nAbility)
            {
                case ABILITY_MONSTER_ARCANEHORROR_SWARM:
                {
                    Ability_ApplyObjectImpactVFX(stEvent.nAbility, stEvent.oCaster);

                    break;
                }
            }

            break;
        }
    }
}