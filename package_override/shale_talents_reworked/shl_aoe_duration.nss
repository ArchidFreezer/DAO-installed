//*=============================================================================
// AB: script for Shale's persistent auras
// Stoneheart's "taunt" aura, Rock Mastery, Stone Aura
//*=============================================================================

#include "ability_h"

const int SHALE_STONEHEART = 300200;
const int SHALE_STONE_ROAR = 300202;
const int SHALE_ROCK_MASTERY = 300300;
const int SHALE_HURL_ROCK = 300301;
const int SHALE_ROCK_BARRAGE = 300303;
const int SHALE_STONE_AURA = 300400;
const int SHALE_INNER_RESERVES = 300401;
const int SHALE_RENEWED_ASSAULT = 300402;
const int SHALE_SUPER_RESISTANCE = 300403;

const resource SCRIPT_RESOURCE = R"shl_aoe_duration.ncs";

//apply heartbeat effects
void _ApplyHeartbeatEffects(int nAbility, object oTarget, object oCreator)
{
    switch (nAbility)
    {
        case SHALE_STONEHEART: // "taunt" aura for Stoneheart
        {
            float fThreatInc = 10.0;

            if (HasAbility(oCreator, SHALE_STONE_ROAR))
            {
                fThreatInc += 10.0; // total: 20
            }

            AI_Threat_UpdateCreatureThreat(oTarget, oCreator, fThreatInc);

            break;
        }

        case SHALE_ROCK_MASTERY: // conditional bonuses when in AoE
        {
            if (GetGroupId(oTarget) == GetGroupId(oCreator) && oTarget != oCreator)
            {
                float fDistance = GetDistanceBetween(oTarget, oCreator);
                int bIsRanged = IsUsingRangedWeapon(oTarget);
                effect eEffect;

                float fAttackInc = 10.0;
                float fDamageInc = 6.0;
                float fMislDef = 20.0;

                if (fDistance <= 3.0) // missile def when within 3m
                {
                    // dummy ID to handle applying/removing conditional bonuses;
                    // also need this to prevent effect stacking after area transition
                    RemoveEffectsByParameters(oTarget, EFFECT_TYPE_INVALID, 300305, oCreator);

                    if (bIsRanged)
                    {
                        eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_ATTACK, fAttackInc,
                                                       PROPERTY_ATTRIBUTE_DAMAGE_BONUS, fDamageInc);
                        ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oTarget, 0.0f, oCreator, 300305);
                    }

                    eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_MISSILE_SHIELD, fMislDef);
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oTarget, 0.0f, oCreator, 300305);
                }
                else if (bIsRanged) // bonuses for ranged weapons
                {
                    RemoveEffectsByParameters(oTarget, EFFECT_TYPE_INVALID, 300305, oCreator);

                    eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_ATTACK, fAttackInc,
                                                   PROPERTY_ATTRIBUTE_DAMAGE_BONUS, fDamageInc);
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oTarget, 0.0f, oCreator, 300305);
                }
                else
                {
                    RemoveEffectsByParameters(oTarget, EFFECT_TYPE_INVALID, 300305, oCreator);
                }
            }

            break;
        }

        case SHALE_STONE_AURA: // proximity bonuses
        {
            if (GetGroupId(oTarget) == GetGroupId(oCreator) && oTarget != oCreator)
            {
                float fDistance = GetDistanceBetween(oTarget, oCreator);

                if (fDistance <= 4.0) // at 4m
                {
                    float fBonus1 = 2.0;
                    float fBonus2 = 3.0;
                    float fBonus3 = 4.0;
                    float fBonus4 = 5.0;
                    effect eEffect;

                    if (fDistance <= 2.0) // 2x bonuses within 2m
                    {
                        fBonus1 = 4.0; // for armor
                        fBonus2 = 6.0; // for spell/elem resistances and SP
                        fBonus3 = 8.0; // for phys/mental resistances
                        fBonus4 = 10.0; // for defense
                    }

                    // dummy ID to handle applying/removing conditional bonuses;
                    // also need this to prevent effect stacking after area transition
                    RemoveEffectsByParameters(oTarget, EFFECT_TYPE_INVALID, 300405, oCreator);

                    eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_DEFENSE, fBonus4,
                                                   PROPERTY_ATTRIBUTE_ARMOR, fBonus1,
                                                   PROPERTY_ATTRIBUTE_SPELLRESISTANCE, fBonus2);
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oTarget, 0.0f, oCreator, 300405);

                    eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_RESISTANCE_PHYSICAL, fBonus3,
                                                   PROPERTY_ATTRIBUTE_RESISTANCE_MENTAL, fBonus3,
                                                   PROPERTY_ATTRIBUTE_SPELLPOWER, fBonus2);
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oTarget, 0.0f, oCreator, 300405);

                    eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_FIRE, fBonus2,
                                                   PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_COLD, fBonus2,
                                                   PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_ELEC, fBonus2);
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oTarget, 0.0f, oCreator, 300405);

                    eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_NATURE, fBonus2,
                                                   PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_SPIRIT, fBonus2);
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oTarget, 0.0f, oCreator, 300405);
                }
                else
                {
                    RemoveEffectsByParameters(oTarget, EFFECT_TYPE_INVALID, 300405, oCreator);
                }
            }

            break;
        }
    }
}

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev); // CAST (directly from engine) or COMMAND_PENDING (re-directed by rules_core)

    switch(nEventType)
    {
        case EVENT_TYPE_SPELLSCRIPT_PENDING:
        {
            // Get structure containing event parameters
            struct EventSpellScriptPendingStruct stEvent = Events_GetEventSpellScriptPendingParameters(ev);

            // Setting return value
            Ability_SetSpellscriptPendingEventResult(COMMAND_RESULT_SUCCESS);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {
            // Get a structure containing event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            // Hand through to cast_impact
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);

            break;
        }

        case EVENT_TYPE_ENTER:
        {
            int nAbility = GetEventInteger(ev,0);
            object oTarget = GetEventTarget(ev);
            object oCreator = GetEventCreator(ev);

            float fScaledValue;
            effect eEffect;

            if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
            {
                // spell-specific on enter event
                switch (nAbility)
                {
                    case SHALE_ROCK_MASTERY:
                    {
                        float fCritChance = 6.0;
                        float fAimSpeed = -0.6;

                        if (HasAbility(oCreator, SHALE_HURL_ROCK))
                        {
                            fCritChance += 3.0;
                            fAimSpeed -= 0.3;
                        }

                        if (HasAbility(oCreator, SHALE_ROCK_BARRAGE))
                        {
                            fCritChance += 3.0; // total: 12
                            fAimSpeed -= 0.3; // total: -1.2 // not that useful though except when countering Haste bug
                        }

                        // if the same group
                        if (GetGroupId(oTarget) == GetGroupId(oCreator) && oTarget != oCreator)
                        {
                            // needed to prevent effect stacking after area transition
                            RemoveEffectsByParameters(oTarget, EFFECT_TYPE_INVALID, nAbility, oCreator);

                            eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_RANGED_CRIT_MODIFIER, fCritChance,
                                                           PROPERTY_ATTRIBUTE_RANGED_AIM_SPEED, fAimSpeed);

                            ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oTarget, 0.0f, oCreator, nAbility);
                        }

                        break;
                    }

                    case SHALE_STONE_AURA:
                    {
                        // reduced radius
                        // mostly defensive now
                        float fDefInc = 10.0;
                        float fArmorInc = 4.0;
                        float fPhysRes = 8.0;
                        float fElemRes = 6.0;
                        float fSpellRes = 6.0;
                        float fHPRegen = 0.0;
                        float fStmRegen = 0.0;
                        float fSpellpower = 0.0;
                        float fMoveSpeed = 1.0;

                        if (HasAbility(oCreator, SHALE_INNER_RESERVES))
                        {
                            fHPRegen += 3.0;
                            fStmRegen += 2.0;
                            fSpellpower += 4.0;
                        }

                        if (HasAbility(oCreator, SHALE_RENEWED_ASSAULT))
                        {
                            fHPRegen += 3.0; // total: 6
                            fStmRegen += 2.0; // total: 4
                            fSpellpower += 4.0; // total: 8 // at 2m: 14
                            fMoveSpeed = 1.15;
                        }

                        if (HasAbility(oCreator, SHALE_SUPER_RESISTANCE))
                        {
                            fDefInc += 5.0; // total: 15 // at 2m: 25
                            fArmorInc += 2.0; // total: 6 // at 2m: 10
                            fPhysRes += 4.0; // total: 12 // at 2m: 20
                            fElemRes += 3.0; // total: 9 // at 2m: 15
                            fSpellRes += 3.0; // total: 9 // at 2m: 15
                        }

                        // if the same group
                        if (GetGroupId(oTarget) == GetGroupId(oCreator) && oTarget != oCreator)
                        {
                            // needed to prevent effect stacking after area transition
                            RemoveEffectsByParameters(oTarget, EFFECT_TYPE_INVALID, nAbility, oCreator);

                            eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_DEFENSE, fDefInc,
                                                           PROPERTY_ATTRIBUTE_ARMOR, fArmorInc,
                                                           PROPERTY_ATTRIBUTE_SPELLRESISTANCE, fSpellRes);
                            ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oTarget, 0.0f, oCreator, nAbility);

                            eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_RESISTANCE_PHYSICAL, fPhysRes,
                                                           PROPERTY_ATTRIBUTE_RESISTANCE_MENTAL, fPhysRes);
                            ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oTarget, 0.0f, oCreator, nAbility);

                            eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_FIRE, fElemRes,
                                                           PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_COLD, fElemRes,
                                                           PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_ELEC, fElemRes);
                            ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oTarget, 0.0f, oCreator, nAbility);

                            eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_NATURE, fElemRes,
                                                           PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_SPIRIT, fElemRes);
                            ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oTarget, 0.0f, oCreator, nAbility);

                            if (HasAbility(oCreator, SHALE_INNER_RESERVES))
                            {
                                eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_REGENERATION_HEALTH, fHPRegen,
                                                               PROPERTY_ATTRIBUTE_REGENERATION_HEALTH_COMBAT, fHPRegen);
                                ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oTarget, 0.0f, oCreator, nAbility);

                                eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_REGENERATION_STAMINA, fStmRegen,
                                                               PROPERTY_ATTRIBUTE_REGENERATION_STAMINA_COMBAT, fStmRegen);
                                ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oTarget, 0.0f, oCreator, nAbility);

                                eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_SPELLPOWER, fSpellpower);
                                ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oTarget, 0.0f, oCreator, nAbility);
                            }

                            if (HasAbility(oCreator, SHALE_RENEWED_ASSAULT))
                            {
                                eEffect = EffectModifyMovementSpeed(fMoveSpeed);
                                ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oTarget, 0.0f, oCreator, nAbility);
                            }
                        }

                        break;
                    }
                }
            }

            break;
        }

        case EVENT_TYPE_AOE_HEARTBEAT:
        {
            int nAbility = GetEventInteger(ev,0);
            object oCreator = GetEventCreator(ev);
            float fInterval = 0.0f;

            if (nAbility == SHALE_ROCK_MASTERY && !HasAbility(oCreator, SHALE_ROCK_BARRAGE))
                break;

            if (nAbility == SHALE_STONE_AURA && !HasAbility(oCreator, SHALE_SUPER_RESISTANCE))
                break;

            int nCount = 0;
            // if Stoneheart then only collect targets when in combat
            if (nAbility != SHALE_STONEHEART || GetGameMode() == GM_COMBAT)
            {
                object[] oTargets = GetCreaturesInAOE(OBJECT_SELF);

                // run through all creatures in AoE
                int nMax = GetArraySize(oTargets);
                for (nCount = 0; nCount < nMax; nCount++)
                {
                    if (nAbility != SHALE_STONEHEART || IsObjectHostile(oCreator, oTargets[nCount]))
                    {
                        _ApplyHeartbeatEffects(nAbility, oTargets[nCount], oCreator);
                    }
                }
            }

            // heartbeat durations
            switch (nAbility)
            {
                case SHALE_STONEHEART:
                {
                    fInterval = 4.0;

                    break;
                }

                case SHALE_ROCK_MASTERY:
                {
                    if (HasAbility(oCreator, SHALE_ROCK_BARRAGE))
                        fInterval = 0.2;

                    break;
                }

                case SHALE_STONE_AURA:
                {
                    if (HasAbility(oCreator, SHALE_SUPER_RESISTANCE))
                        fInterval = 0.2;

                    break;
                }
            }

            if (fInterval > 0.0f)
            {
                if (IsObjectValid(OBJECT_SELF) && IsModalAbilityActive(oCreator, nAbility))
                {
                    // signal next heartbeat
                    DelayEvent(fInterval + 0.05f, OBJECT_SELF, ev);
                }
            }

            break;
        }

        case EVENT_TYPE_EXIT:
        {
            int nAbility = GetEventInteger(ev,0);
            object oTarget = GetEventTarget(ev);
            object oCreator = GetEventCreator(ev);

            if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
            {
                switch (nAbility)
                {
                    case SHALE_ROCK_MASTERY:
                    {
                        if (oTarget != oCreator)
                        {
                            RemoveEffectsByParameters(oTarget, EFFECT_TYPE_INVALID, 300305, oCreator);
                            RemoveEffectsByParameters(oTarget, EFFECT_TYPE_INVALID, nAbility, oCreator);
                        }

                        break;
                    }

                    case SHALE_STONE_AURA:
                    {
                        if (oTarget != oCreator)
                        {
                            RemoveEffectsByParameters(oTarget, EFFECT_TYPE_INVALID, 300405, oCreator);
                            RemoveEffectsByParameters(oTarget, EFFECT_TYPE_INVALID, nAbility, oCreator);
                        }

                        break;
                    }
                }
            }

            break;
        }
    }
}