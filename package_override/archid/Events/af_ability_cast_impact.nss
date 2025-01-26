// Need Constants
#include "events_h"
// Need Effects_HandleApplyEffect
#include "effects_h"
#include "spell_constants_h" // ABILITY_XYZ
#include "plt_cod_aow_spellcombo3" // BLIZZARD TRIPLE COMBO REPORTING
#include "eventmanager_h"
#include "af_spellshaping_h"

// Based on code from Dheuster - Spell Shaping Skill (https://www.nexusmods.com/dragonage/mods/483)
// Modified by Archid to fix a few bugs, simplify some of the code and use event manager functionality

// Summary : When spells/abilities are cast, EVENT_TYPE_ABILITY_CAST_IMPACT is the last
// interceptable event broadcast. With certain Area of Effect spells, the destination
// script applies individual effects to the people in the AOE. Sometimes, these
// individual effects trickle back up through the event tree (such as Damage), but
// secondary effects do not. They are broadcaste as individual events and loop directly
// back to the handler script.
// Example: Ability FIREBALL is handled by spell_aoe_instant.nss. The primary effect
//          (damage) is applied to each target and trickles back up through the event
//          tree as EVENT_TYPE_APPLY_EFFECT. However the secondary effects like
//          KnockDown are handled by EVENT_TYPE_SPELLSCRIPT_INDIVIDUAL_IMPACT
//          events and are only broadcaste back to the script that created the event.
//          (In the case of FIREBALL: spell_aoe_instant).
//
// So... we intercept all EVENT_TYPE_ABILITY_CAST_IMPACT events. We bail early if the
// user doesnt have our skill or the ability is not a talent/skill/spell that has
// known secondary effects. If it IS... we basicaly replicate all the
// EVENT_TYPE_ABILITY_CAST_IMPACT handling functionality from ability_core.
// (Most of the code below is mildly optimized copy/paste from ability core.
// A little from the IMPACT event of any handled spells.
//


// Spell specific scripts
const resource AF_ABI_BLIZZARD_OVERRIDE_SCRIPT = R"af_blizzard_override.ncs";
const resource AF_ABI_GREASE_OVERRIDE_SCRIPT   = R"af_grease_override.ncs";

const int AF_SS_SPELL_STANDARD = 0;
const int AF_SS_SPELL_GREASE = 1;
const int AF_SS_SPELL_BLIZZARD = 2;

void main() {

    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    object  oCaster     = GetEventObject(ev, 0);
    if(IsDead(oCaster))     // If the caster is dead for some reasons, ignore
        return;
    // If user is not using skill, passing control to another handler
    if (!HasAbility(oCaster,AF_ABI_SPELLSHAPING) || !Ability_IsAbilityActive(oCaster, AF_ABI_SPELLSHAPING)) {
         EventManager_ReleaseLock();
         return;
    }

    // Get the Ability Identifier and bail early if it is not one of the abilities we care about:
    int nSpellCast = AF_SS_SPELL_STANDARD;
    int nAbility = GetEventInteger(ev, 0);
    switch (nAbility) {
        case ABILITY_SPELL_FIREBALL:
            ////PrintToLog("Spell Shaping : IT IS FIREBALL!");
            break;
        case ABILITY_SPELL_CONE_OF_COLD:
            ////PrintToLog("Spell Shaping : IT IS CONE OF COLD!");
            break;
        case ABILITY_SPELL_GREASE:
            ////PrintToLog("Spell Shaping : IT IS GREASE!");
            nSpellCast = AF_SS_SPELL_GREASE;
            break;
        case ABILITY_SPELL_BLIZZARD:
            ////PrintToLog("Spell Shaping : IT IS BLIZZARD!");
            nSpellCast = AF_SS_SPELL_BLIZZARD;
            break;
        default:
            EventManager_ReleaseLock();
            return;
    }

    // Now we handle some things that are normally handled by ability_core.


    // 1) Stealth : Most AOE abilities break stealth
    //    Ignore stealth dropping in the following scenarios
    //    1 - You are not in stealth in the first place
    //    2 - It's stealing
    //    3 - It's an item ability and you have stealth 2 and are lucky (10% failure)
    UI_DisplayMessage(oCaster, UI_DEBUG_EVENT_IMPACT_CAST );
    if (IsStealthy(oCaster) && nAbility != ABILITY_SKILL_STEALING_1 && !(GetAbilityType(nAbility) == ABILITY_TYPE_ITEM && HasAbility(oCaster, ABILITY_SKILL_STEALTH_2) && RandomFloat() < 0.9f))
        DropStealth(oCaster);

    // 2) Cooldown (disabling re-use for a small amount of time).
    //    To replicate handling,  we will need a handle to the caster, the item (if ability like scattershot) and knowledge of projectile traits:
    object oItem = GetEventObject(ev, 1);
    if(!IsObjectValid(oItem))
        return;

    int bHasProjectile = GetM2DAInt(TABLE_ABILITIES_SPELLS,"projectile",nAbility);
    if (!Ability_IsModalAbility(nAbility) && (!bHasProjectile || GetAbilityType(nAbility) == ABILITY_TYPE_ITEM) )
        Ability_SetCooldown(oCaster, nAbility, oItem);

    // Game Statistics Tracking
    object oTarget = GetEventObject(ev, 2);
    if (IsFollower(oCaster))
        TrackPartyAbilityUse(nEventType, oCaster, oTarget, nAbility);
    else if (IsFollower(oTarget) && !IsFollower(oCaster))
        TrackMonsterAbilityUse(nEventType, oCaster, oTarget, nAbility);

    // Need to validate location before applying visual effect
    // If we have no valid target location, but a valid target object, populate lTarget from the location of oTarget
    location lTarget = GetEventLocation(ev, 0);
    if (!IsLocationValid(lTarget) && IsObjectValid(oTarget))
        lTarget = GetLocation(oTarget);

    // -----------------------------------------------------------------
    // Apply the location impact visual effect
    // -----------------------------------------------------------------
    Ability_ApplyLocationImpactVFX(nAbility, lTarget);

    // The ultimate goal (normally) is to create an EventSpellScriptImpact
    // event object. However... we we can skip the actual event creation
    // since we will be handling it here. Still need the info normally
    // contained within however.

    int nAbilityType = Ability_GetAbilityType(nAbility);
    int nResistanceCheckResult = GetEventInteger(ev, 0);
    int nCombatAttackResult = GetEventInteger(ev, 1);
    int nHit = GetEventInteger(ev, 2);
    int nHand = GetEventInteger(ev, 3);


    // Not certain if this is important, but we go ahead and do it anyway.
    int nRet = GetLocalInt(GetModule(),HANDLE_EVENT_RETURN);
    SetLocalInt(GetModule(),HANDLE_EVENT_RETURN,COMMAND_RESULT_SUCCESS);

    switch (nSpellCast) {
        case AF_SS_SPELL_GREASE: {
            ////PrintToLog("Spell Shaping : Handling GREASE");

            // Spell Grease
            if (IsObjectValid(oTarget))
                lTarget = GetLocation(oTarget);

            // apply AoE effect on target
            ////PrintToLog("Spell Shaping : GREASE Applying Effect");
            effect eAoE = EffectAreaOfEffect(GREASE_AOE, AF_ABI_GREASE_OVERRIDE_SCRIPT, GREASE_AOE_VFX);
            Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_TEMPORARY, eAoE, lTarget, GREASE_DURATION, oCaster, nAbility);
            SendEventOnCastAt(oTarget,oCaster, nAbility, TRUE);
            break;
        }
        case AF_SS_SPELL_BLIZZARD: {
            ////PrintToLog("Spell Shaping : Handling BLIZZARD");

            // Spell Blizard : based on spell_blizzard.nss : _ApplyDamageAndEffects
            //----
            if (IsObjectValid(oTarget))
                lTarget = GetLocation(oTarget);

            // check for combo effect
            int bCombo = FALSE;
            float fDistance = GetM2DAFloat(TABLE_VFX_PERSISTENT, "RADIUS", STORM_OF_THE_CENTURY_AOE);
            if (IsModalAbilityActive(oCaster, ABILITY_SPELL_SPELL_MIGHT) == TRUE) {
                // clear all tempests in range
                object[] oTraps = GetObjectsInShape(OBJECT_TYPE_AREAOFEFFECTOBJECT, SHAPE_SPHERE, lTarget, fDistance);

                int nCount = 0;
                int nMax = GetArraySize(oTraps);
                for (nCount = 0; nCount < nMax; nCount++) {
                    Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, "AoE " + ToString(nCount) + " = " + GetTag(oTraps[nCount]));
                    if (GetTag(oTraps[nCount]) == TEMPEST_TAG) {
                        bCombo = TRUE;
                        DestroyObject(oTraps[nCount]);
                    }
                }
            }

            if (bCombo == TRUE)
            {
                // clear all blizzards in range
                object[] oTraps = GetObjectsInShape(OBJECT_TYPE_AREAOFEFFECTOBJECT, SHAPE_SPHERE, lTarget, fDistance);

                int nCount = 0;
                int nMax = GetArraySize(oTraps);
                for (nCount = 0; nCount < nMax; nCount++) {
                    Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, "AoE " + ToString(nCount) + " = " + GetTag(oTraps[nCount]));
                    if (GetTag(oTraps[nCount]) == BLIZZARD_TAG)
                        DestroyObject(oTraps[nCount]);
                }

                nAbility = ABILITY_SPELL_STORM_OF_THE_CENTURY;
                effect eAoE = EffectAreaOfEffect(STORM_OF_THE_CENTURY_AOE, SCRIPT_SPELL_AOE_DURATION, STORM_OF_THE_CENTURY_AOE_VFX);
                Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_TEMPORARY, eAoE, lTarget, STORM_OF_THE_CENTURY_DURATION, oCaster, nAbility);

                // additional mana drain
                effect eEffect = EffectModifyManaStamina(STORM_OF_THE_CENTURY_MANA_DRAIN);
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oCaster, 0.0f, oCaster, nAbility);
                UI_DisplayDamageFloaty(oCaster, oCaster, FloatToInt(STORM_OF_THE_CENTURY_MANA_DRAIN), nAbility, 0, TRUE);

                // combo effect - storm of the century
                if (IsFollower(oCaster) == TRUE)
                    WR_SetPlotFlag(PLT_COD_AOW_SPELLCOMBO3, COD_AOW_SPELLCOMBO_3_STORM_OF_THE_CENTURY, TRUE);
            }
            else
            {
                effect eAoE = EffectAreaOfEffect(BLIZZARD_AOE, AF_ABI_BLIZZARD_OVERRIDE_SCRIPT, BLIZZARD_AOE_VFX);
                Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_TEMPORARY, eAoE, lTarget, BLIZZARD_DURATION, oCaster, nAbility);
                Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_TEMPORARY, EffectVisualEffect(BLIZZARD_ICE_SHEET_VFX), lTarget, BLIZZARD_DURATION, oCaster, nAbility);


                // -------------------------------------------------------------------------
                // Demo hack - signal the first hostile creature an oncast at event
                // -------------------------------------------------------------------------
                object[] a = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, lTarget, 20.0f);

                int i = 0;
                int nSize = GetArraySize(a);
                for (i = 0; i < nSize; i++)
                    if (IsObjectHostile(oCaster, a[i]))
                        SendEventOnCastAt(a[i], oCaster, nAbility, TRUE);
            }
            break; // AF_SS_SPELL_BLIZZARD
        }
        case AF_SS_SPELL_STANDARD: {
            int nAoEType = GetM2DAInt(TABLE_ABILITIES_SPELLS, "aoe_type", nAbility);
            if (nAoEType == 1) { // Circular
                // -------------------------------------------------------------------------
                // BEGIN COPY/PASTE from spell_aoe_instant.nss : _ApplyImpactDamageAndEffects
                // -------------------------------------------------------------------------

                // location impact vfx
                if (!IsObjectValid(oTarget))
                    lTarget = GetLocation(oTarget);
                Ability_ApplyLocationImpactVFX(nAbility, lTarget);

                float fRadius = GetM2DAFloat(TABLE_ABILITIES_SPELLS, "aoe_param1", nAbility);

                // get objects in area of effect
                object[] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, lTarget, fRadius);

                // spell-specific special events
                switch (nAbility)
                {
                    case ABILITY_SPELL_FIREBALL: {
                        // ignite
                        SendComboEventAoE(COMBO_EVENT_IGNITE, SHAPE_SPHERE, lTarget, oCaster, fRadius);
                        break;
                    }
                    case ABILITY_SPELL_ANTIMAGIC_BURST: {
                        // glyph of paralysis
                        object[] oTraps = GetObjectsInShape(OBJECT_TYPE_PLACEABLE, SHAPE_SPHERE, lTarget, fRadius);

                        int nCount = 0;
                        int nMax = GetArraySize(oTraps);
                        for (nCount = 0; nCount < nMax; nCount++)
                            if (GetTag(oTraps[nCount]) == GLYPH_OF_PARALYSIS_TAG)
                                DestroyObject(oTraps[nCount]);

                        // normal glyphs
                        oTraps = GetObjectsInShape(OBJECT_TYPE_AREAOFEFFECTOBJECT, SHAPE_SPHERE, lTarget, fRadius);

                        nMax = GetArraySize(oTraps);
                        for (nCount = 0; nCount < nMax; nCount++)
                        {
                            string sTag = GetTag(oTraps[nCount]);
                            if ((sTag == GLYPH_OF_WARDING_TAG) || (sTag == GLYPH_OF_REPULSION_TAG)
                             || (sTag == ANTIMAGIC_BURST_BLIZZARD_TAG) || (sTag == ANTIMAGIC_BURST_TEMPEST_TAG)
                             || (sTag == ANTIMAGIC_BURST_DEATHCLOUD_TAG) || (sTag == ANTIMAGIC_BURST_SPELLBLOOM_TAG)
                             || (sTag == ANTIMAGIC_BURST_EARTHQUAKE_TAG) || (sTag == ANTIMAGIC_BURST_INFERNO_TAG))
                            {
                                DestroyObject(oTraps[nCount]);
                            }
                        }

                        break;
                    }
                    case ABILITY_SPELL_MANA_CLASH: {
                        // caster vfx
                        effect eEffect = EffectVisualEffect(MANA_CLASH_CASTER_VFX);
                        ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oCaster, 0.0f, oCaster, nAbility);
                        break;
                    }
                }

                // ========================== SPELL SHAPING ====================
                int nCount = 0;
                int nMax = Min(GetArraySize(oTargets), 30);
                for (nCount = 0; nCount < nMax; nCount++)
                    if (IsSpellShapingTarget(oCaster, oTargets[nCount]))
                        if  (!CheckSpellResistance(oTargets[nCount], oCaster, nAbility))
                            SetIndividualImpactAOEEvent(oCaster,oTargets[nCount],nAbility,lTarget,500);
                        else
                            UI_DisplayMessage(oTargets[nCount], UI_MESSAGE_RESISTED);

            } else if (nAoEType == 2) { // Cone
                // cone vfx
                effect eCone = EffectConeCasting(Ability_GetImpactLocationVfxId(nAbility));
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eCone, oCaster, 1.5f, oCaster, 0 /*intentional*/);

                // cone details
                float fAoEParam1 = GetM2DAFloat(TABLE_ABILITIES_SPELLS, "aoe_param1", nAbility);
                float fAoEParam2 = GetM2DAFloat(TABLE_ABILITIES_SPELLS, "aoe_param2", nAbility);
                if (fAoEParam2 <= 0.0f)
                    fAoEParam2 = 5.0f;
                lTarget = GetLocation(oCaster);

                // unique spell effects
                switch (nAbility)
                {
                    case ABILITY_SPELL_FLAME_BLAST:
                        SendComboEventAoE(COMBO_EVENT_IGNITE, SHAPE_CONE, lTarget, oCaster, fAoEParam1, fAoEParam2);
                        break;
                }

                // ========================== SPELL SHAPING ====================
                object[] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_CONE, lTarget, fAoEParam1, fAoEParam2);
                int nCount = 0;
                int nMax = GetArraySize(oTargets);
                for (nCount = 0; nCount < nMax; nCount++)
                    if (IsSpellShapingTarget(oCaster, oTargets[nCount]))
                        if  (!CheckSpellResistance(oTargets[nCount], oCaster, nAbility))
                            SetIndividualImpactAOEEvent(oCaster,oTargets[nCount],nAbility,lTarget,500);
                        else
                            UI_DisplayMessage(oTargets[nCount], UI_MESSAGE_RESISTED);
            }
            break; // AF_SS_SPELL_STANDARD
        }
    }

    // -----------------------------------------------------------------
    // If item ability, remove one item from the stack. This needs to be the last thing
    // in the script.
    // -----------------------------------------------------------------
    if ((GetAbilityType(nAbility) == ABILITY_TYPE_ITEM) && (nAbility != ITEM_ABILITY_UNIQUE_POWER_UNLIMITED_USE) && (nAbility != ITEM_ABILITY_KOLGRIMS_HORN))
        RemoveItem(oItem,1);
} 