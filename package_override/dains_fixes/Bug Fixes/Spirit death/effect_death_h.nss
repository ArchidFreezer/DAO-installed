// -----------------------------------------------------------------------------
// Owner: Georg Zoeller
// -----------------------------------------------------------------------------

#include "log_h"
#include "core_h"
#include "2da_constants_h"
//#include "wrappers_h"
#include "events_h"
#include "effect_constants_h"
#include "achievement_core_h"
#include "stats_core_h"
/** ----------------------------------------------------------------------------
* @brief Returns an effect which kills a creature.
*
* Constructor for the death effect. When applied to a creature, this effect
* instantly kills the creature. If the creature is flagged as plot or immortal
* then this effect will do nothing.
*
* @author Georg Zoeller
*
* @param bForceDeath - Force death regardless of death status. Used only OnSpawn
*
* @return a valid effect of type EFFECT_TYPE_DEATH
*
/
------------------------------------------------------------------------------*/

effect EffectDeath(int bForceDeath = 0);
effect EffectDeath(int bForceDeath = 0)
{
    effect eEffect = Effect(EFFECT_TYPE_DEATH);
    eEffect = SetEffectInteger(eEffect, 0, 1);
    return eEffect;
}


// -----------------------------------------------------------------------------
// This utility function handles the application of the effect and
// should never be called directly except in Effects_h
// -----------------------------------------------------------------------------
int Effects_HandleApplyEffectDeath(effect eEffect, object oContext = OBJECT_SELF)
{
    object oTarget = oContext;
    object oKiller = GetEffectCreator(eEffect);
    command pAnimationCommand;
    int nType = GetObjectType (oTarget);

    int bReturn = FALSE;


    // -------------------------------------------------------------------------
    // NOTE: IsDead is actually an engine check that checks if the creature
    // has 0 HP or lower - it is no real flag.
    // -------------------------------------------------------------------------
    if ((IsPlot(oTarget) == FALSE) && (IsImmortal(oTarget) == FALSE))
    {

        // ---------------------------------------------------------------------
        // PLC Death
        // ---------------------------------------------------------------------
        if (nType == OBJECT_TYPE_PLACEABLE)
        {

            // -----------------------------------------------------------------
            // Sent the OnDeathEvent to the target
            // -----------------------------------------------------------------
            SendEventOnDeath(oTarget, oKiller);

            // -----------------------------------------------------------------
            // Actually killing the target (by setting Health to 0)
            // -----------------------------------------------------------------
            SetPlaceableHealth(oTarget, 0); // Same as setting target to being 'dead'
        }
        // ---------------------------------------------------------------------
        // Creature Death
        // ---------------------------------------------------------------------
        else if (nType == OBJECT_TYPE_CREATURE)
        {

            if(HasDeathEffect(oTarget))
                 return FALSE;
            //if (GetCreatureFlag(oTarget,CREATURE_RULES_FLAG_DYING))
            //{
            //    Log_Trace(LOG_CHANNEL_COMBAT_DEATH, "effect_death_h", "Not killing already dying creature", oTarget);
            //    return FALSE;
            //}

            bReturn = TRUE;

            // -----------------------------------------------------------------
            // NOTE: the death reaction for synched death (death blow) is handled
            // during the Rules_CalculateDamage function. This is needed because
            // synched reactions must be played immediately, but any other reaction
            // can be waited for the death effect to handle it.
            // -----------------------------------------------------------------

            SetCreatureFlag(oTarget,CREATURE_RULES_FLAG_DYING,TRUE);

            // remove all effects applied ON me
            Effects_RemoveAllEffects(oTarget,TRUE, TRUE);

            // -----------------------------------------------------------------
            // <Achievement entry point>
            // -----------------------------------------------------------------
            ACH_HandleDeathEffect(oTarget, oKiller, eEffect);
            // -----------------------------------------------------------------
            // <Achievement entry point/>
            // -----------------------------------------------------------------

            // Stats - count party kills
            STATS_HandlePartyKills(oKiller, oTarget);

            // Stats - handle "most powerful slain"
            STATS_TrackMostPowerfulSlain(oKiller, oTarget);

            // Stats - handle "number of creatures of type killed"
            STATS_CountKillsByGroupType(oKiller, oTarget);

            // -----------------------------------------------------------------
            // Slayers with the death blow talent gain 15% of enemy health back in mana
            // -----------------------------------------------------------------
            if (IsObjectValid(oKiller) && (HasAbility(oKiller, ABILITY_TALENT_DEATH_BLOW)))
            {
                //float fMana     = GetCreatureProperty(oKiller, PROPERTY_DEPLETABLE_MANA_STAMINA);
                float fRestore  = GetCreatureProperty(oTarget, PROPERTY_DEPLETABLE_HEALTH, PROPERTY_VALUE_BASE) * 0.2;
                UpdateCreatureProperty(oKiller, PROPERTY_DEPLETABLE_MANA_STAMINA, fRestore, PROPERTY_VALUE_CURRENT);
                ApplyEffectVisualEffect(oKiller, oKiller, 90184, EFFECT_DURATION_TYPE_INSTANT, 0.0f);
            }

            // (Georg) Ghosts just avoid the whole chain and disintegrate right away
            if (HasAbility(oTarget,ABILITY_TRAIT_GHOST))
            {
                SendEventDying(oTarget, oKiller);
                ApplyEffectVisualEffect(oTarget, oTarget, VFX_IMP_DEATH, EFFECT_DURATION_TYPE_INSTANT, 0.0f);
                SendEventOnDeath(oTarget, oKiller);
            } else {
                SetCreatureProperty(oTarget, PROPERTY_DEPLETABLE_MANA_STAMINA, 0.0f, PROPERTY_VALUE_CURRENT);
                SendEventDying(oTarget, oKiller);
            }
        }
    }

    return bReturn;
}

// -----------------------------------------------------------------------------
// This utility function handles the removal of the effect and
// should never be called directly except in Effects_h
// -----------------------------------------------------------------------------
int Effects_HandleRemoveEffectDeath(effect eEffect)
{
    return TRUE;
}

/** @brief (effect_death_h) Kills a creature.
*
* Kills a creature by creating and applying a death effect.
* - Does nothing if applied to an already dead creature.
* - Does nothing on immortal or plot flagged creatures
*
* @param oTarget    - The unfortunate creature to die.
* @param oKiller    - The killer (OBJECT_INVALID for creatures killed by plot).
* @param nAbilityId - If used from an ability script, pass in stEvent.nAbility.
*/
void KillCreature(object oVictim, object oKiller = OBJECT_INVALID, int nAbilityId = 0, int bProcessInline = FALSE, int nDamage = 0);
void KillCreature(object oVictim, object oKiller = OBJECT_INVALID, int nAbilityId = 0, int bProcessInline = FALSE, int nDamage = 0)
{

    Log_Trace(LOG_CHANNEL_COMBAT_DEATH, "effect_death_h.KillCreature","victim:" + ToString(oVictim) + ", killer: " + ToString(oKiller));

    if (IsObjectValid(oVictim) && GetObjectType(oVictim) == OBJECT_TYPE_CREATURE)
    {
        if (!IsDead(oVictim))
        {
            if (!IsPlot(oVictim) && !IsImmortal(oVictim))
            {

                effect eDeath = EffectDeath();
                eDeath = SetEffectCreator(eDeath, oKiller);
                eDeath = SetEffectAbilityID(eDeath, nAbilityId);
                // This introduced a bug with death animations. We are temporarily commenting it out (Jose)
                eDeath = SetEffectInteger(eDeath, ACH_EFFECT_DEATH_DAMAGE_INDEX , nDamage);    // EffectDeath already records information on Integer Index 0, so we use Integer Index 1 to store the damage.
//                Effects_HandleApplyEffectDeath(eDeath, oVictim);
                if (!bProcessInline)
                {
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_DEATH, eDeath, oVictim, 0.0f, oKiller, nAbilityId);
                }
                else
                {
                    Effects_HandleApplyEffectDeath(eDeath, oVictim);
                }
            }
        }
    }
}

/** @brief (effect_death_h) Destroys a placeable
*
* Destroys a placeable by creating and applying a death effect.
* - Does nothing if applied to an already dead destroyed object.
* - Does nothing on immortal or plot flagged objects
*
* @param oPlaceable  - The placeable to be destroyed
* @param oDestroyer  - The killer (OBJECT_INVALID for creatures killed by plot).
* @param nAbilityId  - If used from an ability script, pass in stEvent.nAbility.
*/
void DestroyPlaceable(object oPlaceable, object oDestroyer = OBJECT_INVALID, int nAbilityId = 0);
void DestroyPlaceable(object oPlaceable, object oDestroyer = OBJECT_INVALID, int nAbilityId = 0)
{
    if (IsObjectValid(oPlaceable) && GetObjectType(oPlaceable) == OBJECT_TYPE_PLACEABLE)
    {
        if (!IsDead(oPlaceable))
        {
            if (!IsPlot(oPlaceable) && !IsImmortal(oPlaceable))
            {
                effect eDeath = EffectDeath();
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT,eDeath, oPlaceable, 0.0f, oDestroyer, nAbilityId);

                //SetPlaceableActionResult(oPlaceable, PLACEABLE_ACTION_DESTROY, TRUE);
            }
        }
    }
}