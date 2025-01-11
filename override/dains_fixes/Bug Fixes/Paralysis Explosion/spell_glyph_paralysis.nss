// -----------------------------------------------------------------------------
// talent_single_target.nss
// -----------------------------------------------------------------------------
/*
    Generic Ability Script for single target abilities
*/
// -----------------------------------------------------------------------------
// georg / petert
// -----------------------------------------------------------------------------

#include "log_h"
#include "abi_templates"
#include "sys_traps_h"
#include "spell_constants_h"
#include "plt_cod_aow_spellcombo2"
#include "plt_cod_aow_spellcombo5"
#include "plt_cod_aow_spellcombo8"

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    // -------------------------------------------------------------------------
    // VAR BLOCK
    // -------------------------------------------------------------------------
    int    nScalingVector   = SCALING_VECTOR_DURATION;
    int    nAttackingValue  = PROPERTY_ATTRIBUTE_SPELLPOWER;
    int    nResistance      = RESISTANCE_INVALID;
    float  fDuration        = 0.0f;
    float  fScaledValue     = 0.0f;
    int    nEffect          = 0;
    int    nHandler         = SPELL_HANDLER_CUSTOM;
    effect eDamage;
    effect eEffect;
    effect[] eEffects;
    int bHostile = FALSE;

    // make sure there is a location, just in case
    if (IsObjectValid(stEvent.oTarget) == TRUE)
    {
        stEvent.lTarget = GetLocation(stEvent.oTarget);
    }

    // -------------------------------------------------------------------------
    // Handle Spells
    // -------------------------------------------------------------------------
    switch (stEvent.nAbility)
    {
        case ABILITY_SPELL_GLYPH_OF_PARALYSIS:
        {
            // check for spell combo
            int bCombo = FALSE;

            // get radii
            int nAoE1 = GetM2DAInt(TABLE_ABILITIES_SPELLS, "aoe_idx", ABILITY_SPELL_GLYPH_OF_PARALYSIS);
            float fRadius1 = GetM2DAFloat(TABLE_VFX_PERSISTENT, "RADIUS", nAoE1);
            fRadius1 = MaxF(fRadius1, 0.0f);
            int nAoE2 = GetM2DAInt(TABLE_ABILITIES_SPELLS, "aoe_idx", ABILITY_SPELL_GLYPH_OF_REPULSION);
            float fRadius2 = GetM2DAFloat(TABLE_VFX_PERSISTENT, "RADIUS", nAoE1);
            fRadius2 = MaxF(fRadius2, 0.0f);

            // if there is a valid range
            float fDistance = fRadius1 + fRadius2;
            if (fDistance > 0.0f)
            {
                // get glyphs of repulsion in range
                object[] oAoEs = GetObjectsInShape(OBJECT_TYPE_AREAOFEFFECTOBJECT, SHAPE_SPHERE, stEvent.lTarget, fDistance);

                int nCount = 0;
                int nMax = GetArraySize(oAoEs);
                for (nCount = 0; nCount < nMax; nCount++)
                {
                    Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, "AoE " + ToString(nCount) + " = " + GetTag(oAoEs[nCount]));
                    if (GetTag(oAoEs[nCount]) == GLYPH_OF_REPULSION_TAG)
                    {
                        bCombo = TRUE;
                        DestroyObject(oAoEs[nCount]);
                    }
                }
            }

            if (bCombo == TRUE)
                        {
                // impact vfx
                Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_INSTANT, EffectVisualEffect(PARALYSIS_EXPLOSION_IMPACT_VFX), stEvent.lTarget, 0.0f, stEvent.oCaster, ABILITY_SPELL_PARALYSIS_EXPLOSION);

                // vfx
                Ability_ApplyLocationImpactVFX(ABILITY_SPELL_PARALYSIS_EXPLOSION, stEvent.lTarget);

                // range of explosion
                fDistance += fRadius2;
                effect eEffect = EffectParalyze(Ability_GetImpactObjectVfxId(ABILITY_SPELL_PARALYSIS_EXPLOSION));
                object[] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, stEvent.lTarget, fDistance);
                int nCount = 0;
                int nMax = GetArraySize(oTargets);
                float fDuration;
                for (nCount = 0; nCount < nMax; nCount++)
                {
                    if (CheckSpellResistance(oTargets[nCount], stEvent.oCaster, ABILITY_SPELL_PARALYSIS_EXPLOSION) == FALSE)
                    {
                        fDuration = GetRankAdjustedEffectDuration(oTargets[nCount], PARALYSIS_EXPLOSION_DURATION);

                        // remove stacking effects
                        RemoveStackingEffects(oTargets[nCount], stEvent.oCaster, ABILITY_SPELL_PARALYSIS_EXPLOSION);

                        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTargets[nCount], fDuration, stEvent.oCaster, ABILITY_SPELL_PARALYSIS_EXPLOSION);
                    } else
                    {
                        UI_DisplayMessage(oTargets[nCount], UI_MESSAGE_RESISTED);
                    }
                }

                // combo effect codex - paralysis explosion
                if (IsFollower(stEvent.oCaster) == TRUE)
                {
                    WR_SetPlotFlag(PLT_COD_AOW_SPELLCOMBO2, COD_AOW_SPELLCOMBO_2_PARALYSIS_EXPLOSION, TRUE);
                }
            } else
            {
                object oTrap = Trap_CreateTrap(GLYPH_OF_PARALYSIS_TRAP, stEvent.lTarget, stEvent.oCaster);

                // verify that there aren't too many glyphs
                object[] oTrapList = GetNearestObjectByTag(oTrap, "genip_trap_glyph", OBJECT_TYPE_PLACEABLE, 100);
                int nSize = GetArraySize(oTrapList);
                Log_Trace(LOG_CHANNEL_SYSTEMS_TRAPS, GetCurrentScriptName() + " Glyph of Paralysis List Size = " + ToString(nSize));
                Log_Trace(LOG_CHANNEL_SYSTEMS_TRAPS, GetCurrentScriptName() + " Glyph of Paralysis Max = " + ToString(GLYPH_OF_PARALYSIS_MAX_NUMBER));

                // if there are already the maximum number of glyphs
                if (nSize >= GLYPH_OF_PARALYSIS_MAX_NUMBER)
                {
                    // find the number of glyphs owned by the same caster
                    int nCount = 0;
                    int nOwnerNum = 0;
                    object oOwner;
                    for (nCount = 0; nCount < nSize; nCount++)
                    {
                        // get owner
                        oOwner = GetLocalObject(oTrapList[nCount], PLC_TRAP_OWNER);
                        Log_Trace(LOG_CHANNEL_SYSTEMS_TRAPS, GetCurrentScriptName() + " Owner of Glyph of Paralysis " + ToString(nCount) + " is " + GetTag(oOwner));
                        Log_Trace(LOG_CHANNEL_SYSTEMS_TRAPS, GetCurrentScriptName() + " Number of Glyphs of Paralysis by caster = " + ToString(nOwnerNum));

                        // if owner is the same
                        if (oOwner == stEvent.oCaster)
                        {
                            nOwnerNum++;
                            if (nOwnerNum >= GLYPH_OF_PARALYSIS_MAX_NUMBER)
                            {
                                SetPlot(oTrapList[nCount], FALSE);
                                Safe_Destroy_Object(oTrapList[nCount], 0);
                            }
                        }
                    }
                }

                Log_Trace(LOG_CHANNEL_SYSTEMS_TRAPS, GetCurrentScriptName() + " Glyph of Paralysis Created");

                Trap_ArmTrap(oTrap, stEvent.oCaster, 0.0f);

                // signal duration of glyph
                event ev = Event(EVENT_TYPE_DESTROY_OBJECT);
                ev = SetEventInteger(ev, 0, TRUE);      // Forces Plot property to FALSE
                DelayEvent(GLYPH_OF_PARALYSIS_DURATION, oTrap, ev);
            }

            break;
        }
    }
}

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    switch(nEventType)
    {
        case EVENT_TYPE_SPELLSCRIPT_PENDING:
        {
            Ability_SetSpellscriptPendingEventResult(COMMAND_RESULT_SUCCESS);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            // Hand this through to cast_impact
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            // Handle impact
            if (CheckSpellResistance(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility) == FALSE)
                _HandleImpact(stEvent);
            else
                UI_DisplayMessage(stEvent.oTarget, UI_MESSAGE_RESISTED);

            break;
        }
    }
}