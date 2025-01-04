#include "ability_h"
#include "core_h"
#include "combat_damage_h"
#include "talent_constants_h"
#include "plt_tut_modal"

float _GetAttackDamage(object oAttacker) {
    object oWeapon = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oAttacker);

    // I'd hate to break someone's mod that lets you use staves with shields
    if (GetBaseItemType(oWeapon) == BASE_ITEM_TYPE_STAFF)
        return Combat_Damage_GetMageStaffDamage(oAttacker, OBJECT_INVALID, oWeapon, TRUE);

    // Attribute Modifier
    float fStrength = Combat_Damage_GetAttributeBonus(oAttacker, HAND_MAIN, oWeapon, TRUE) * GetWeaponAttributeBonusFactor(oWeapon);
    // Weapon Damage
    float fWeapon = 0.5*(DmgGetWeaponBaseDamage(oWeapon) + DmgGetWeaponMaxDamage(oWeapon));
    // Character damage bonus
    float fDmgBonus = GetCreatureProperty(oAttacker, PROPERTY_ATTRIBUTE_DAMAGE_BONUS);
    
    // Put them all together
    return fStrength + fWeapon + fDmgBonus;
}

// add effects
void _ActivateModalAbility(struct EventSpellScriptImpactStruct stEvent)
{
    // effects
    effect eEffect;
    effect[] eEffects;
    int nVfx = Ability_GetImpactObjectVfxId(stEvent.nAbility);

    if(IsFollower(stEvent.oCaster))
    {
        WR_SetPlotFlag(PLT_TUT_MODAL, TUT_MODAL_1, TRUE);
    }

    eEffects[0] = EffectModifyProperty(PROPERTY_ATTRIBUTE_ARMOR, SHIELD_WALL_ARMOR_BONUS);
    eEffects[1] = EffectModifyProperty(PROPERTY_ATTRIBUTE_MISSILE_SHIELD, SHIELD_WALL_MISSILE_SHIELD_BONUS);
    eEffects[2] = EffectModifyProperty(PROPERTY_ATTRIBUTE_DAMAGE_BONUS, -0.2f * _GetAttackDamage(stEvent.oCaster));

    // shield mastery bonus
    if (HasAbility(stEvent.oCaster, ABILITY_TALENT_SHIELD_MASTERY) == TRUE)
    {
        eEffects[3] = EffectModifyProperty(PROPERTY_ATTRIBUTE_DEFENSE, SHIELD_MASTERY_SHIELD_WALL_DEFENSE_BONUS);
    }

    // activation vfx
    Ability_ApplyObjectImpactVFX(stEvent.nAbility, stEvent.oCaster);

    Ability_ApplyUpkeepEffects(stEvent.oCaster, stEvent.nAbility, eEffects, stEvent.oTarget);
}

// remove effects
void _DeactivateModalAbility(object oCaster, int nAbility)
{
    // remove effects
    Effects_RemoveUpkeepEffect(oCaster, nAbility);
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