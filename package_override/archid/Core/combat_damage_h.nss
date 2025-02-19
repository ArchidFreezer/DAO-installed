// -----------------------------------------------------------------------------
// combat_damage_h - Damage Include
// -----------------------------------------------------------------------------
/*
    Damage Utility Include

    Contains Damage calculation and resistance logic

*/
// -----------------------------------------------------------------------------
// Owner: Georg Zoeller
// -----------------------------------------------------------------------------

#include "core_h"
#include "2da_constants_h"
#include "effects_h"
#include "sys_disease"
#include "plt_cod_aow_spellcombo9"


const float DESTROYER_ARMOR_PENALTY = -5.0f;
const float DESTROYER_DURATION = 3.0f;
const int DESTROYER_VFX = 90065;

int Combat_ShatterCheck(object oCreature, object oCaster)
{
    int bShatter = FALSE;

    if (!IsCreatureBossRank(oCreature) && !IsPlot(oCreature) && !IsImmortal(oCreature))
    {
        int nDifficulty = GetGameDifficulty();
        if ((IsPartyMember(oCreature) == FALSE) || (nDifficulty >= GAME_DIFFICULTY_HARD))
        {
            float fChance = 1.0f;
            if (IsCreatureSpecialRank(oCreature) == TRUE)
            {
                if (nDifficulty == GAME_DIFFICULTY_CASUAL)
                {
                    fChance = 0.3;
                } else if (nDifficulty == GAME_DIFFICULTY_NORMAL)
                {
                    fChance = 0.2;
                } else if (nDifficulty == GAME_DIFFICULTY_HARD)
                {
                    fChance = 0.10f;
                } else // nightmare?
                {
                    fChance = 0.05f;
                }
            }
            float fRandom = RandomFloat();

            #ifdef DEBUG
            LogTrace(LOG_CHANNEL_COMBAT_ABILITY, "Shatter fChance = " + ToString(fChance));
            LogTrace(LOG_CHANNEL_COMBAT_ABILITY, "Shatter fRandom = " + ToString(fRandom));
            #endif

            if (fRandom < fChance)
            {
                effect[] ePetrify = GetEffects(oCreature, EFFECT_TYPE_PETRIFY);
                if (GetArraySize(ePetrify) > 0)
                {
                    if (GetCanDiePermanently(oCreature) == TRUE)
                    {
                        UI_DisplayMessage(oCreature, UI_MESSAGE_SHATTERED);

                        // play shattering vfx
                        effect eEffect;
                        if (GetEffectInteger(ePetrify[0], 0) == 1)
                        {
                            // creature
                            eEffect = EffectVisualEffect(90164);
                            ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oCreature, 0.0f, oCaster);
                        } else
                        {
                            // location
                            eEffect = EffectVisualEffect(90146);
                            Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_INSTANT, eEffect, GetLocation(oCreature), 0.0f, oCaster);

                            // creature
                            eEffect = EffectVisualEffect(90150);
                            ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oCreature, 0.0f, oCaster);
                        }

                        KillCreature(oCreature, oCaster);

                        bShatter = TRUE;

                        // combo effect codex - shattering
                        if (IsFollower(oCaster) == TRUE)
                        {
                            WR_SetPlotFlag(PLT_COD_AOW_SPELLCOMBO9, COD_AOW_SPELLCOMBO_9_SHATTER, TRUE);
                        }
                    }
                }
            }
        }
    }

    return bShatter;
}

float Combat_Damage_GetAbilityDamage(object oDamager, object oDamagee, float fBaseDamage, int nAbility)
{

    return fBaseDamage;
}




// damage, no weapon
float Combat_Damage_GetBaseDamage(object oAttacker, float fBaseMin = 0.0f, float fBaseMax = 0.0f)
{

    float fDmg = Combat_Damage_GetAttributeBonus(oAttacker, HAND_MAIN);
    return  fDmg;
}





float DmgGetArmorRating(object oDefender)
{
    float fAr =     GetCreatureProperty(oDefender,PROPERTY_ATTRIBUTE_ARMOR);
    // Armor is calculated 70 (fixed) /30 (random)
    float fArRolled  = (RandFF(fAr) * COMBAT_ARMOR_RANDOM_ELEMENT) + (fAr * (1.0f - COMBAT_ARMOR_RANDOM_ELEMENT ));

    object oArmor = GetItemInEquipSlot(INVENTORY_SLOT_CHEST, oDefender);

    #ifdef DEBUG
     _LogDamage("  fAr:  " + ToString(oArmor) + ":" + ToString(fArRolled) + " = " + ToString(fAr * 0.75) + " + Rand(" + ToString(fAr * 0.25) + ")");
    #endif

    return fArRolled;
}


float DmgGetArmorPenetrationRating (object oAttacker, object oWeapon)
{

    float fBase = GetItemStat(oWeapon,ITEM_STAT_ARMOR_PENETRATION) + GetCreatureProperty(oAttacker, PROPERTY_ATTRIBUTE_AP);

    if (IsMeleeWeapon2Handed(oWeapon))
    {
        // -----------------------------------------------------------------
        // STRONG: Armor Rating
        // -----------------------------------------------------------------
        if (HasAbility(oAttacker,ABILITY_TALENT_STRONG))
        {
            #ifdef DEBUG
            _LogDamage("  fAP: (Modified +25% by TALENT_STRONG) ");
            #endif
            fBase *= 1.25;
        }
    }


    return fBase;
}


float DmgGetArmorMitigatedDamage(float fDamage, float fArmorPenetration, object oDefender)
{
    return MaxF(0.0, fDamage - MaxF(0.0, DmgGetArmorRating(oDefender) - fArmorPenetration));
}


float GetCriticalDamageModifier(object oAttacker)
{
    return COMBAT_CRITICAL_DAMAGE_MODIFIER + (GetCreatureProperty(oAttacker, 54 /*PROPERTY_ATTRIBUTE_CRITICAL_RANGE*/) / 100.0);
}

float Combat_Damage_GetBackstabDamage(object oAttacker, object oWeapon, float fDamage)
{

    //  ------------------------------------------------------------------------
    // Each backstab is an auto crit.
    //  ------------------------------------------------------------------------
    fDamage *= GetCriticalDamageModifier(oAttacker);


    // -------------------------------------------------------------------------
    // Exploit Weakness:  Backstab Damage = Int / 3
    // -------------------------------------------------------------------------
    if (HasAbility(oAttacker,ABILITY_TALENT_EXPLOIT_WEAKNESS))
    {
        float fBase = MaxF(0.0,(GetAttributeModifier(oAttacker,PROPERTY_ATTRIBUTE_INTELLIGENCE)/3.0)) ;
        float fMod = MaxF(0.2,RandomFloat());
        fDamage += (fBase * fMod);
    }

    // GXA Override
    if (HasAbility(oAttacker, 401312) == TRUE) // GXA Deep Striking
    {
        if (IsModalAbilityActive(oAttacker, 401310) == TRUE) // GXA Shadow Striking
        {
            fDamage *= 1.5f;
        }
    }
    // GXA Override

    return fDamage;
}



float Combat_Damage_GetTalentBoni(object oAttacker, object oDefender, object oWeapon)
{

    float fBase = 0.0;


    if (HasAbility(oAttacker, ABILITY_TALENT_SHATTERING_BLOWS))
    {
        if (IsObjectValid(oDefender))
        {
            if (GetCreatureAppearanceFlag(oDefender, APR_RULES_FLAG_CONSTRUCT))
            {
                if ( IsUsingMeleeWeapon(oAttacker, oWeapon) &&  IsMeleeWeapon2Handed(oWeapon))
                {
                    fBase += (GetAttributeModifier(oAttacker, PROPERTY_ATTRIBUTE_STRENGTH) * 0.5f);
                }
            }
        }
    }

    if (IsModalAbilityActive(oAttacker, ABILITY_TALENT_BLOOD_FRENZY))
    {
        float fMod = (10.0 *  MaxF(0.0,1.0 - _GetRelativeResourceLevel(oAttacker, PROPERTY_DEPLETABLE_HEALTH)));
        #ifdef DEBUG
        _LogDamage("-- BLOOD_FRENZY DAMAGE BONUS: "  + ToString(fMod));
        #endif

        fBase += fMod;
    }


    return fBase;
}



float Combat_Damage_GetAttackDamage(object oAttacker, object oTarget, object oWeapon, int nAttackResult, float fArmorPenetrationBonus = 0.0, int bForceMaxWeaponDamage = FALSE, int bDoubleAttBonus = FALSE)
{

    int nHand = HAND_MAIN;
    int nSlot = GetItemEquipSlot(oWeapon);

    // -------------------------------------------------------------------------
    // special case: one hit kill forms generally don't do damage...
    // -------------------------------------------------------------------------
    if (IsShapeShifted(oAttacker))
    {
        if (GetM2DAInt(TABLE_APPEARANCE,"OneShotKills", GetAppearanceType(oAttacker)))
        {
            return 1.0f;
        }
    }

    if (IsObjectValid(oWeapon))
    {
        if (nSlot == INVENTORY_SLOT_MAIN || nSlot == INVENTORY_SLOT_BITE)
        {
            nHand = HAND_MAIN;
        }
        else if (nSlot == INVENTORY_SLOT_OFFHAND)
        {
            nHand = HAND_OFFHAND;
        }

        // Mage staffs have their own rules
        if (nAttackResult != COMBAT_RESULT_DEATHBLOW && GetBaseItemType(oWeapon) == BASE_ITEM_TYPE_STAFF)
        {
            if (!GetHasEffects(oAttacker, EFFECT_TYPE_SHAPECHANGE))
            {
                return Combat_Damage_GetMageStaffDamage(oAttacker, oTarget,oWeapon);
            }
            else
            {
                oWeapon = OBJECT_INVALID;
            }
        }

    }

    // Weapon Attribute Bonus Factor
    float fFactor =     GetWeaponAttributeBonusFactor(oWeapon);

    // Attribute Modifier
    float fStrength = Combat_Damage_GetAttributeBonus(oAttacker, nHand, oWeapon) * fFactor;
    if (bDoubleAttBonus == TRUE)
    {
        fStrength *= 2.0f;
    }

    // Weapon Damage
    float fWeapon   =   IsObjectValid(oWeapon)? DmgGetWeaponDamage(oWeapon,bForceMaxWeaponDamage) : COMBAT_DEFAULT_UNARMED_DAMAGE ;

    // Game Difficulty Adjustments
    float fDiffBonus =  Diff_GetRulesDamageBonus(oAttacker);


    float fDamage   =   fWeapon + fStrength + fDiffBonus ;
    float fDamageScale = GetM2DAFloat(TABLE_AUTOSCALE,"fDamageScale", GetCreatureRank(oAttacker));

    float fAr       =   DmgGetArmorRating(oTarget);

    // GXA Override
    if (HasAbility(oAttacker, 401101) == TRUE) // GXA Spirit Damage
    {
        if (IsModalAbilityActive(oAttacker, 401100) == TRUE) // GXA Spirit Warrior
        {
            // bypass armor for normal attacks
            fAr = 0.0f;
        }
    }
    // GXA Override

    float fAp       =   DmgGetArmorPenetrationRating(oAttacker, oWeapon) + fArmorPenetrationBonus;
    float fDmgBonus =   GetCreatureProperty(oAttacker, PROPERTY_ATTRIBUTE_DAMAGE_BONUS);





    #ifdef DEBUG
    _LogDamage("Total: "  + ToString(fDamage), oTarget);
    _LogDamage("  fStrength: "  + ToString(fStrength));
    _LogDamage("  fWeapon  : "  + ToString(fWeapon));
    _LogDamage("  fDmgBonus: "  + ToString(fDmgBonus));
    _LogDamage("        fAr: "  + ToString(fAr));
    _LogDamage("        fAp: "  + ToString(fAp));
    _LogDamage(" fRankScale: "  + ToString(fDamageScale));
    #endif


    if (nAttackResult == COMBAT_RESULT_CRITICALHIT)
    {
        fDamage *= GetCriticalDamageModifier(oAttacker);
        #ifdef DEBUG
        _LogDamage("Crit:        "  + ToString(fDamage));
        #endif
    }
    else if (nAttackResult == COMBAT_RESULT_BACKSTAB)
    {
        fDamage = Combat_Damage_GetBackstabDamage(oAttacker,oWeapon, fDamage);
        #ifdef DEBUG
        _LogDamage("Backstab:        "  + ToString(fDamage));
        #endif
    }
    else if (nAttackResult == COMBAT_RESULT_DEATHBLOW)
    {
        fDamage = GetMaxHealth(oTarget)+1.0f;
        #ifdef DEBUG
        _LogDamage("Deathblow damage:"  + ToString(fDamage));
        #endif
    }

    fDamage = fDamage - MaxF(0.0f,fAr - fAp);

    fDamage += fDmgBonus + Combat_Damage_GetTalentBoni(oAttacker, oTarget, oWeapon);


    // -------------------------------------------------------------------------
    // Damage scale only kicks in on 'significant' damage.
    // -------------------------------------------------------------------------
    if (fDamageScale >0.0 && fDamage> GetDamageScalingThreshold() )
    {
        fDamage *= fDamageScale;
    }

    // -------------------------------------------------------------------------
    // Weapon damage is always at least 1, even with armor. This is intentional
    // to avoid deadlocks of creatures that are both unable to damage each other
    // -------------------------------------------------------------------------
    fDamage = MaxF(1.0f,fDamage);



    return (fDamage);
}




void Combat_Damage_CheckOnImpactAbilities(object oTarget, object oDamager, float fDamage,  int nAttackResult, object oWeapon, int nAbility)
{


    if (nAbility != 0)
    {

    }


    // -------------------------------------------------------------------------
    // Some passive abilities grant 'to hit' effects...
    // -------------------------------------------------------------------------
    if (nAttackResult == COMBAT_RESULT_CRITICALHIT)
    {
/*
        if (!IsCreatureBossRank(oTarget) && !IsImmortal(oTarget) && !IsPlot(oTarget))
        {
            // ---------------------------------------------------------------------
            // Petrified creatures that are hit by
            // ---------------------------------------------------------------------
            if (GetHasEffects(oTarget, EFFECT_TYPE_PETRIFY))
            {
                if (GetCanDiePermanently(oTarget))
                {
                    UI_DisplayMessage(oTarget,UI_MESSAGE_SHATTERED);
                    KillCreature(oTarget, oDamager);
                    return;
                }
            }
        }*/

        if (Combat_ShatterCheck(oTarget, oDamager) == TRUE)
        {
            return;
        }



        if (IsMeleeWeapon2Handed(oWeapon))
        {
            if (HasAbility(oDamager, ABILITY_TALENT_STUNNING_BLOWS))
            {
                // ~50%
                if(RandomFloat()<0.5)
                {
                    if (!GetHasEffects(oTarget, EFFECT_TYPE_STUN))
                    {
                        Engine_ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, EffectStun(),oTarget,1.5f + (RandomFloat()*2.5),oDamager,ABILITY_TALENT_STUNNING_BLOWS);
                        #ifdef DEBUG
                        _LogDamage("DAMAGE-Combat-Efffect: STUNNING_BLOWS");
                        #endif

                     }
                }
            }


            if (HasAbility(oDamager, ABILITY_TALENT_DESTROYER))
            {
                // Can not stack temporary effects on hit, might cause runaway memory usage in high speed attack situations
                if (!GetHasEffects(oTarget, EFFECT_TYPE_MODIFY_PROPERTY,ABILITY_TALENT_DESTROYER ))
                {

                    effect eDebuff = EffectModifyProperty(PROPERTY_ATTRIBUTE_ARMOR, DESTROYER_ARMOR_PENALTY);
                    eDebuff = SetEffectEngineInteger(eDebuff, EFFECT_INTEGER_VFX, DESTROYER_VFX);
                    Engine_ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eDebuff, oTarget, DESTROYER_DURATION, oDamager, ABILITY_TALENT_DESTROYER);

                    #ifdef DEBUG
                    _LogDamage("DAMAGE-Combat-Efffect: ABILITY_TALENT_DESTROYER");
                    #endif
                }

            }
        }    /* using 2 h weapon*/

    } /* crit*/

    // -------------------------------------------------------------------------
    // Any significant results in additional bleeding equivalent to 25% of damage
    // over 4 seconds on a backstab
    // -------------------------------------------------------------------------
    else if (nAttackResult == COMBAT_RESULT_BACKSTAB)
    {
        if ((fDamage>=10.0) && IsModalAbilityActive(oDamager, ABILITY_TALENT_LACERATE))
        {
            // Can not stack temporary effects on hit, might cause runaway memory usage in high speed attack situations
            if (!GetHasEffects(oTarget, EFFECT_TYPE_DOT,ABILITY_TALENT_LACERATE ))
            {
                ApplyEffectDamageOverTime(oTarget, oDamager,ABILITY_TALENT_LACERATE, fDamage*0.25,4.0f, DAMAGE_TYPE_PHYSICAL);
            }
        }
    }





}      /* func*/