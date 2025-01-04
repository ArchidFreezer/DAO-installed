// -----------------------------------------------------------------------------
// spell_blizzard.ncs - Blizzard spell script
// -----------------------------------------------------------------------------
/*

*/
// -----------------------------------------------------------------------------
// georg@2006/11/29
// -----------------------------------------------------------------------------

#include "log_h"
#include "ability_h"
#include "combat_damage_h"
#include "events_h"
#include "spell_constants_h"
#include "plt_cod_aow_spellcombo3"

//------------------------------------------------------------------------------
// Spellscript Impact Damage and Effects
//------------------------------------------------------------------------------
void _ApplyImpactDamageAndEffects(struct EventSpellScriptImpactStruct stEvent)
{

    if (IsObjectValid(stEvent.oTarget))
    {
        stEvent.lTarget = GetLocation(stEvent.oTarget);
    }

    // check for combo effect
    int bCombo = FALSE;

    float fDistance = GetM2DAFloat(TABLE_VFX_PERSISTENT, "RADIUS", STORM_OF_THE_CENTURY_AOE);

    if (IsModalAbilityActive(stEvent.oCaster, ABILITY_SPELL_SPELL_MIGHT) == TRUE)
    {
        // clear all tempests in range
        object[] oTraps = GetObjectsInShape(OBJECT_TYPE_AREAOFEFFECTOBJECT, SHAPE_SPHERE, stEvent.lTarget, fDistance);

        int nCount = 0;
        int nMax = GetArraySize(oTraps);
        for (nCount = 0; nCount < nMax; nCount++)
        {
            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, "AoE " + ToString(nCount) + " = " + GetTag(oTraps[nCount]));
            if (GetTag(oTraps[nCount]) == TEMPEST_TAG)
            {
                bCombo = TRUE;
                DestroyObject(oTraps[nCount]);
            }
        }
    }

    if (bCombo == TRUE)
    {
        // clear all blizzards in range
        object[] oTraps = GetObjectsInShape(OBJECT_TYPE_AREAOFEFFECTOBJECT, SHAPE_SPHERE, stEvent.lTarget, fDistance);

        int nCount = 0;
        int nMax = GetArraySize(oTraps);
        for (nCount = 0; nCount < nMax; nCount++)
        {
            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, "AoE " + ToString(nCount) + " = " + GetTag(oTraps[nCount]));
            if (GetTag(oTraps[nCount]) == BLIZZARD_TAG)
            {
                DestroyObject(oTraps[nCount]);
            }
        }

        stEvent.nAbility = ABILITY_SPELL_STORM_OF_THE_CENTURY;
        effect eAoE = EffectAreaOfEffect(STORM_OF_THE_CENTURY_AOE, SCRIPT_SPELL_AOE_DURATION, STORM_OF_THE_CENTURY_AOE_VFX);
        Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_TEMPORARY, eAoE, stEvent.lTarget, STORM_OF_THE_CENTURY_DURATION, stEvent.oCaster, stEvent.nAbility);

        // additional mana drain
        effect eEffect = EffectModifyManaStamina(STORM_OF_THE_CENTURY_MANA_DRAIN);
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, stEvent.oCaster, 0.0f, stEvent.oCaster, stEvent.nAbility);
        UI_DisplayDamageFloaty(stEvent.oCaster, stEvent.oCaster, FloatToInt(STORM_OF_THE_CENTURY_MANA_DRAIN), stEvent.nAbility, 0, TRUE);

        // combo effect - storm of the century
        if (IsFollower(stEvent.oCaster) == TRUE)
        {
            WR_SetPlotFlag(PLT_COD_AOW_SPELLCOMBO3, COD_AOW_SPELLCOMBO_3_STORM_OF_THE_CENTURY, TRUE);
        }
    } else
    {
        effect eAoE = EffectAreaOfEffect(BLIZZARD_AOE, BLIZZARD_RESOURCE, BLIZZARD_AOE_VFX);
        Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_TEMPORARY, eAoE, stEvent.lTarget, BLIZZARD_DURATION, stEvent.oCaster, stEvent.nAbility);
        Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_TEMPORARY, EffectVisualEffect(BLIZZARD_ICE_SHEET_VFX), stEvent.lTarget, BLIZZARD_DURATION, stEvent.oCaster, stEvent.nAbility);


        // -------------------------------------------------------------------------
        // Demo hack - signal the first hostile creature an oncast at event
        // -------------------------------------------------------------------------
        object[] a = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, stEvent.lTarget, 20.0f);

        int nSize = GetArraySize(a);
        int i;

        for (i = 0; i < nSize; i++)
        {
            if (IsObjectHostile(stEvent.oCaster, a[i]))
            {
                SendEventOnCastAt(a[i], stEvent.oCaster, stEvent.nAbility, TRUE);
            }
        }
    }
}

//------------------------------------------------------------------------------
// Spellscript Heartbeat/Enter secondary effects
//------------------------------------------------------------------------------
void _ApplySecondaryEffects(object oCreator, object oTarget, int nAbility = ABILITY_SPELL_BLIZZARD)
{
    // 75% nothing, 12.5% slip, 12.5% freeze
    int r = Random(8);
    if (r < 2)
    {
        if (ResistanceCheck(oCreator, oTarget, PROPERTY_ATTRIBUTE_SPELLPOWER, RESISTANCE_PHYSICAL) == FALSE)
        {
            if (r == 1)
            {
                effect eEffect = Effect(EFFECT_TYPE_SLIP);
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oTarget, 0.0f, oCreator, nAbility);
            }
            else
            {
                float fDuration = GetRankAdjustedEffectDuration(oTarget, BLIZZARD_FROZEN_DURATION);

                // frozen
                effect eEffect = EffectParalyze(BLIZZARD_FROZEN_VFX);
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTarget, fDuration, oCreator, nAbility);

                // petrify
                eEffect = Effect(EFFECT_TYPE_PETRIFY);
                eEffect = SetEffectInteger(eEffect, 0, 0);
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTarget, fDuration, oCreator, nAbility);
            }
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

            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + "EVENT_TYPE_SPELLSCRIPT_PENDING");

            // Setting return value
            Ability_SetSpellscriptPendingEventResult(COMMAND_RESULT_SUCCESS);
            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {
            // Get a structure containing event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + "EVENT_TYPE_SPELLSCRIPT_CAST");

            // Hand through to cast_impact
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);
            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            // Get structure containing event parameters
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + "EVENT_TYPE_SPELLSCRIPT_IMPACT");

            _ApplyImpactDamageAndEffects(stEvent);
            break;
        }

        case EVENT_TYPE_ENTER:
        {
            int nAbility = GetEventInteger(ev,0);
            object oTarget = GetEventTarget(ev);
            object oCreator = GetEventCreator(ev);

            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "Entering Blizzard: " + ToString(oTarget));
            if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
            {
                if (CheckSpellResistance(oTarget, oCreator, nAbility) == FALSE)
                {
                    // -------------------------------------------------------------
                    // Slow Effect Resistance Block
                    // -------------------------------------------------------------
                   effect eSlow = EffectModifyMovementSpeed(BLIZZARD_SLOW_FRACTION, TRUE);
                   ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eSlow, oTarget, 0.0f, oCreator, nAbility);

                   // Apply freeze/slip
                   _ApplySecondaryEffects(oCreator, oTarget, nAbility);
                } else
                {
                    UI_DisplayMessage(oTarget, UI_MESSAGE_RESISTED);
                }

               // ------------------------------------------------------
               // +50% fire resistance
               // ------------------------------------------------------
               effect eResists = EffectModifyProperty(PROPERTY_ATTRIBUTE_DAMAGE_RESISTANCE_FIRE, BLIZZARD_FIRE_RESISTANCE_BONUS);
               ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eResists, oTarget, 0.0f, oCreator, nAbility);

               // ------------------------------------------------------
               // +10 points of defense while in blizzard.
               // ------------------------------------------------------
               effect eDefense = EffectModifyProperty(PROPERTY_ATTRIBUTE_DEFENSE, BLIZZARD_DEFENSE_BONUS);
               ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eDefense, oTarget, 0.0f, oCreator, nAbility);

               SendEventOnCastAt(oTarget, OBJECT_SELF, ABILITY_SPELL_BLIZZARD);
            }

            break;
        }

        case EVENT_TYPE_AOE_HEARTBEAT:
        {
            int nAbility = GetEventInteger(ev,0);
            int nPhase = GetEventInteger(ev, 1);
            int nGameMode = GetEventInteger(ev, 2);
            object oCreator = GetEventCreator(ev);


            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "Blizzard Heartbeat " + ToString(nPhase));

            // if the area is PRE tower 1
            object oArea = GetArea(OBJECT_SELF);
            string sTag = GetTag(oArea);
            int nType;
            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "Blizzard Area = " + sTag);
            if (sTag == "pre410ar_tower_level_1")
            {
                // check for fire barricade VFX in the AoE
                effect[] oVFX = GetEffects(oArea);//GetObjectsInShape(OBJECT_TYPE_VFX, SHAPE_SPHERE, GetLocation(OBJECT_SELF), 20.0f);
                int nCount = 0;
                int nMax = GetArraySize(oVFX);
                location lAoE = GetLocation(OBJECT_SELF);
                if (IsLocationValid(lAoE) == TRUE)
                {
                    Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "  AoE location valid.");
                }
                location lLoc;
                float fDistance;
                object[] oSoundSet;
                int nSoundCount;
                int nSoundMax;
                string sSoundTag;
                float fSoundDistance;
                Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "  There are " + ToString(nMax) + " VFX present.");
                for (nCount = 0; nCount < nMax; nCount++)
                {
                    nType = GetEffectType(oVFX[nCount]);
                    sTag = ToString(nType);
                    Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "  Effect Type in AoE = " + sTag);
                    if (nType == EFFECT_TYPE_VISUAL_EFFECT)
                    {
                        Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "    Effect is a VFX.");

                        // if the correct vfx type
                        nType = GetVisualEffectID(oVFX[nCount]);
                        Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "    Effect is ID " + ToString(nType) + " vs " + ToString(VFX_IMMOLATE_NO_CRUST));
                        if (nType == VFX_IMMOLATE_NO_CRUST)
                        {
                            // if close enough
                            lLoc = GetVisualEffectLocation(oVFX[nCount]);
                            if (IsLocationValid(lLoc) == TRUE)
                            {
                                Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "    VFX location valid.");
                            }
                            fDistance = GetDistanceBetweenLocations(lAoE, lLoc);
                            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "      Distance = " + ToString(fDistance));

                            if (fDistance <= 15.0f)
                            {
                                RemoveEffect(oArea, oVFX[nCount]);

                                oSoundSet = GetNearestObjectToLocation(lLoc, OBJECT_TYPE_WAYPOINT);
                                string sVFXTag = GetTag(oSoundSet[0]);
                                Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "        VFX tag = " + sVFXTag);
                                int nLength = GetStringLength(sVFXTag);
                                string sSoundTag = "emitter_" + ToString(StringToInt(SubString(sVFXTag, nLength - 1, 1)) + 1);
                                Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "        Sound tag = " + sSoundTag);
                                object oSound = GetObjectByTag(sSoundTag);
                                StopSoundObject(oSound);
/*
                                // disable sound emitter closest to it
                                oSoundSet = GetObjectsInShape(OBJECT_TYPE_SOUND, SHAPE_SPHERE, lLoc, 5.0f);
                                nSoundCount = 0;
                                nSoundMax = GetArraySize(oSoundSet);
                                Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "      Sounds in Range = " + ToString(nSoundMax));
                                for (nSoundCount = 0; nSoundCount < nSoundMax; nSoundCount++)
                                {
                                    sSoundTag = GetTag(oSoundSet[nSoundCount]);
                                    fSoundDistance = GetDistanceBetweenLocations(lLoc, GetLocation(oSoundSet[nSoundCount]));
                                    Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "        Sound " + ToString(nSoundCount) + " = " + sSoundTag + " at " + ToString(fSoundDistance));
                                }
                                */
                            }
                        }
                    }
                }
            }
            //

            if (nPhase == 0)
            {
                //Change this to actually supplying the AoE effect...
                SendComboEventAoE(ABILITY_SPELL_BLIZZARD, SHAPE_SPHERE, GetLocation(OBJECT_SELF), oCreator, 10.0f, 0.0f, 0.0f, 1.0f);
            } else
            {
                object[] a = GetCreaturesInAOE(OBJECT_SELF);

                int nSize = GetArraySize(a);
                int i;

                // ideal total damage divided over the number of intervals
                float fDamage = (100.0f + GetCreatureSpellPower(oCreator)) * BLIZZARD_DAMAGE_FRACTION;

                // note: the effect is cut short when the spell ends.
                float fResult;
                for (i = 0; i < nSize; i++)
                {
                    if (CheckSpellResistance(a[i], oCreator, nAbility) == FALSE)
                    {
                        // ---------------------------------------------------------
                        // Apply a short term DOT.
                        // ----------------------------------------------------------
                        ApplyEffectDamageOverTime(a[i], oCreator, ABILITY_SPELL_BLIZZARD, fDamage, (BLIZZARD_INTERVAL_DURATION - 0.5f), DAMAGE_TYPE_COLD);
    //                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eDamage, a[i], 0.0f, oCreator, nAbility);

                        // Apply freeze/slip
                        _ApplySecondaryEffects(oCreator, a[i], nAbility);
                    } else
                    {
                        UI_DisplayMessage(a[i], UI_MESSAGE_RESISTED);
                    }
                }

            }

            nPhase ++;
            ev = SetEventInteger(ev, 1, nPhase);
            ev = SetEventInteger(ev, 2, GetGameMode());

            if (nGameMode == GM_COMBAT && GetGameMode() == GM_EXPLORE)
            {
                Safe_Destroy_Object(OBJECT_SELF);
                // terminate AoEs after 2 ticks in explore mode.
            }
            else
            {
                if (IsObjectValid(OBJECT_SELF) )
                {

                    if (GetObjectType(oCreator) == OBJECT_TYPE_CREATURE && IsDead(oCreator))
                    {
                        Safe_Destroy_Object(OBJECT_SELF);
                    }
                    else
                    {
                        // signal next heartbeat
                        DelayEvent(BLIZZARD_INTERVAL_DURATION + 0.05f, OBJECT_SELF, ev);
                    }
                }
            }

            break;
        }

        case EVENT_TYPE_EXIT:
        {
            int nAbility = GetEventInteger(ev,0);
            object oTarget = GetEventTarget(ev);
            object oCreator = GetEventCreator(ev);

            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "Exiting Blizzard: " + ToString(oTarget));
            if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
            {
                RemoveStackingEffects(oTarget, oCreator, nAbility);

            }
            break;
        }
    }
}