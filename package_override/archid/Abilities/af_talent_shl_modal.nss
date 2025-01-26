//*=============================================================================
// AB: script for Shale's modals and passives
//*=============================================================================

#include "abi_templates"
#include "combat_h"
#include "plt_tut_modal"

const int SHALE_PULVERIZE = 300100;
const int SHALE_SLAM = 300101;
const int SHALE_QUAKE = 300102;
const int SHALE_KILLING_BLOW = 300103;
const int SHALE_STONEHEART = 300200;
const int SHALE_BELLOW = 300201;
const int SHALE_STONE_ROAR = 300202;
const int SHALE_REGENERATE_BURST = 300203;
const int SHALE_ROCK_MASTERY = 300300;
const int SHALE_HURL_ROCK = 300301;
const int SHALE_EARTHEN_GRASP = 300302;
const int SHALE_ROCK_BARRAGE = 300303;
const int SHALE_STONE_AURA = 300400;
const int SHALE_INNER_RESERVES = 300401;
const int SHALE_RENEWED_ASSAULT = 300402;
const int SHALE_SUPER_RESISTANCE = 300403;

const int SHALE_RANGED_MODE_AOE = 2003;

const int SHALE_TAUNT_AURA = 2010;

// different radii for Stone Aura
const int SHALE_STONE_AURA_1 = 2011; // 6m
const int SHALE_STONE_AURA_2 = 2012; // 6.5m
const int SHALE_STONE_AURA_3 = 2013; // 7m
const int SHALE_STONE_AURA_4 = 2014; // 8m

// persistent aura script
const resource SCRIPT_SHL_AOE_DURATION = R"af_talent_shl_aoe_duration.ncs";

// add effects
void _ActivateModalAbility(struct EventSpellScriptImpactStruct stEvent)
{
    // effects
    effect eEffect;
    effect[] eEffects;
    int nVFX = Ability_GetImpactObjectVfxId(stEvent.nAbility);
    int nIndx = 0;

    if(IsFollower(stEvent.oCaster))
    {
        WR_SetPlotFlag(PLT_TUT_MODAL, TUT_MODAL_1, TRUE);
    }

    // -------------------------------------------------------------------------
    // Handle Abilities
    // -------------------------------------------------------------------------
    switch (stEvent.nAbility)
    {
        case SHALE_PULVERIZE:
        {
            // added crit chance, attack bonus, ms bonus,
            // armor penalty, extra def penalty
            // basically Berserk mode
            float fDamageInc = 4.0;
            float fAttackInc = 4.0;
            float fDefDec = -10.0;
            float fArmorDec = -5.0;
            float fAPInc = 0.0;
            float fMoveSpeed = 1.15;
            float fCritChance = 0.0;

            if (HasAbility(stEvent.oCaster, SHALE_SLAM))
            {
                fDamageInc += 2.0;
                fAttackInc += 2.0;
                fAPInc += 3.0;
            }

            if (HasAbility(stEvent.oCaster, SHALE_QUAKE))
            {
                fDefDec -= 5.0; // total: -15
            }

            if (HasAbility(stEvent.oCaster, SHALE_KILLING_BLOW))
            {
                fDamageInc += 2.0; // total: 8
                fAttackInc += 2.0; // total: 8
                fAPInc += 3.0; // total: 6
                fCritChance = 5.0;
            }

            eEffects[nIndx] = EffectModifyProperty(PROPERTY_ATTRIBUTE_DAMAGE_BONUS, fDamageInc,
                                                   PROPERTY_ATTRIBUTE_ATTACK, fAttackInc);
            eEffects[nIndx++] = SetEffectEngineInteger(eEffects[0], EFFECT_INTEGER_VFX, nVFX); // VFX - looping glow

            eEffects[nIndx++] = EffectModifyProperty(PROPERTY_ATTRIBUTE_DEFENSE, fDefDec,
                                                     PROPERTY_ATTRIBUTE_ARMOR, fArmorDec);

            if (fAPInc > 0.0)
            {
                eEffects[nIndx++] = EffectModifyProperty(PROPERTY_ATTRIBUTE_AP, fAPInc);
            }

            if (HasAbility(stEvent.oCaster, SHALE_QUAKE))
            {
                eEffects[nIndx++] = EffectModifyMovementSpeed(fMoveSpeed);
            }

            if (fCritChance > 0.0)
            {
                eEffects[nIndx] = EffectModifyProperty(PROPERTY_ATTRIBUTE_MELEE_CRIT_MODIFIER, fCritChance);
            }

            break;
        }

        case SHALE_STONEHEART:
        {
            // buffed defenses
            // added physical resistance, damage penalty, crit chance penalty
            // attack speed modifier doesn't seem to work on Shale
            float fArmorInc = 6.0;
            float fElResist = 12.0;
            float fPhysResist = 16.0;
            float fDamageDec = -6.0;
            float fCritChance = -10.0;
            effect eVFX;

            if (HasAbility(stEvent.oCaster, SHALE_BELLOW))
            {
                fArmorInc += 3.0;
                fElResist += 6.0;
                fPhysResist += 8.0;
            }

            if (HasAbility(stEvent.oCaster, SHALE_REGENERATE_BURST))
            {
                fArmorInc += 3.0; // total: 12
                fElResist += 6.0; // total: 24
                fPhysResist += 8.0; // total: 32
            }


            eEffects[nIndx] = EffectModifyProperty(PROPERTY_ATTRIBUTE_ARMOR, fArmorInc,
                                                   PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_FIRE, fElResist,
                                                   PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_COLD, fElResist);
            eEffects[nIndx++] = SetEffectEngineInteger(eEffects[0], EFFECT_INTEGER_VFX, nVFX); // VFX - looping glow

            eEffects[nIndx++] = EffectModifyProperty(PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_ELEC, fElResist,
                                                     PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_NATURE, fElResist,
                                                     PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_SPIRIT, fElResist);

            eEffects[nIndx++] = EffectModifyProperty(PROPERTY_ATTRIBUTE_RESISTANCE_PHYSICAL, fPhysResist,
                                                     PROPERTY_ATTRIBUTE_RESISTANCE_MENTAL, fPhysResist);

            eEffects[nIndx++] = EffectModifyProperty(PROPERTY_ATTRIBUTE_DAMAGE_BONUS, fDamageDec,
                                                     PROPERTY_ATTRIBUTE_MELEE_CRIT_MODIFIER, fCritChance);

            if (HasAbility(stEvent.oCaster, SHALE_STONE_ROAR)) // HP/stamina regen
            {
                eEffects[nIndx++] = EffectModifyProperty(PROPERTY_ATTRIBUTE_REGENERATION_HEALTH, 3.0,
                                                         PROPERTY_ATTRIBUTE_REGENERATION_HEALTH_COMBAT, 3.0);

                eEffects[nIndx++] = EffectModifyProperty(PROPERTY_ATTRIBUTE_REGENERATION_STAMINA, 2.0,
                                                         PROPERTY_ATTRIBUTE_REGENERATION_STAMINA_COMBAT, 2.0);
            }

            // new VFX - ripped from Taunt, tinted blue, indicates taunt effect
            ApplyEffectVisualEffect(stEvent.oCaster, stEvent.oCaster, 105429, EFFECT_DURATION_TYPE_INSTANT, 0.0f, stEvent.nAbility);

            eEffects[nIndx] = EffectAreaOfEffect(SHALE_TAUNT_AURA, SCRIPT_SHL_AOE_DURATION);

            break;
        }

        case SHALE_ROCK_MASTERY:
        {
            // added move speed penalty, increased missile def
            // removed armor/defense/crit chance penalty
            float fMissileDef = 40.0;
            float fAttackDec = -10.0;
            float fMoveSpeed = 0.7;

            if (HasAbility(stEvent.oCaster, SHALE_HURL_ROCK))
            {
                fMissileDef += 10.0;
            }

            if (HasAbility(stEvent.oCaster, SHALE_EARTHEN_GRASP))
            {
                fMissileDef += 10.0;
            }

            if (HasAbility(stEvent.oCaster, SHALE_ROCK_BARRAGE))
            {
                fMissileDef += 10.0; // total: 70
            }

            eEffects[nIndx] = EffectModifyProperty(PROPERTY_ATTRIBUTE_MISSILE_SHIELD, fMissileDef,
                                                   PROPERTY_ATTRIBUTE_ATTACK, fAttackDec);
            eEffects[nIndx++] = SetEffectEngineInteger(eEffects[0], EFFECT_INTEGER_VFX, nVFX); // VFX - looping glow

            eEffects[nIndx++] = EffectModifyMovementSpeed(fMoveSpeed);

            eEffects[nIndx] = EffectAreaOfEffect(SHALE_RANGED_MODE_AOE, SCRIPT_SHL_AOE_DURATION, 105417); // VFX - aura
            eEffects[nIndx] = SetEffectEngineFloat(eEffects[nIndx], EFFECT_FLOAT_SCALE, GetM2DAFloat(TABLE_VFX_PERSISTENT, "RADIUS", SHALE_RANGED_MODE_AOE)); // scale VFX radius

            break;
        }

        case SHALE_STONE_AURA:
        {
            // buffed defenses
            // added physical resistance (doesn't matter much - concept element)
            // increased stamina penalty
            float fArmorInc = 15.0;
            float fElemResist = 15.0;
            float fSpellResist = 12.0;
            float fPhysResist = 30.0;
            float fDefDec = -50.0;
            float fStamDec = -15.0;
            int nID = 0;

            // bigger radius when progressing tree
            if (HasAbility(stEvent.oCaster, SHALE_SUPER_RESISTANCE))
            {
                nID = SHALE_STONE_AURA_4; // 8m
            }
            else if (HasAbility(stEvent.oCaster, SHALE_RENEWED_ASSAULT))
            {
                nID = SHALE_STONE_AURA_3; // 7m
            }
            else if (HasAbility(stEvent.oCaster, SHALE_INNER_RESERVES))
            {
                nID = SHALE_STONE_AURA_2; // 6.5m
            }
            else
            {
                nID = SHALE_STONE_AURA_1; // 6m
            }

            if (HasAbility(stEvent.oCaster, SHALE_INNER_RESERVES))
            {
                fStamDec += 3.0;
            }

            if (HasAbility(stEvent.oCaster, SHALE_RENEWED_ASSAULT))
            {
                fArmorInc += 5.0; // 20
                fElemResist += 10.0;  // 25
                fSpellResist += 8.0; // 20
            }

            if (HasAbility(stEvent.oCaster, SHALE_SUPER_RESISTANCE))
            {
                fArmorInc += 5.0; // total: 25
                fElemResist += 10.0; // total: 35
                fSpellResist += 8.0; // total: 28
                fPhysResist += 20.0;// total: 50
            }

            eEffects[nIndx] = EffectModifyProperty(PROPERTY_ATTRIBUTE_ARMOR, fArmorInc,
                                                   PROPERTY_ATTRIBUTE_SPELLRESISTANCE, fSpellResist,
                                                   PROPERTY_ATTRIBUTE_RESISTANCE_PHYSICAL, fPhysResist);
            eEffects[nIndx++] = SetEffectEngineInteger(eEffects[0], EFFECT_INTEGER_VFX, nVFX); // VFX - looping glow

            eEffects[nIndx++] = EffectModifyProperty(PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_FIRE, fElemResist,
                                                     PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_COLD, fElemResist,
                                                     PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_ELEC, fElemResist);

            eEffects[nIndx++] = EffectModifyProperty(PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_NATURE, fElemResist,
                                                     PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_SPIRIT, fElemResist);

            eEffects[nIndx++] = EffectModifyProperty(PROPERTY_ATTRIBUTE_DEFENSE, fDefDec,
                                                     PROPERTY_ATTRIBUTE_REGENERATION_STAMINA, fStamDec,
                                                     PROPERTY_ATTRIBUTE_REGENERATION_STAMINA_COMBAT, fStamDec);

            eEffects[nIndx++] = EffectParalyze();

            eEffects[nIndx] = EffectAreaOfEffect(nID, SCRIPT_SHL_AOE_DURATION, 105415); // VFX - aura
            eEffects[nIndx] = SetEffectEngineFloat(eEffects[nIndx], EFFECT_FLOAT_SCALE, GetM2DAFloat(TABLE_VFX_PERSISTENT, "RADIUS", nID)); // scale VFX radius

            break;
        }
    }

    Ability_ApplyUpkeepEffects(stEvent.oCaster, stEvent.nAbility, eEffects, stEvent.oTarget);
}

// remove effects
void _DeactivateModalAbility(object oCaster, int nAbility)
{
    // remove effects
    Effects_RemoveUpkeepEffect(oCaster, nAbility);

    // clear Stone Will effects if Stoneheart is deactivated
    if (nAbility == SHALE_STONEHEART && GetHasEffects(oCaster, EFFECT_TYPE_STONE_WILL, SHALE_STONE_ROAR))
    {
        RemoveEffectsByParameters(oCaster, EFFECT_TYPE_INVALID, SHALE_STONE_ROAR);
        RemoveAbility(oCaster, ABILITY_TRAIT_STURDY);
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

            // modal-specific VFX's
            switch (stEvent.nAbility)
            {
                case SHALE_PULVERIZE:
                {
                    ApplyEffectVisualEffect(OBJECT_SELF, OBJECT_SELF, 105425, EFFECT_DURATION_TYPE_INSTANT, 0.0f, stEvent.nAbility);
                    ApplyEffectVisualEffect(OBJECT_SELF, OBJECT_SELF, 105419, EFFECT_DURATION_TYPE_INSTANT, 0.0f, stEvent.nAbility);

                    break;
                }

                case SHALE_STONEHEART:
                {
                    ApplyEffectVisualEffect(OBJECT_SELF, OBJECT_SELF, 105426, EFFECT_DURATION_TYPE_INSTANT, 0.0f, stEvent.nAbility);
                    ApplyEffectVisualEffect(OBJECT_SELF, OBJECT_SELF, 105419, EFFECT_DURATION_TYPE_INSTANT, 0.0f, stEvent.nAbility);

                    break;
                }

                case SHALE_ROCK_MASTERY:
                {
                    ApplyEffectVisualEffect(OBJECT_SELF, OBJECT_SELF, 105427, EFFECT_DURATION_TYPE_INSTANT, 0.0f, stEvent.nAbility);
                    ApplyEffectVisualEffect(OBJECT_SELF, OBJECT_SELF, 105419, EFFECT_DURATION_TYPE_INSTANT, 0.0f, stEvent.nAbility);

                    break;
                }

                case SHALE_STONE_AURA:
                {
                    ApplyEffectVisualEffect(OBJECT_SELF, OBJECT_SELF, 105428, EFFECT_DURATION_TYPE_INSTANT, 0.0f, stEvent.nAbility);
                    ApplyEffectVisualEffect(OBJECT_SELF, OBJECT_SELF, 105419, EFFECT_DURATION_TYPE_INSTANT, 0.0f, stEvent.nAbility);

                    break;
                }
            }

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

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