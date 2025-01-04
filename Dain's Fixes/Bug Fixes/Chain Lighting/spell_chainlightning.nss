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

void _ApplyImpactAndFork(object oTarget, object oPropagator, object oOriginalCaster, int nAbility, int nCount)
{
    if (CheckSpellResistance(oTarget, oOriginalCaster, nAbility) == FALSE)
    {
        float fSpellpower = GetCreatureSpellPower(oOriginalCaster);
        float fDamage = 0.20f*(100.0f + fSpellpower)/(Max(nCount, 1));
        //Effects_ApplyInstantEffectDamage(oTarget, oOriginalCaster, fDamage, DAMAGE_TYPE_ELECTRICITY, 0, nAbility);
        effect eEffect = EffectDamage(fDamage, DAMAGE_TYPE_ELECTRICITY);
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oTarget, 0.0f, oOriginalCaster, nAbility);

        // If the projectile has reached 4th generation, abort.
        if (nCount > 3) {
            return;
        }

        // Spawn Secondary lightning at adjusted height
        vector v = GetPosition(oTarget);
        v.z += 0.75*GetHeight(oTarget);

        // Generate the SPELL_SECONDARY_IMPACT event
        event ev = Event(90210);
        ev = SetEventInteger(ev, 0, nAbility);
        ev = SetEventInteger(ev, 1, nCount+1);
        ev = SetEventObject(ev, 0, oTarget);
        ev = SetEventObject(ev, 2, oOriginalCaster);

        // First bounce hits 10 targets, otherwise up to 4 - generation
        int nTargets = (nCount == 0) ? 10 : 4 - nCount;
        object[] arSecTargets = GetNearestObject(oTarget, OBJECT_TYPE_CREATURE, 30, TRUE);
        location lTarget = GetLocation(oTarget);

        int i, nSize = GetArraySize(arSecTargets);
        for (i = 0; i < nSize && nTargets > 0; i++) {
            object oSecTarget = arSecTargets[i];
            if (GetDistanceBetweenLocations(lTarget, GetLocation(oSecTarget)) > 10.0f) {
                break;
            } else if (oSecTarget != oPropagator && IsObjectHostile(oSecTarget, oOriginalCaster) && CheckLineOfSightObject(oSecTarget, oTarget)) {
                object oPrj = FireHomingProjectile(128, v, oSecTarget, 0, oOriginalCaster);
                SetProjectileImpactEvent(oPrj, SetEventObject(ev, 1, oSecTarget));
                nTargets--;
            }
        }
    } else {
        UI_DisplayMessage(oTarget, UI_MESSAGE_RESISTED);
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

        case  90210:
        {
            object oTarget = GetEventObject(ev,1);
            if (IsDeadOrDying(oTarget)) {
                return;
            }
            object oPropagator  = GetEventObject(ev,0);
            int nAbility = GetEventInteger(ev,0);
            int nCount = GetEventInteger(ev, 1);
            object oOriginalCaster = GetEventObject(ev, 2);

            _ApplyImpactAndFork(oTarget, oPropagator, oOriginalCaster, nAbility, nCount);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            //--------------------------------------------------------------
            // Get a structure with the event parameters
            //--------------------------------------------------------------
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            _ApplyImpactAndFork(stEvent.oTarget, stEvent.oCaster, stEvent.oCaster, stEvent.nAbility, 0);

            //------------------------------------------------------------------
            // Tell the targeted creature that it has been cast at
            //------------------------------------------------------------------
            SendEventOnCastAt(stEvent.oTarget,stEvent.oCaster, stEvent.nAbility, TRUE);

            break;

        }
    }
}