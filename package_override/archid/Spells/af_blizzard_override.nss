// -----------------------------------------------------------------------------
// Blizzard Override spell script based on code from Dheuster
// This is called in the af_ability_cast_impact event override script to handle the spellshaping ability
// Modified by Archid to reduce code duplication and generally improve readability
// -----------------------------------------------------------------------------

#include "combat_damage_h"
#include "events_h"
#include "spell_constants_h"
#include "plt_cod_aow_spellcombo3"
#include "af_spellshaping_h"
#include "af_logging_h"

// This must match the row in the logging_ m2da table
const int AF_LOG_GROUP = 4;

// First floor of the Tower of Ishal in the prequel
const string AF_AR_PRE_TOWER_ISHAL_1           = "pre410ar_tower_level_1";

//------------------------------------------------------------------------------
// Spellscript Impact Damage and Effects
//------------------------------------------------------------------------------


void main() {
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev); // CAST (directly from engine) or COMMAND_PENDING (re-directed by rules_core)

    switch(nEventType) {
        case EVENT_TYPE_SPELLSCRIPT_CAST: {
            //PrintToLog("Spell Shaping : EVENT_TYPE_SPELLSCRIPT_CAST (ss_dheu_blizzard_override) caught");

            // Get a structure containing event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            afLogInfo("EVENT_TYPE_SPELLSCRIPT_CAST", AF_LOG_GROUP);

            // Hand through to cast_impact
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);
            break;
        }

        case EVENT_TYPE_ENTER: {
            //PrintToLog("Spell Shaping : EVENT_TYPE_ENTER (ss_dheu_blizzard_override) caught");
            int nAbility = GetEventInteger(ev,0);
            object oTarget = GetEventTarget(ev);
            object oCreator = GetEventCreator(ev);

            afLogInfo("Entering Blizzard: " + ToString(oTarget), AF_LOG_GROUP);
            if (IsObjectValid(oTarget) && GetObjectType(oTarget) == OBJECT_TYPE_CREATURE) {
                if (IsSpellShapingTarget(oCreator, oTarget)) {
                    if (!CheckSpellResistance(oTarget, oCreator, nAbility)) {
                        // -------------------------------------------------------------
                        // Slow Effect Resistance Block
                        // -------------------------------------------------------------
                        effect eSlow = EffectModifyMovementSpeed(BLIZZARD_SLOW_FRACTION, TRUE);
                        ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eSlow, oTarget, 0.0f, oCreator, nAbility);

                        // physical resistance for slip
                        if (ResistanceCheck(oCreator, oTarget, PROPERTY_ATTRIBUTE_SPELLPOWER, RESISTANCE_PHYSICAL) == FALSE)
                            ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, Effect(EFFECT_TYPE_SLIP), oTarget, 0.0f, oCreator, nAbility);
                    }
                    else
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

        case EVENT_TYPE_AOE_HEARTBEAT: {
            //PrintToLog("Spell Shaping : EVENT_TYPE_AOE_HEARTBEAT (ss_dheu_blizzard_override) caught");

            int nAbility = GetEventInteger(ev,0);
            int nPhase = GetEventInteger(ev, 1);
            int nGameMode = GetEventInteger(ev, 2);
            object oCreator = GetEventCreator(ev);

            afLogDebug("Blizzard Heartbeat " + ToString(nPhase), AF_LOG_GROUP);

            // if the area is PRE tower 1
            object oArea = GetArea(OBJECT_SELF);
            string sTag = GetTag(oArea);
            int nType;
            afLogDebug("Blizzard Area = " + sTag, AF_LOG_GROUP);

            // Custom code for the first flor of the Tower of Ishal in the prequel
            if (sTag == AF_AR_PRE_TOWER_ISHAL_1) {
                // check for fire barricade VFX in the AoE
                effect[] oVFX = GetEffects(oArea);//GetObjectsInShape(OBJECT_TYPE_VFX, SHAPE_SPHERE, GetLocation(OBJECT_SELF), 20.0f);
                location lAoE = GetLocation(OBJECT_SELF);
                if (IsLocationValid(lAoE))
                    afLogDebug("  AoE location valid.", AF_LOG_GROUP);

                int nMax = GetArraySize(oVFX);
                afLogDebug("  There are " + ToString(nMax) + " VFX present.", AF_LOG_GROUP);
                int nCount = 0;
                for (nCount = 0; nCount < nMax; nCount++)
                {
                    nType = GetEffectType(oVFX[nCount]);
                    sTag = ToString(nType);
                    afLogDebug("  Effect Type in AoE = " + sTag, AF_LOG_GROUP);
                    if (nType == EFFECT_TYPE_VISUAL_EFFECT)
                    {
                        afLogDebug("    Effect is a VFX.", AF_LOG_GROUP);

                        // if the correct vfx type
                        nType = GetVisualEffectID(oVFX[nCount]);
                        afLogDebug("    Effect is ID " + ToString(nType) + " vs " + ToString(VFX_IMMOLATE_NO_CRUST), AF_LOG_GROUP);
                        if (nType == VFX_IMMOLATE_NO_CRUST)
                        {
                            // if close enough
                            location lLoc = GetVisualEffectLocation(oVFX[nCount]);
                            if (IsLocationValid(lLoc))
                                afLogDebug("    VFX location valid.", AF_LOG_GROUP);

                            float fDistance = GetDistanceBetweenLocations(lAoE, lLoc);
                            afLogDebug("      Distance = " + ToString(fDistance), AF_LOG_GROUP);

                            if (fDistance <= 15.0f)
                            {
                                RemoveEffect(oArea, oVFX[nCount]);

                                object[] oSoundSet = GetNearestObjectToLocation(lLoc, OBJECT_TYPE_WAYPOINT);
                                string sVFXTag = GetTag(oSoundSet[0]);
                                afLogDebug("        VFX tag = " + sVFXTag, AF_LOG_GROUP);
                                int nLength = GetStringLength(sVFXTag);
                                string sSoundTag = "emitter_" + ToString(StringToInt(SubString(sVFXTag, nLength - 1, 1)) + 1);
                                afLogDebug("        Sound tag = " + sSoundTag, AF_LOG_GROUP);
                                object oSound = GetObjectByTag(sSoundTag);
                                StopSoundObject(oSound);
                            }
                        }
                    }
                }
            }

            if (nPhase == 0) {
                //Change this to actually supplying the AoE effect...
                SendComboEventAoE(ABILITY_SPELL_BLIZZARD, SHAPE_SPHERE, GetLocation(OBJECT_SELF), oCreator, 10.0f, 0.0f, 0.0f, 1.0f);
            } else {
                object[] oTargets = GetCreaturesInAOE(OBJECT_SELF);

                // ideal total damage divided over the number of intervals
                float fDamage = (100.0f + GetCreatureSpellPower(oCreator)) * BLIZZARD_DAMAGE_FRACTION;

                int i;
                int nSize = GetArraySize(oTargets);
                for (i = 0; i < nSize; i++) {
                    if (IsSpellShapingTarget(oCreator, oTargets[i])) {
                        if (!CheckSpellResistance(oTargets[i], oCreator, nAbility)) {
                            // ---------------------------------------------------------
                            // Apply a short term DOT.
                            // ----------------------------------------------------------
                            ApplyEffectDamageOverTime(oTargets[i], oCreator, ABILITY_SPELL_BLIZZARD, fDamage, (BLIZZARD_INTERVAL_DURATION - 0.5f), DAMAGE_TYPE_COLD);
                            if (nPhase == 3 && !ResistanceCheck(oCreator, oTargets[i], PROPERTY_ATTRIBUTE_SPELLPOWER, RESISTANCE_PHYSICAL)) {
                                float fDuration = GetRankAdjustedEffectDuration(oTargets[i], BLIZZARD_FROZEN_DURATION);
                                // be nice, the player has only just started the game!
                                effect ep = IsPartyMember(oTargets[i]) ? EffectModifyMovementSpeed(0.5f) : EffectParalyze(BLIZZARD_FROZEN_VFX);
                                ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, ep, oTargets[i], fDuration, oCreator, ABILITY_SPELL_BLIZZARD);
                            }
                        } else {
                            UI_DisplayMessage(oTargets[i], UI_MESSAGE_RESISTED);
                        }
                    }
                }
            }

            nPhase ++;
            ev = SetEventInteger(ev, 1, nPhase);
            ev = SetEventInteger(ev, 2, GetGameMode());

            if (nGameMode == GM_COMBAT && GetGameMode() == GM_EXPLORE) {
                Safe_Destroy_Object(OBJECT_SELF);
                // terminate AoEs after 2 ticks in explore mode.
            } else if (IsObjectValid(OBJECT_SELF) ) {
                if (GetObjectType(oCreator) == OBJECT_TYPE_CREATURE && IsDead(oCreator))
                    Safe_Destroy_Object(OBJECT_SELF);
                else
                    DelayEvent(BLIZZARD_INTERVAL_DURATION + 0.05f, OBJECT_SELF, ev); // signal next heartbeat
            }

            break;
        }

        case EVENT_TYPE_EXIT: {
            afLogDebug("Spell Shaping : EVENT_TYPE_EXIT (ss_dheu_blizzard_override) caught", AF_LOG_GROUP);

            int nAbility = GetEventInteger(ev,0);
            object oTarget = GetEventTarget(ev);
            object oCreator = GetEventCreator(ev);

            afLogInfo("Exiting Blizzard: " + ToString(oTarget), AF_LOG_GROUP);
            if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
                RemoveStackingEffects(oTarget, oCreator, nAbility);

            break;
        }
    }
}