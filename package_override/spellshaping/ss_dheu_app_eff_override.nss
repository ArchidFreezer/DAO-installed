    // Need Constants
    #include "events_h"
    // Need Effects_HandleApplyEffect
    #include "effects_h"
    #include "ability_h"
    #include "ss_dheu_constants_h"

    int _handle_damage(int difficulty, int nAbility, float manacost, float damage, object oCreator) {
        float fCost = manacost * damage;
                                           
        if (ABILITY_SPELL_BLOOD_SACRIFICE == nAbility)
        {
            return FALSE;
        }
        // Stolen from ability_h : Ability_SubtractAbilityCost
        // ===================================================

        // ---------------------------------------------------------------------
        // is blood magic active?
        // ---------------------------------------------------------------------
        if (Ability_IsBloodMagic(oCreator))
        {
            int nBloodMagicVFX = 1519;
            float fMultiplier = 0.8f;
            if (GetHasEffects(oCreator, EFFECT_TYPE_BLOOD_MAGIC_BONUS) == TRUE)
            {
                fMultiplier = 0.6f;
            }

            fCost = fCost* fMultiplier;

            // NO need to check health for nightmare mode if using blood magic 
            // because they will die if they run out of health.
            // PrintToLog("Applying [" + ToString(fCost) + "] Blood damage to Caster for Ability [" + ToString(nAbility) + "]");

            // Effects_ApplyInstantEffectDamage expects positive value
            Effects_ApplyInstantEffectDamage(oCreator, oCreator, fCost, DAMAGE_TYPE_PLOT, DAMAGE_EFFECT_FLAG_UNRESISTABLE, nAbility, nBloodMagicVFX);
        }
        else
        {
            // For Nightmare, we stop damage protection when they run out of mana.
            if (difficulty > GAME_DIFFICULTY_HARD)
            {    
                float fMana = GetCurrentManaStamina(oCreator);
                if (fMana < fCost) 
                {
                    return FALSE;
                }
            }

            // Effect_InstantApplyEffectModifyManaStamina needs negative value
            // in this situation
            fCost = FloatToInt(fCost) * -1.0;
            // PrintToLog("Applying Mana damage to Caster [" + ToString(fCost) + "]");
            Effect_InstantApplyEffectModifyManaStamina(oCreator, fCost);
        }
        return TRUE;
    }

    void main()
    {
        event ev = GetCurrentEvent();
        int nEventType = GetEventType(ev);
        if (EVENT_TYPE_APPLY_EFFECT == GetEventType(ev))
        {
            //PrintToLog("Spell Shaping : EVENT_TYPE_APPLY_EFFECT");
            effect eEffect = GetCurrentEffect();
            int nEffectType = GetEffectType(eEffect);

            if (nEffectType == EFFECT_TYPE_DAMAGE || IsEffectTypeHostile(nEffectType))
            {
                //PrintToLog("Spell Shaping : EffectType [" + ToString(nEventType) + "] is Hostile");
                object oCreator = GetEffectCreator(eEffect);
                // object oTarget = OBJECT_SELF;
                if (IsObjectValid(oCreator) && IsObjectValid(OBJECT_SELF) && FALSE == IsDead(oCreator))
                {
                    //PrintToLog("Spell Shaping : oCreator and OBJECT_SELF are valid");
                    if (HasAbility(oCreator,SPELLSHAPING) && Ability_IsAbilityActive(oCreator, SPELLSHAPING))
                    {
                        if (!IsObjectHostile(OBJECT_SELF,oCreator))
                        {
                            // Easy      - No Mana Cost
                            // Normal    - 1 : 15%, 2 : 10%, 3 : 5%,  4 : No mana Cost
                            // Hard      - 1 : 30%, 2 : 25%, 3 : 20%, 4 : 15%
                            // Nightmare - 1 : 60%, 2 : 50%, 3 : 40%, 4 : 30%

                            int difficulty = GetGameDifficulty();
                            float manacost = 0.0;
                            float adjust = 0.05;
                            if (difficulty != GAME_DIFFICULTY_CASUAL)
                            {
                                manacost = 0.15;
                                if (difficulty == GAME_DIFFICULTY_HARD)
                                {
                                    manacost = 0.30;
                                }
                                else if (difficulty > GAME_DIFFICULTY_HARD)
                                {
                                    manacost = 0.60;
                                    adjust = 0.10;
                                }
                            }

                            if (HasAbility(oCreator,EXPERT_SPELLSHAPING))
                            {
                                manacost -= adjust;
                                manacost -= adjust;
                                if (HasAbility(oCreator,MASTER_SPELLSHAPING))
                                {
                                    manacost -= adjust;
                                }

                                // To have Master, you have to have Expert
                                // We handle both the same.

                                //PrintToLog("Spell Shaping : oCreator HasAbility EXPERT_SPELLSHAPING or MASTER_SPELLSHAPING. Ignoring Spell");
                                if (manacost > 0.0)
                                {
                                    // PrintToLog("manacost [" + ToString(manacost) + "] is > 0.0");
                                    float fDamage = GetEffectFloat(eEffect, 0);
                                    int nAbility = GetEffectAbilityID(eEffect);
                                    if (_handle_damage(difficulty, nAbility, manacost, fDamage, oCreator))
                                    {
                                        return;
                                    }
                                }
                                else
                                {
                                    return;
                                }

                            }
                            else
                            {
                                // To have Improved, you must also have SpellShapping.
                                // We handle both the same.
                                //PrintToLog("Spell Shaping : oCreator HasAbility SPELLSHAPING or IMPROVED_SPELLSHAPING");

                                if (TRUE == IsPartyMember(OBJECT_SELF))
                                {
                                    if (HasAbility(oCreator,IMPROVED_SPELLSHAPING))
                                    {
                                        manacost -= adjust;
                                    }
                                    if (manacost > 0.0)
                                    {
                                        // PrintToLog("manacost [" + ToString(manacost) + "] is > 0.0");
                                        float fDamage = GetEffectFloat(eEffect, 0);
                                        int nAbility = GetEffectAbilityID(eEffect);
                                        if (_handle_damage(difficulty, nAbility, manacost, fDamage, oCreator))
                                        {
                                            return;
                                        }
                                    }
                                    else
                                    {
                                        //PrintToLog("Spell Shaping : Target is Party Member. Ignoring Spell");
                                        return;
                                    }
                                }
                                else
                                {
                                    //PrintToLog("Spell Shaping : Target is NOT Party Member");
                                }
                            }
                        }
                        else
                        {
                            //PrintToLog("Spell Shaping : Caster and target are not hostile");
                        }
                    }
                    else
                    {
                        //PrintToLog("Spell Shaping : oCreator does not have spellshaping");
                    }
                }
                else
                {
                    //PrintToLog("Spell Shaping : oCreator and OBJECT_SELF are NOT valid");
                }
            }
            else
            {
                //PrintToLog("Spell Shaping : Effect Type [" + ToString(nEffectType) + "] is NOT Hostile");
            }
            //PrintToLog("Spell Shaping : Sending EVENT_TYPE_APPLY_EFFECT to default handler");
            HandleEvent(ev, R"rules_core.ncs");
        }
        else
        {
            //PrintToLog("Spell Shaping : Event is UNKNOWN");
            HandleEvent(ev, R"rules_core.ncs");
        }
    }
