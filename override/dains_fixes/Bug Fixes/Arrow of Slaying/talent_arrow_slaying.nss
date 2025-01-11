// -------------------------------------\---------------------------------------
// talent_arrow_slaying
// -----------------------------------------------------------------------------
/*



*/
// -----------------------------------------------------------------------------
// georg
// -----------------------------------------------------------------------------


#include "log_h"
#include "ability_h"

#include "combat_h"

#include "talent_constants_h"

/** ------------------------------------------------------------------------------
*  @brief Spellscript Cast Damage and Effects (for direct attacks with damage handled
*  by rules core)
*
*  @returns Damage inflicted
*  @author Georg Zoeller
------------------------------------------------------------------------------**/


//------------------------------------------------------------------------------
// Spellscript Impact Damage and Effects
//------------------------------------------------------------------------------
void _ApplyImpactDamageAndEffects(struct EventSpellScriptImpactStruct stEvent)
{
    float fAttackBonus = ARROW_OF_SLAYING_ATTACK_BONUS;
    if (HasAbility(stEvent.oCaster, ABILITY_TALENT_MASTER_ARCHER) == TRUE)
    {
        fAttackBonus += MASTER_ARCHER_ARROW_OF_SLAYING_ATTACK_BONUS;
    }

    object oWeapon  = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, stEvent.oCaster);
    int nResult     = Combat_GetAttackResult(stEvent.oCaster, stEvent.oTarget, oWeapon, fAttackBonus);
    if (IsCombatHit(nResult) == TRUE)
    {
        // always crit;
        if (nResult == COMBAT_RESULT_HIT)
        {
            nResult = COMBAT_RESULT_CRITICALHIT;
        }

        // *2 crit damage is default.
        float fDamage   = Combat_Damage_GetAttackDamage(stEvent.oCaster, stEvent.oTarget, oWeapon, nResult, 0.0, TRUE) * 2.0;

        // bonus damage if at least equal level.
        int nDifference = GetLevel(stEvent.oCaster) - GetLevel(stEvent.oTarget);
        if (nDifference > 0)
        {
            // elite bosses are immune to this
            int nRank = GetCreatureRank(stEvent.oTarget);
            if (nRank != CREATURE_RANK_ELITE_BOSS)
            {
                // bosses and players take reduced damage
                if (nRank == CREATURE_RANK_BOSS || nRank == CREATURE_RANK_PLAYER)
                {
                    float fBase = ARROW_OF_SLAYING_DAMAGE_BASE * pow(IntToFloat(nDifference),2.0f);
                    float fBonus = RandFF(fBase, fBase);
                    fBonus *= ARROW_OF_SLAYING_BOSS_DAMAGE_FACTOR;
                    fDamage += fBonus;
                }
                // Instant kill on elite and lower
                else
                {
                    float fCurrentHealth = GetCurrentHealth(stEvent.oTarget);
                    fDamage = fCurrentHealth + 1.0f;
                }
            }
        }

        // impact effect
        effect eImpactEffect = EffectImpact(fDamage, oWeapon, Ability_GetImpactObjectVfxId(stEvent.nAbility), stEvent.nAbility);
        Combat_HandleAttackImpact(stEvent.oCaster, stEvent.oTarget, nResult, eImpactEffect);

        // Character stamina regen slowed by 1.0 for 10 seconds.
        effect eStrain = EffectDecreaseProperty(PROPERTY_ATTRIBUTE_REGENERATION_STAMINA, ARROW_OF_SLAYING_REGENERATION_PENALTY,
                                          PROPERTY_ATTRIBUTE_REGENERATION_STAMINA_COMBAT, ARROW_OF_SLAYING_REGENERATION_PENALTY);
        eStrain = SetEffectEngineInteger(eStrain, EFFECT_INTEGER_VFX, ARROW_OF_SLAYING_CASTER_VFX);
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eStrain, stEvent.oCaster, ARROW_OF_SLAYING_REGENERATION_PENALTY_DURATION, stEvent.oCaster, stEvent.nAbility);

    }



  }




//------------------------------------------------------------------------------
// Spellscript Main, initiated from ability_core.nss
//------------------------------------------------------------------------------
void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev); // CAST (directly from engine) or COMMAND_PENDING (re-directed by rules_core)

    switch(nEventType)
    {


        //----------------------------------------------------------------------
        // This event fires out of ability_core.nss as a reaction to a
        // EVENT_TYPE_COMMAND_PENDING Event.
        //
        // It is used to
        //      - Handle Toggling of Modal Abilities
        //      - Handle Success or failure of reaction (anim) based abilities
        //----------------------------------------------------------------------

        case EVENT_TYPE_SPELLSCRIPT_PENDING:
        {
            //--------------------------------------------------------------
            // Get a structure with the event parameters
            //--------------------------------------------------------------
            struct EventSpellScriptPendingStruct stEvent = Events_GetEventSpellScriptPendingParameters(ev);

            //--------------------------------------------------------------
            // Setting Return Value
            //--------------------------------------------------------------
            Ability_SetSpellscriptPendingEventResult(COMMAND_RESULT_SUCCESS);


            break;

        }


        //----------------------------------------------------------------------
        // This event fires out of ability_core.nss as a reaction to a
        // EVENT_TYPE_CAST_START Event.
        //
        // It is used to
        //      - Calculate and set damage for animation based abilities
        //      - Fire specific effects (such as shield bash knockdown)
        //  - Toggle On Modal Abilities
        //----------------------------------------------------------------------

        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {

            //--------------------------------------------------------------
            // Get a structure with the event parameters
            //--------------------------------------------------------------
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);



            //--------------------------------------------------------------
            // Apply evil looking vfx on archer...
            //--------------------------------------------------------------
            ApplyEffectVisualEffect(stEvent.oCaster, stEvent.oCaster, ARROW_OF_SLAYING_CASTER_VFX, EFFECT_DURATION_TYPE_TEMPORARY, 4.5f, stEvent.nAbility);


            // -------------------------------------------------------------
            // Message the Attack result back to the engine
            // -------------------------------------------------------------
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);

            break;

        }


        //----------------------------------------------------------------------
        // This event fires out of ability_core.nss as a reaction to a
        // EVENT_TYPE_CAST_IMPACT Event.
        //
        // It is used to
        //      - Apply damage
        //      - Apply Visual Effects
        //  - Resolve other spell effects
        //----------------------------------------------------------------------

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            //--------------------------------------------------------------
            // Get a structure with the event parameters
            //--------------------------------------------------------------
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);



            RemoveStackingEffects(stEvent.oCaster, stEvent.oCaster, stEvent.nAbility);

            _ApplyImpactDamageAndEffects(stEvent);


            //------------------------------------------------------------------
            // Tell the targeted creature that it has been cast at
            //------------------------------------------------------------------
            SendEventOnCastAt(stEvent.oTarget,stEvent.oCaster, stEvent.nAbility, TRUE);

            break;

        }
    }
}