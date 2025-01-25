/*
* Code taken from Daimbramage - Dain's Fixes mod
*
* Scattershot talent override
*/
// -------------------------------------\---------------------------------------
// talent_scattershot
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
void _ApplyImpactDamageAndEffects(object oCaster, object oTarget, int nAbility, int bInitial, object oWeapon)
{

    // if attack hits
     int nResult = Combat_GetAttackResult(oCaster, oTarget, oWeapon, 0.0f, nAbility);
     if (nResult == COMBAT_RESULT_MISS)
     {
        nResult = COMBAT_RESULT_HIT;
     }

     float fDamage = Combat_Damage_GetAttackDamage(oCaster, oTarget, oWeapon, nResult);
     effect eEffect = EffectImpact(fDamage, oWeapon, 0, ABILITY_TALENT_SCATTERSHOT );
     Combat_HandleAttackImpact(oCaster, oTarget, nResult, eEffect);


     float fDuration = GetRankAdjustedEffectDuration(oTarget, 2.0f);

     // remove stacking effects
     RemoveStackingEffects(oTarget, oCaster, nAbility);

     effect eK = EffectStun();
     ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eK, oTarget, fDuration, oCaster, nAbility);
     DamageCreature(oTarget, oCaster, 15.0 , DAMAGE_TYPE_PHYSICAL);

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

        case  90210 /*the bad event*/:
        {

            object oTarget = GetEventObject(ev,1);
            object oCaster  = GetEventObject(ev,0);
            int nAbility = GetEventInteger(ev,0);
            object oWeapon = GetEventObject(ev,3);
            object oOriginalCaster  = GetEventObject(ev, 2);


            _ApplyImpactDamageAndEffects(oOriginalCaster, oTarget, nAbility,FALSE, oWeapon);



            break;


        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            //--------------------------------------------------------------
            // Get a structure with the event parameters
            //--------------------------------------------------------------
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);


            object oWeapon = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, stEvent.oCaster);

            object[] secondaryTargets = GetHostileObjectsInRadius(stEvent.oTarget, stEvent.oCaster, OBJECT_TYPE_CREATURE,15.0f);
            int nSize = GetArraySize(secondaryTargets);
            int i;
            int nObstructed = 0;
            int nCap = Min(5 + FloatToInt(GetCreatureSpellPower(stEvent.oCaster)/10.0f), 10);

            for (i = 0; i < nSize && i < (10 + nObstructed); i++)
            {
                if (secondaryTargets[i] != stEvent.oCaster && !IsDead(secondaryTargets[i]) && secondaryTargets[i] != stEvent.oTarget )
                {

                    if (CheckLineOfSightObject(stEvent.oTarget,secondaryTargets[i]))
                    {
                        object oPrj = FireHomingProjectile(1, GetPosition(stEvent.oTarget), secondaryTargets[i], 1067,  stEvent.oCaster);

                        event ev = Event(90210);
                        ev = SetEventInteger(ev, 0, stEvent.nAbility);
                        ev = SetEventObject(ev, 0, stEvent.oCaster); // used to be oTarget
                        ev = SetEventObject(ev, 1, secondaryTargets[i]);
                        ev = SetEventObject(ev, 2, stEvent.oCaster);
                        ev = SetEventObject(ev, 3, oWeapon);

                        SetProjectileImpactEvent(oPrj, ev);




                    } else
                    {
                        nObstructed++;
                    }
                } else
                {
                    nObstructed++;
                }

            }
            _ApplyImpactDamageAndEffects(stEvent.oCaster, stEvent.oTarget, stEvent.nAbility,TRUE, oWeapon);



            //------------------------------------------------------------------
            // Tell the targeted creature that it has been cast at
            //------------------------------------------------------------------
            SendEventOnCastAt(stEvent.oTarget,stEvent.oCaster, stEvent.nAbility, TRUE);

            break;

        }
    }
}