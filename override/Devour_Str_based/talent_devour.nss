// -----------------------------------------------------------------------------
// spell_aoe_instant
// -----------------------------------------------------------------------------
/*
    Script for Area of Effect spells that have an instant effect.
*/
// -----------------------------------------------------------------------------
// petert
// -----------------------------------------------------------------------------

#include "log_h"
#include "abi_templates"
#include "combat_h"
#include "talent_constants_h"

const int DEVOUR_PROJECTILE = 104;
const resource SCRIPT_SPELL_DEATH_MAGIC = R"talent_devour.ncs";

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

            // location impact vfx
            if (stEvent.oTarget != OBJECT_INVALID)
            {
                stEvent.lTarget = GetLocation(stEvent.oTarget);
            }

            float fRadius = GetM2DAFloat(TABLE_ABILITIES_SPELLS, "aoe_param1", stEvent.nAbility);

            // get objects in area of effect
            object[] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, stEvent.lTarget, fRadius);

            // cycle through objects
            int nCount = 0;
            int nMax = GetArraySize(oTargets);
            effect eEffect;
            object oBag;
            int nAppearance;
            int nDecayBehaviour;
            for (nCount = 0; nCount < nMax; nCount++)
            {
                #ifdef DEBUG
                LogTrace(LOG_CHANNEL_COMBAT_ABILITY, "  Object " + ToString(nCount) + " = " + GetTag(oTargets[nCount]));
                #endif
                if (HasDeathEffect(oTargets[nCount], TRUE) == TRUE)
                {
                    #ifdef DEBUG
                    LogTrace(LOG_CHANNEL_COMBAT_ABILITY, "    Is dead");
                    #endif

                    if (IsPlot(oTargets[nCount]) == FALSE)
                    {
                        #ifdef DEBUG
                        LogTrace(LOG_CHANNEL_COMBAT_ABILITY, "    Is not plot");
                        #endif

                        if (GetCanDiePermanently(oTargets[nCount]) == TRUE)
                        {
                            #ifdef DEBUG
                            LogTrace(LOG_CHANNEL_COMBAT_ABILITY, "    Can die permanently");
                            #endif

                            nAppearance = GetAppearanceType(oTargets[nCount]);
                            nDecayBehaviour = GetM2DAInt(TABLE_APPEARANCE, "DecayBehaviour", nAppearance);
                            #ifdef DEBUG
                            LogTrace(LOG_CHANNEL_COMBAT_ABILITY, "    nAppearance " + ToString(nAppearance) + " with nDecayBehaviour " + ToString(nDecayBehaviour));
                            #endif
                            if (nDecayBehaviour == 0)
                            {
                                eEffect = EffectVisualEffect(Ability_GetImpactObjectVfxId(stEvent.nAbility));
                                ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oTargets[nCount], 0.0f, stEvent.oCaster, stEvent.nAbility);

                                // create event
                                event ev = Event(90210);
                                ev = SetEventInteger(ev, 0, stEvent.nAbility);
                                ev = SetEventObject(ev, 0, stEvent.oCaster);
                                ev = SetEventObject(ev, 1, stEvent.oCaster);

                                // fire projectile
                                vector v = GetPosition(oTargets[nCount]);
                                object oProjectile = FireHomingProjectile(DEVOUR_PROJECTILE, v, stEvent.oCaster, 0,  stEvent.oCaster);
                                SetProjectileImpactEvent(oProjectile, ev);

                                // get body bag
                                oBag = GetCreatureBodyBag(oTargets[nCount]);
                                #ifdef DEBUG
                                LogTrace(LOG_CHANNEL_COMBAT_ABILITY, "    Old Bag = " + GetTag(oBag));
                                #endif

                                // if a bodybag already exists
                                if (IsObjectValid(oBag) == TRUE)
                                {
                                    // degrade body
                                    SetBodybagDecayDelay(oBag, 0);
                                } else
                                {
                                    // create one
                                    SpawnBodyBag(oTargets[nCount], TRUE);
                                    oBag = GetCreatureBodyBag(oTargets[nCount]);
                                    #ifdef DEBUG
                                    LogTrace(LOG_CHANNEL_COMBAT_ABILITY, "    New Bag = " + GetTag(oBag));
                                    #endif
                                    if (IsObjectValid(oBag) == TRUE)
                                    {
                                        // if it doesn't have a real corpse model
                                        int nAppearance = GetAppearanceType(oTargets[nCount]);
                                        if (GetM2DAString(TABLE_APPEARANCE, "CorpseModel", nAppearance) == "plc_bagcoin03_0")
                                        {
                                            int nCreatureType = GetM2DAInt(TABLE_APPEARANCE, "CREATURE_TYPE", nAppearance);
                                            resource rItem;
                                            int nStackSize = 1;
                                            if (nCreatureType == CREATURE_TYPE_UNDEAD)
                                            {
                                                rItem = R"gen_im_cft_reg_spiritshard.uti";
                                            } else if (nCreatureType == CREATURE_TYPE_DEMON)
                                            {
                                                rItem = R"gen_im_cft_reg_demonicichor.uti";
                                            } else if (nCreatureType == CREATURE_TYPE_GOLEM)
                                            {
                                                rItem = R"gen_im_cft_reg_lightning.uti";
                                            } else if (nCreatureType == CREATURE_TYPE_HUMANOID)
                                            {
                                                rItem = R"gen_im_cft_reg_elfroot.uti";
                                            } else if (nCreatureType == CREATURE_TYPE_DARKSPAWN)
                                            {
                                                rItem = R"gen_im_cft_reg_deathroot.uti";
                                            } else if (nCreatureType == CREATURE_TYPE_DRAGON)
                                            {
                                                rItem = R"gen_im_cft_reg_charm.uti";
                                            } else
                                            {
                                                rItem = R"gen_im_copper.uti";
                                                nStackSize = FloatToInt(GetLevel(GetHero()) * 10 * (0.8f + (RandomFloat() * 0.4f)));
                                                nStackSize = Max(nStackSize, 1);
                                            }
                                            CreateItemOnObject(rItem, oBag, nStackSize, "", TRUE);
                                        } else
                                        {
                                            SetBodybagDecayDelay(oBag, 0);
                                            SetObjectInteractive(oTargets[nCount], FALSE);
                                            SetObjectInteractive(oBag, FALSE);
                                            DestroyObject(oBag, 10000);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            break;
        }

        case 90210:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            // heal
            float fHeal = (100.0f + GetAttributeModifier(stEvent.oCaster, PROPERTY_ATTRIBUTE_STRENGTH)) * DEVOUR_HEAL_FACTOR;
            effect eEffect = EffectHeal(fHeal);
            eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_VFX, DEVOUR_HEAL_VFX);
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, stEvent.oCaster, 0.0f, stEvent.oCaster, stEvent.nAbility);

            break;
        }
    }
}