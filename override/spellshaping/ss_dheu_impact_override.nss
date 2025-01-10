// Need Constants
#include "events_h"
// Need Effects_HandleApplyEffect
#include "effects_h"
#include "ability_h"
#include "spell_constants_h" // ABILITY_XYZ
#include "ss_dheu_constants_h"
#include "plt_cod_aow_spellcombo3" // BLIZZARD TRIPLE COMBO REPORTING

// Summary : When spells/abilities are cast, EVENT_TYPE_ABILITY_CAST_IMPACT is the last
// interceptable event broadcast. With certain Area of Effect spells, the destination
// script applies individual effects to the people in the AOE. Sometimes, these
// individual effects trickle back up through the event tree (such as Damage), but
// secondary effects do not. They are broadcaste as individual events and loop directly
// back to the handler script.
//
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
// Why this approach. Isn't it messy?
//
// Simple: If someone installs my mod, they get 4 new skills. If they do
// not invest in those skills, My 2 overriden events redirect to the games
// default handlers... So my code changes are ONLY INTRODUCED if the user
// actually invests in one of the skills.
//
// I could have changed the spellscript columns in ABI_base.xls, however
// then my overridden spellscripts would get used wether the person
// invested in my new skill or not. There would also be a lot more opportunities to
// clash with other mods.

void main() {

    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    if (EVENT_TYPE_ABILITY_CAST_IMPACT == nEventType)
    {

        ////PrintToLog("Spell Shaping : EVENT_TYPE_ABILITY_CAST_IMPACT caught");

        object  oCaster     = GetEventObject(ev, 0);
        if(IsDead(oCaster))     // If the caster is dead for some reasons, ignore
        {
            return;
        }
        // If user is not using skill, redirect to default
        if (!HasAbility(oCaster,SPELLSHAPING) || !Ability_IsAbilityActive(oCaster, SPELLSHAPING))
        {
             HandleEvent(ev, R"ability_core.ncs");
             return;
        }

        // Get the Ability Identifier and bail early if it is not one of the
        // abilities we care about:

        int     nAbility    = GetEventInteger(ev, 0);
        if(nAbility == 0)
        {
            return;
        }
        int specific = 0;
        switch (nAbility) {
            case ABILITY_SPELL_FIREBALL:
                ////PrintToLog("Spell Shaping : IT IS FIREBALL!");
                break;
            case ABILITY_SPELL_CONE_OF_COLD:
                ////PrintToLog("Spell Shaping : IT IS CONE OF COLD!");
                break;
            case ABILITY_SPELL_GREASE:
                ////PrintToLog("Spell Shaping : IT IS GREASE!");
                specific = 1;
                break;
            case ABILITY_SPELL_BLIZZARD:
                ////PrintToLog("Spell Shaping : IT IS BLIZZARD!");
                specific = 2;
                break;
            default:
                ////PrintToLog("Spell Shaping : Dont care about Ability");
                HandleEvent(ev, R"ability_core.ncs");
                return;
        }

        // Now we handle some things that are normally handled by ability_core.


        // 1) Stealth : Most AOE abilities break stealth
        // break stealth when using an ability

        UI_DisplayMessage(oCaster, UI_DEBUG_EVENT_IMPACT_CAST );

        if (IsStealthy(oCaster) == TRUE)
        {
            // ignore stealth dropping if its an item and you have stealth 2
            float fRandom = RandomFloat();
            if ((GetAbilityType(nAbility) != ABILITY_TYPE_ITEM) || ((HasAbility(oCaster, ABILITY_SKILL_STEALTH_2) == FALSE) || (fRandom < 0.1f)))
            {
                // stealing is a special exception
                if (nAbility != ABILITY_SKILL_STEALING_1)
                {
                    DropStealth(oCaster);
                }
            }
        }

        // 2) Cooldown (disabling re-use for a small amount of time).
        // To replicate handling,  we will need a handle to the caster, the
        // item (if ability like scattershot) and knowledge of projectile traits:
        object  oItem       = GetEventObject(ev, 1);
        if(oItem != OBJECT_INVALID && !IsObjectValid(oItem))
        {
            return;
        }
        int bHasProjectile = GetM2DAInt(TABLE_ABILITIES_SPELLS,"projectile",nAbility);
        if (!Ability_IsModalAbility(nAbility) && (!bHasProjectile || (GetAbilityType(nAbility) == ABILITY_TYPE_ITEM)))
        {
            Ability_SetCooldown(oCaster, nAbility, oItem);
        }


        // Game Statistics Tracking
        object  oTarget     = GetEventObject(ev, 2);
        if (IsFollower(oCaster))
        {
            TrackPartyAbilityUse(nEventType, oCaster, oTarget, nAbility);
        }
        else if (IsFollower(oTarget) && !IsFollower(oCaster))
        {
            TrackMonsterAbilityUse(nEventType, oCaster, oTarget, nAbility);
        }

        // Need to validate location before applying visual effect
        location lTarget = GetEventLocation(ev, 0);
        if (!IsLocationValid(lTarget))
        {
            // If we have no valid target location, but a valid target object, populate lTarget from
            // the location of oTarget;
            if (IsObjectValid(oTarget))
            {
                lTarget = GetLocation(oTarget);
            }
        }

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


        // event evImpact = EventSpellScriptImpact(oCaster,oTarget,nAbility,nAbilityType, nResistanceCheckResult, lTarget, nHit, nHand,oItem);

        // int n2DA = Ability_GetAbilityTable(nAbilityType);
        // resource rResource = GetM2DAResource(n2DA,"SpellScript",nAbility);

        // if (rResource == "")
        // {
        //    return;
        // }

        // Not certain if this is important, but we go ahead and do it anyway.
        int nRet = GetLocalInt(GetModule(),HANDLE_EVENT_RETURN);
        SetLocalInt(GetModule(),HANDLE_EVENT_RETURN,COMMAND_RESULT_SUCCESS);

        // HandleEvent(ev, R"ss_dheu_spells.ncs");
        // HandleEvent(ev, rResource);

        // struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);
        // _ApplyImpactDamageAndEffects(stEvent);


        int nAoEType = GetM2DAInt(TABLE_ABILITIES_SPELLS, "aoe_type", nAbility);
        // 1 = cicular
        // 2 = cone

        if (0 != specific)
        {
            if (1 == specific)
            {
                ////PrintToLog("Spell Shaping : Handling GREASE");

                // Spell Grease
                if (IsObjectValid(oTarget))
                {
                    ////PrintToLog("Spell Shaping : GREASE Target Valid");
                    lTarget = GetLocation(oTarget);
                }
                else
                {
                    ////PrintToLog("Spell Shaping : GREASE Target NOT Valid");
                }

                // apply AoE effect on target
                ////PrintToLog("Spell Shaping : GREASE Applying Effect");
                effect eAoE = EffectAreaOfEffect(GREASE_AOE, R"ss_dheu_grease_override.ncs", GREASE_AOE_VFX);
                Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_TEMPORARY, eAoE, lTarget, GREASE_DURATION, oCaster, nAbility);
                SendEventOnCastAt(oTarget,oCaster, nAbility, TRUE);
            }
            else if (2 == specific)
            {
                ////PrintToLog("Spell Shaping : Handling BLIZZARD");

                // Spell Blizard : based on spell_blizzard.nss : _ApplyDamageAndEffects
                //----
                if (IsObjectValid(oTarget))
                {
                    lTarget = GetLocation(oTarget);
                }

                // check for combo effect
                int bCombo = FALSE;

                float fDistance = GetM2DAFloat(TABLE_VFX_PERSISTENT, "RADIUS", STORM_OF_THE_CENTURY_AOE);

                if (IsModalAbilityActive(oCaster, ABILITY_SPELL_SPELL_MIGHT) == TRUE)
                {
                    // clear all tempests in range
                    object[] oTraps = GetObjectsInShape(OBJECT_TYPE_AREAOFEFFECTOBJECT, SHAPE_SPHERE, lTarget, fDistance);

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
                    object[] oTraps = GetObjectsInShape(OBJECT_TYPE_AREAOFEFFECTOBJECT, SHAPE_SPHERE, lTarget, fDistance);

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

                    nAbility = ABILITY_SPELL_STORM_OF_THE_CENTURY;
                    effect eAoE = EffectAreaOfEffect(STORM_OF_THE_CENTURY_AOE, SCRIPT_SPELL_AOE_DURATION, STORM_OF_THE_CENTURY_AOE_VFX);
                    Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_TEMPORARY, eAoE, lTarget, STORM_OF_THE_CENTURY_DURATION, oCaster, nAbility);

                    // additional mana drain
                    effect eEffect = EffectModifyManaStamina(STORM_OF_THE_CENTURY_MANA_DRAIN);
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oCaster, 0.0f, oCaster, nAbility);
                    UI_DisplayDamageFloaty(oCaster, oCaster, FloatToInt(STORM_OF_THE_CENTURY_MANA_DRAIN), nAbility, 0, TRUE);

                    // combo effect - storm of the century
                    if (IsFollower(oCaster) == TRUE)
                    {
                        WR_SetPlotFlag(PLT_COD_AOW_SPELLCOMBO3, COD_AOW_SPELLCOMBO_3_STORM_OF_THE_CENTURY, TRUE);
                    }
                }
                else
                {
                    effect eAoE = EffectAreaOfEffect(BLIZZARD_AOE, R"ss_dheu_blizzard_override.ncs", BLIZZARD_AOE_VFX);
                    Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_TEMPORARY, eAoE, lTarget, BLIZZARD_DURATION, oCaster, nAbility);
                    Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_TEMPORARY, EffectVisualEffect(BLIZZARD_ICE_SHEET_VFX), lTarget, BLIZZARD_DURATION, oCaster, nAbility);


                    // -------------------------------------------------------------------------
                    // Demo hack - signal the first hostile creature an oncast at event
                    // -------------------------------------------------------------------------
                    object[] a = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, lTarget, 20.0f);

                    int nSize = GetArraySize(a);
                    int i;

                    for (i = 0; i < nSize; i++)
                    {
                        if (IsObjectHostile(oCaster, a[i]))
                        {
                            SendEventOnCastAt(a[i], oCaster, nAbility, TRUE);
                        }
                    }
                }
                //----
            }

        }
        else if (nAoEType == 1)
        {
            // -------------------------------------------------------------------------
            // BEGIN COPY/PASTE from spell_aoe_instant.nss : _ApplyImpactDamageAndEffects
            // -------------------------------------------------------------------------

            // location impact vfx
            if (oTarget != OBJECT_INVALID)
            {
                    lTarget = GetLocation(oTarget);
            }
            Ability_ApplyLocationImpactVFX(nAbility, lTarget);

            float fRadius = GetM2DAFloat(TABLE_ABILITIES_SPELLS, "aoe_param1", nAbility);

            // get objects in area of effect
            object[] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, lTarget, fRadius);

            // spell-specific special events
            switch (nAbility)
            {
                case ABILITY_SPELL_FIREBALL:
                {
                    // ignite
                    SendComboEventAoE(COMBO_EVENT_IGNITE, SHAPE_SPHERE, lTarget, oCaster, fRadius);

                    break;
                }

                case ABILITY_SPELL_ANTIMAGIC_BURST:
                {
                    // glyph of paralysis
                    object[] oTraps = GetObjectsInShape(OBJECT_TYPE_PLACEABLE, SHAPE_SPHERE, lTarget, fRadius);

                    int nCount = 0;
                    int nMax = GetArraySize(oTraps);
                    for (nCount = 0; nCount < nMax; nCount++)
                    {
                        if (GetTag(oTraps[nCount]) == GLYPH_OF_PARALYSIS_TAG)
                        {
                            DestroyObject(oTraps[nCount]);
                        }
                    }

                    // normal glyphs
                    oTraps = GetObjectsInShape(OBJECT_TYPE_AREAOFEFFECTOBJECT, SHAPE_SPHERE, lTarget, fRadius);

                    nCount = 0;
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

                case ABILITY_SPELL_MANA_CLASH:
                {
                    // caster vfx
                    effect eEffect = EffectVisualEffect(MANA_CLASH_CASTER_VFX);
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oCaster, 0.0f, oCaster, nAbility);

                    break;
                }
            }

            // cycle through objects

            // ========================== BEGIN SPELL SHAPING EDITS ====================

            if (HasAbility(oCaster,IMPROVED_SPELLSHAPING))
            {
                if (HasAbility(oCaster,MASTER_SPELLSHAPING))
                {
                    int nCount = 0;
                    int nMax = Min(GetArraySize(oTargets), 30);
                    int cgroupID = GetGroupId(oCaster);
                    for (nCount = 0; nCount < nMax; nCount++)
                    {
                        if (IsObjectValid(oTargets[nCount]))
                        {
                            if (IsObjectHostile(oTargets[nCount],oCaster))
                            {
                                if (CheckSpellResistance(oTargets[nCount], oCaster, nAbility) == FALSE)
                                {
                                    SetIndividualImpactAOEEvent(oCaster,oTargets[nCount],nAbility,lTarget,500);
                                }
                                else
                                {
                                    UI_DisplayMessage(oTargets[nCount], UI_MESSAGE_RESISTED);
                                }
                            }
                            // else ignore
                        }
                    }
                }
                else
                {
                    // Code for expert is the same as improved since expert only
                    // protects allies from damage and that is handled elsewhere.

                    int nCount = 0;
                    int nMax = Min(GetArraySize(oTargets), 30);
                    for (nCount = 0; nCount < nMax; nCount++)
                    {
                        if (IsObjectValid(oTargets[nCount]))
                        {
                            if (!IsPartyMember(oTargets[nCount]))
                            {
                                if (CheckSpellResistance(oTargets[nCount], oCaster, nAbility) == FALSE)
                                {
                                    SetIndividualImpactAOEEvent(oCaster,oTargets[nCount],nAbility,lTarget,500);
                                }
                                else
                                {
                                    UI_DisplayMessage(oTargets[nCount], UI_MESSAGE_RESISTED);
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
                int nCount = 0;
                int nMax = Min(GetArraySize(oTargets), 30);
                for (nCount = 0; nCount < nMax; nCount++)
                {
                    if (CheckSpellResistance(oTargets[nCount], oCaster, nAbility) == FALSE)
                    {
                        // per-spell effects
                        SetIndividualImpactAOEEvent(oCaster,oTargets[nCount],nAbility,lTarget);
                    }
                    else
                    {
                        UI_DisplayMessage(oTargets[nCount], UI_MESSAGE_RESISTED);
                    }
                }
            }

            // ========================== END SPELL SHAPING EDITS ====================

        }
        // -------------------------------------------------------------------------
        // END COPY/PASTE from spell_aoe_instant.nss : _ApplyImpactDamageAndEffects
        // -------------------------------------------------------------------------

        else if (nAoEType == 2)
        {
            // cone vfx
            effect eCone = EffectConeCasting(Ability_GetImpactLocationVfxId(nAbility));
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eCone, oCaster, 1.5f, oCaster, 0 /*intentional*/);

            // cone details
            float fAoEParam1 = GetM2DAFloat(TABLE_ABILITIES_SPELLS, "aoe_param1", nAbility);
            float fAoEParam2 = GetM2DAFloat(TABLE_ABILITIES_SPELLS, "aoe_param2", nAbility);
            if (fAoEParam2 <= 0.0f)
            {
                fAoEParam2 = 5.0f;
            }
            lTarget = GetLocation(oCaster);

            // unique spell effects
            switch (nAbility)
            {
                case ABILITY_SPELL_FLAME_BLAST:
                {
                    SendComboEventAoE(COMBO_EVENT_IGNITE, SHAPE_CONE, lTarget, oCaster, fAoEParam1, fAoEParam2);

                    break;
                }
            }

            effect eEffect;

            // ========================== BEGIN SPELL SHAPING EDITS ====================
            if (HasAbility(oCaster,IMPROVED_SPELLSHAPING))
            {
                if (HasAbility(oCaster,MASTER_SPELLSHAPING))
                {
                    object[] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_CONE, lTarget, fAoEParam1, fAoEParam2);
                    int nCount = 0;
                    int nMax = GetArraySize(oTargets);
                    int cgroupID = GetGroupId(oCaster);
                    for (nCount = 0; nCount < nMax; nCount++)
                    {
                        if (IsObjectValid(oTargets[nCount]))
                        {
                            if (IsObjectHostile(oTargets[nCount],oCaster))
                            {
                                // if (cgroupID !=  GetGroupId(oTargets[nCount]))
                                if (CheckSpellResistance(oTargets[nCount], oCaster, nAbility) == FALSE)
                                {
                                    SetIndividualImpactAOEEvent(oCaster,oTargets[nCount],nAbility,lTarget,500);
                                }
                                else
                                {
                                    UI_DisplayMessage(oTargets[nCount], UI_MESSAGE_RESISTED);
                                }
                            }
                        }
                    }
                }
                else
                {
                    // Code for expert is the same as improved since expert only
                    // protects allies from damage and that is handles elsewhere.
                    object[] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_CONE, lTarget, fAoEParam1, fAoEParam2);
                    int nCount = 0;
                    int nMax = GetArraySize(oTargets);
                    for (nCount = 0; nCount < nMax; nCount++)
                    {
                        if (IsObjectValid(oTargets[nCount]))
                        {
                            if (!IsPartyMember(oTargets[nCount]))
                            {
                                if (CheckSpellResistance(oTargets[nCount], oCaster, nAbility) == FALSE)
                                {
                                    SetIndividualImpactAOEEvent(oCaster,oTargets[nCount],nAbility,lTarget,500);
                                }
                                else
                                {
                                    UI_DisplayMessage(oTargets[nCount], UI_MESSAGE_RESISTED);
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                // Default (orignial) implementation
                object[] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_CONE, lTarget, fAoEParam1, fAoEParam2);
                int nCount = 0;
                int nMax = GetArraySize(oTargets);
                for (nCount = 0; nCount < nMax; nCount++)
                {
                    // do not affect caster
                    if (oTargets[nCount] != oCaster)
                    {
                        if (CheckSpellResistance(oTargets[nCount], oCaster, nAbility) == FALSE)
                        {
                            SetIndividualImpactAOEEvent(oCaster,oTargets[nCount],nAbility,lTarget,500);
                        }
                        else
                        {
                            UI_DisplayMessage(oTargets[nCount], UI_MESSAGE_RESISTED);
                        }
                    }
                }
            }
        } // If AOE == 2

        // -----------------------------------------------------------------
        // If item ability, remove one item from the stack. This needs to be the last thing
        // in the script.
        // -----------------------------------------------------------------
        if ((GetAbilityType(nAbility) == ABILITY_TYPE_ITEM) && (nAbility != ITEM_ABILITY_UNIQUE_POWER_UNLIMITED_USE) && (nAbility != ITEM_ABILITY_KOLGRIMS_HORN))
        {
            RemoveItem(oItem,1);
        }
    }
    else if (EVENT_TYPE_SPELLSCRIPT_INDIVIDUAL_IMPACT == nEventType)
    {
        // Reroute to the abilities normal handler.
        int nAbility = GetEventInteger(ev,0);
        int nAbilityType = Ability_GetAbilityType(nAbility);
        int n2DA = Ability_GetAbilityTable(nAbilityType);
        resource rResource = GetM2DAResource(n2DA,"SpellScript",nAbility);

        ////PrintToLog("Spell Shaping : Intercepted EVENT_TYPE_SPELLSCRIPT_INDIVIDUAL_IMPACT. Sending to Resource [" + ResourceToString(rResource) + "]");

        if (rResource != "")
        {
            HandleEvent(ev, rResource);
        }
    }
    /*
    else if (EVENT_TYPE_TRAP_TRIGGER_ENTER == nEventType)
    {
        ////PrintToLog("Spell Shaping : Intercepted EVENT_TYPE_TRAP_TRIGGER_ENTER.");
        object oTarget  = GetEventTarget(ev);
        object oTrap    = GetEventCreator(ev);
        object oCreator = OBJECT_INVALID;
        if (GetObjectType(oTrap) == OBJECT_TYPE_PLACEABLE)
        {
            oCreator = GetLocalObject(oTrap, PLC_TRAP_OWNER);
        }
        //  HandleEvent(ev, R"placeable_core.ncs");
    }
    */
    else
    {
        ////PrintToLog("Spell Shaping : ss_dheu_impact_override.nss : Unknown EVENT Type [" + ToString(nEventType) + "] caught");
    }
}