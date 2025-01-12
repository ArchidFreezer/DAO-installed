// -----------------------------------------------------------------------------
// ss_dheu_blizzard_overrdie.ncs - Blizzard Override spell script
// -----------------------------------------------------------------------------
/*

*/
// -----------------------------------------------------------------------------
// dheu@gmail.com 2009/12/25
// -----------------------------------------------------------------------------

#include "log_h"
#include "ability_h"
#include "combat_damage_h"
#include "events_h"
#include "spell_constants_h"
#include "plt_cod_aow_spellcombo3" 
#include "ss_dheu_constants_h"

//------------------------------------------------------------------------------
// Spellscript Impact Damage and Effects
//------------------------------------------------------------------------------


void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev); // CAST (directly from engine) or COMMAND_PENDING (re-directed by rules_core)

    switch(nEventType)
    {
        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {
            //PrintToLog("Spell Shaping : EVENT_TYPE_SPELLSCRIPT_CAST (ss_dheu_blizzard_override) caught");

            // Get a structure containing event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + "EVENT_TYPE_SPELLSCRIPT_CAST");

            // Hand through to cast_impact
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);
            break;
        }

        case EVENT_TYPE_ENTER:
        {
            //PrintToLog("Spell Shaping : EVENT_TYPE_ENTER (ss_dheu_blizzard_override) caught");
            int nAbility = GetEventInteger(ev,0);
            object oTarget = GetEventTarget(ev);
            object oCreator = GetEventCreator(ev);

            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "Entering Blizzard: " + ToString(oTarget));
            if (IsObjectValid(oTarget) && GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
            {                
                if (HasAbility(oCreator,IMPROVED_SPELLSHAPING))
                {
                    //PrintToLog("Spell Shaping : EVENT_TYPE_ENTER (ss_dheu_blizzard_override) Has SpellShaping");

                    if (HasAbility(oCreator,MASTER_SPELLSHAPING))
                    {                    
                        // Maybe consider GetHero if oCreator isn't working
                        if (IsObjectHostile(oTarget,oCreator))
                        {
                            if (CheckSpellResistance(oTarget, oCreator, nAbility) == FALSE)
                            {
                                // -------------------------------------------------------------
                                // Slow Effect Resistance Block
                                // -------------------------------------------------------------
                                effect eSlow = EffectModifyMovementSpeed(BLIZZARD_SLOW_FRACTION, TRUE);
                                ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eSlow, oTarget, 0.0f, oCreator, nAbility);

                                // physical resistance
                                if (ResistanceCheck(oCreator, oTarget, PROPERTY_ATTRIBUTE_SPELLPOWER, RESISTANCE_PHYSICAL) == FALSE)
                                {
                                    // slip
                                    effect eSlip = Effect(EFFECT_TYPE_SLIP);
                                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eSlip, oTarget, 0.0f, oCreator, nAbility);
                                }
                            } 
                            else
                            {
                                UI_DisplayMessage(oTarget, UI_MESSAGE_RESISTED);
                            }
                        }
                        // else ignore
                    }
                    else
                    {
                        if (!IsPartyMember(oTarget))
                        {
                            if (CheckSpellResistance(oTarget, oCreator, nAbility) == FALSE)
                            {
                                // -------------------------------------------------------------
                                // Slow Effect Resistance Block
                                // -------------------------------------------------------------
                                effect eSlow = EffectModifyMovementSpeed(BLIZZARD_SLOW_FRACTION, TRUE);
                                ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eSlow, oTarget, 0.0f, oCreator, nAbility);

                                // physical resistance
                                if (ResistanceCheck(oCreator, oTarget, PROPERTY_ATTRIBUTE_SPELLPOWER, RESISTANCE_PHYSICAL) == FALSE)
                                {
                                    // slip
                                    effect eSlip = Effect(EFFECT_TYPE_SLIP);
                                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eSlip, oTarget, 0.0f, oCreator, nAbility);
                                }
                            } 
                            else
                            {
                                UI_DisplayMessage(oTarget, UI_MESSAGE_RESISTED);
                            }
                        }
                        // else ignore
                    }
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
            //PrintToLog("Spell Shaping : EVENT_TYPE_AOE_HEARTBEAT (ss_dheu_blizzard_override) caught");

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
            } 
            else
            {
                object[] a = GetCreaturesInAOE(OBJECT_SELF);

                int nSize = GetArraySize(a);
                int i;

                // ideal total damage divided over the number of intervals
                float fDamage = (100.0f + GetCreatureSpellPower(oCreator)) * BLIZZARD_DAMAGE_FRACTION;

                // note: the effect is cut short when the spell ends.
                float fResult; 
                
                if (HasAbility(oCreator,IMPROVED_SPELLSHAPING))
                {
                    if (HasAbility(oCreator,MASTER_SPELLSHAPING))
                    {
                        for (i = 0; i < nSize; i++)
                        {
                            if (IsObjectValid(a[i]))
                            {
                                if (IsObjectHostile(a[i],oCreator))
                                {
                                    if (CheckSpellResistance(a[i], oCreator, nAbility) == FALSE)
                                    {
                                        // ---------------------------------------------------------
                                        // Apply a short term DOT.
                                        // ----------------------------------------------------------
                                        ApplyEffectDamageOverTime(a[i], oCreator, ABILITY_SPELL_BLIZZARD, fDamage, (BLIZZARD_INTERVAL_DURATION - 0.5f), DAMAGE_TYPE_COLD);
                                        if (nPhase == 3)
                                        {
                                            // physical resistance
                                            if (ResistanceCheck(oCreator, a[i], PROPERTY_ATTRIBUTE_SPELLPOWER, RESISTANCE_PHYSICAL) == FALSE)
                                            {
                                                float fDuration = GetRankAdjustedEffectDuration(a[i], BLIZZARD_FROZEN_DURATION);
                                                effect ep = EffectParalyze(BLIZZARD_FROZEN_VFX);
                                                ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, ep, a[i], fDuration, oCreator, ABILITY_SPELL_BLIZZARD);
                                            }
                                        }
                                    } 
                                    else
                                    {
                                        UI_DisplayMessage(a[i], UI_MESSAGE_RESISTED);
                                    }
                                }
                                // else Ignore
                            }
                        }
                    }
                    else
                    {
                        for (i = 0; i < nSize; i++)
                        {
                            if (IsObjectValid(a[i]))
                            {
                                if (!IsPartyMember(a[i]))
                                {
                                    if (CheckSpellResistance(a[i], oCreator, nAbility) == FALSE)
                                    {
                                        // ---------------------------------------------------------
                                        // Apply a short term DOT.
                                        // ----------------------------------------------------------
                                        ApplyEffectDamageOverTime(a[i], oCreator, ABILITY_SPELL_BLIZZARD, fDamage, (BLIZZARD_INTERVAL_DURATION - 0.5f), DAMAGE_TYPE_COLD);
                                        if (nPhase == 3)
                                        {
                                            // physical resistance
                                            if (ResistanceCheck(oCreator, a[i], PROPERTY_ATTRIBUTE_SPELLPOWER, RESISTANCE_PHYSICAL) == FALSE)
                                            {
                                                float fDuration = GetRankAdjustedEffectDuration(a[i], BLIZZARD_FROZEN_DURATION);
                                                effect ep = EffectParalyze(BLIZZARD_FROZEN_VFX);
                                                ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, ep, a[i], fDuration, oCreator, ABILITY_SPELL_BLIZZARD);
                                            }
                                        }
                                    } 
                                    else
                                    {
                                        UI_DisplayMessage(a[i], UI_MESSAGE_RESISTED);
                                    }
                                }
                                // else ignore
                            }
                        }
                    }
                }
                else
                {
                    // Default (orignial) implementation
                    for (i = 0; i < nSize; i++)
                    {
                        if (CheckSpellResistance(a[i], oCreator, nAbility) == FALSE)
                        {
                            // ---------------------------------------------------------
                            // Apply a short term DOT.
                            // ----------------------------------------------------------
                            ApplyEffectDamageOverTime(a[i], oCreator, ABILITY_SPELL_BLIZZARD, fDamage, (BLIZZARD_INTERVAL_DURATION - 0.5f), DAMAGE_TYPE_COLD);
                            if (nPhase == 3)
                            {
                                // physical resistance
                                if (ResistanceCheck(oCreator, a[i], PROPERTY_ATTRIBUTE_SPELLPOWER, RESISTANCE_PHYSICAL) == FALSE)
                                {
                                    float fDuration = GetRankAdjustedEffectDuration(a[i], BLIZZARD_FROZEN_DURATION);

                                    effect ep = EffectParalyze(BLIZZARD_FROZEN_VFX);

                                    // don't affect party members as badly
                                    if (IsPartyMember(a[i]) == TRUE)
                                    {
                                        ep = EffectModifyMovementSpeed(0.5f);
                                    }

                                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, ep, a[i], fDuration, oCreator, ABILITY_SPELL_BLIZZARD);
                                }
                            }
                        } 
                        else
                        {
                            UI_DisplayMessage(a[i], UI_MESSAGE_RESISTED);
                        }
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
            //PrintToLog("Spell Shaping : EVENT_TYPE_EXIT (ss_dheu_blizzard_override) caught");

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