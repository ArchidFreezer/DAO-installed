#include "log_h"
#include "abi_templates"
#include "combat_h"
#include "talent_constants_h"
#include "achievement_core_h"
#include "ai_threat_h"
#include "spell_constants_h"

void _ApplySpellEffects(struct EventSpellScriptImpactStruct stEvent, object oTarget)
{
    float fScaledValue;
    effect eEffect;

    switch (stEvent.nAbility)
    {
        case ABILITY_TALENT_DUAL_WEAPON_SWEEP:
        {
            // if not the caster
            if (oTarget != stEvent.oCaster)
            {
                // if the target is not dead and is hostile
                if ((IsDead(oTarget) == FALSE) && (IsObjectHostile(stEvent.oCaster, oTarget) == TRUE))
                {
                    object oMainHand   = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, stEvent.oCaster);
                    object oOffHand    = GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND, stEvent.oCaster);
                    object oWeapon;

                    // get direction to target
                    float fAngle = GetAngleBetweenObjects(stEvent.oCaster, oTarget);
                    #ifdef DEBUG
                    Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName(), "fAngle of " + GetTag(oTarget) + " = " + ToString(fAngle));
                    #endif
                    if ((fAngle >= DUAL_WEAPON_SWEEP_RIGHT_ARC_START) && (fAngle <= 365.0f))
                    {
                        // main hand damage
                        oWeapon = oMainHand;
                    }
                    else if ((fAngle >= -5.0f) && (fAngle <= DUAL_WEAPON_SWEEP_LEFT_ARC_END))
                    {
                        // off hand damage
                        oWeapon = oOffHand;
                    }

                    int bDoubleHit = FALSE;
                    if (fAngle > 310.0f || fAngle < 50.0f)
                    {
                        bDoubleHit = TRUE;
                    }

                    // if target was in an arc
                    if (oWeapon != OBJECT_INVALID)
                    {
                        int nResult = COMBAT_RESULT_HIT;/* (stEvent.oCaster, oTarget, oWeapon, 0.0f, stEvent.nAbility);*/

                        // normal damage
                        float fDamage = Combat_Damage_GetAttackDamage(stEvent.oCaster, oTarget, oWeapon, nResult, 0.0f) * 1.5f;
                        eEffect = EffectImpact(fDamage, oWeapon,0, stEvent.nAbility);
                        Combat_HandleAttackImpact(stEvent.oCaster, oTarget, nResult, eEffect);

                        // If the target is within the hit cone of both weapons, do damage twice
                        if (bDoubleHit)
                        {
                            oWeapon = (oWeapon == oMainHand)?oOffHand: oMainHand;
                            fDamage = Combat_Damage_GetAttackDamage(stEvent.oCaster, oTarget, oWeapon, nResult, 0.0f) * 1.5f;
                            eEffect = EffectImpact(fDamage, oWeapon,0, stEvent.nAbility);
                            Combat_HandleAttackImpact(stEvent.oCaster, oTarget, nResult, eEffect);
                        }
                    }
                }
            }
            break;
        }
    }
}

// Spellscript Impact Damage and Effects
void _ApplyImpactDamageAndEffects(struct EventSpellScriptImpactStruct stEvent)
{
    // only work for sphere spells
    int nAoEType = GetM2DAInt(TABLE_ABILITIES_SPELLS, "aoe_type", stEvent.nAbility);
    if (nAoEType == 1)
    {
        // location impact vfx
        if (stEvent.oTarget != OBJECT_INVALID)
        {
            stEvent.lTarget = GetLocation(stEvent.oTarget);
        }
        Ability_ApplyLocationImpactVFX(stEvent.nAbility, stEvent.lTarget);

        float fRadius = GetM2DAFloat(TABLE_ABILITIES_SPELLS, "aoe_param1", stEvent.nAbility);

        // get objects in area of effect
        object[] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, stEvent.lTarget, fRadius);

        // cycle through objects
        int nCount = 0;
        int nMax = GetArraySize(oTargets);
        for (nCount = 0; nCount < nMax; nCount++)
        {
            // per-spell effects
            _ApplySpellEffects(stEvent, oTargets[nCount]);
        }

        // ------------ <Core Achievements Processing> -------------------
        ACH_ProcessAchievementImpactDamageAndEffects(stEvent, oTargets);
        // ------------ <Core Achievements Processing/> -------------------
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
            // Get a structure with the event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_PENDING", Log_GetAbilityNameById(stEvent.nAbility));
            #endif

            // Setting Return Value
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

            // hand this through to cast_impact
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_IMPACT",Log_GetAbilityNameById(stEvent.nAbility));
            #endif

            // AbiAoEImpact(stEvent.lTarget,  stEvent.oCaster, stEvent.nAbility);
            _ApplyImpactDamageAndEffects(stEvent);

            break;
        }
    }
}