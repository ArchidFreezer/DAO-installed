// -----------------------------------------------------------------------------
// effect_damage_h
// -----------------------------------------------------------------------------
/*

    This file is the SINGLE POINT OF ENTRY for all health modification in the
    game.


    Limited Editing Permissions: Only Georg edits this file.

*/
// -----------------------------------------------------------------------------
// Owner: Georg Zoeller
// -----------------------------------------------------------------------------

#include "2da_constants_h"
#include "sys_gore_h"
#include "events_h"
//#include "wrappers_h"
#include "ui_h"

#include "stats_core_h"

//------------------------------------------------------------------------------
// Include Effects we are dependent on
//------------------------------------------------------------------------------
#include "effect_death_h"
#include "effect_heal_h"
#include "effect_modify_mana_stam_h"
#include "sys_stealth_h"
#include "sys_resistances_h"

const int ANIMATION_DAMAGE_ADDITIVE = 103;

const int DAMAGE_EFFECT_FLAG_NONE        = 0x00000000 ;
const int DAMAGE_EFFECT_FLAG_CRITICAL    = 0x00000001; //critical hit
const int DAMAGE_EFFECT_FLAG_DEATHBLOW   = 0x00000002; //death blow
const int DAMAGE_EFFECT_FLAG_UPDATE_GORE = 0x00000004; //update gore on attacker
const int DAMAGE_EFFECT_FLAG_LEECH_50    = 0x00000008; //leech 50% health back to attacker
const int DAMAGE_EFFECT_FLAG_LEECH_75    = 0x00000010; //leech 75% health back to attacker
const int DAMAGE_EFFECT_FLAG_LEECH_100   = 0x00000020; //leech 100% health back to attacker
const int DAMAGE_EFFECT_FLAG_LEECH_MANA    = 0x00000040; // mana is leeched instead of health
const int DAMAGE_EFFECT_FLAG_UNRESISTABLE  = 0x00000080; // can not be resisted
const int DAMAGE_EFFECT_FLAG_BACKSTAB      = 0x00000100; // backstab
const int DAMAGE_EFFECT_FLAG_LEECH_25      = 0x00000200; //leech 20% health back to attacker
const int DAMAGE_EFFECT_FLAG_BONUS_DMG      = 0x00000400; //'bonus' damage (different message) from item property.
const int DAMAGE_EFFECT_FLAG_FROM_DOT       = 0x00000800; //coming from dots.
const int DAMAGE_EFFECT_FLAG_NOLEECH        = 0x00001000; //convert leech into simple 'also deal damage'

const float DAMAGE_CRITICAL_DISPLAY_THRESHOLD = 10.0f; // any damage below this will not show up as critical (even though it is handled internally as such)
const float DAMAGE_IMMUNITY_MESSAGE_THRESHOLD = 8.0f;

const float LIFEWARD_HEALTH_FRACTION = 0.33;
const int   LIFEWARD_HEALING_VFX = 1021;

const int FEAST_OF_THE_FALLEN_VFX = 90011;


/*

// -----------------------------------------------------------------------------
// Damage Types
// -----------------------------------------------------------------------------
const int DAMAGE_TYPE_INVALID                       = 0;
const int DAMAGE_TYPE_PHYSICAL                      = 1;
const int DAMAGE_TYPE_FIRE                          = 2;
const int DAMAGE_TYPE_COLD                          = 3;
const int DAMAGE_TYPE_ELECTRICITY                   = 4;
const int DAMAGE_TYPE_POISON                        = 5;
const int DAMAGE_TYPE_LETHAL                        = 6;
const int DAMAGE_TYPE_TBD                           = 7;  //debug

*/



int IsHostileEffectAllowed(object oTarget, object oDamager, int nAbility)
{

    int bValid = TRUE;

    if (GetObjectType(oDamager) == OBJECT_TYPE_CREATURE)
    {
        if (!IsObjectHostile(oTarget, oDamager))
        {
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE,"effect_damage_h.IsHostileEffectAllowed","Damager and Target not hostile: false");
            #endif
            bValid = FALSE;
        }
    }
    else
    {
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE,"effect_damage_h.IsHostileEffectAllowed","Damager is a placeable, skipping hostility checks");
        #endif
        return TRUE;
    }

    // -----------------------------------------------------------------
    // Abilities by default don't care for hostilities
    // -----------------------------------------------------------------
    if (nAbility != 0)
    {
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE,"effect_damage_h.IsHostileEffectAllowed","Ability: true");
        #endif
        bValid = TRUE;
    }


    // -----------------------------------------------------------------
    // Neutrals can never be damaged...
    // -----------------------------------------------------------------
    if (GetGroupId(oTarget) == GROUP_NEUTRAL)
    {
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE,"effect_damage_h.IsHostileEffectAllowed","Neutral Group: false");
        #endif
        // Can harm self
        if (oTarget != oDamager)
        {
            bValid = FALSE;
        }
    }

    // -----------------------------------------------------------------
    // Non combatants don't get damaged either
    // -----------------------------------------------------------------
    if (GetCombatantType(oTarget) == CREATURE_TYPE_NON_COMBATANT)
    {
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE,"effect_damage_h.IsHostileEffectAllowed","Non Combatant: false");
        #endif

        // Can harm self
        if (oTarget != oDamager)
        {
            bValid = FALSE;
        }
    }

    return bValid;
}



int IsFriendlyFireParty(object oTarget, object oDamager)
{
    // verify same group id
    if (GetGroupId(oTarget) == GetGroupId(oDamager))
    {
        // Only for party members, since this is a difficulty option. Monsters still can nuke each other
        if (IsPartyMember(oTarget))
        {
            return TRUE;
        }
    }
    return FALSE;
}

int IsDamageAllowed(object oTarget, object oDamager, int nAbility, int nDamageType, int nDamageFlags =0)
{

     if (GetObjectType(oDamager) != OBJECT_TYPE_CREATURE)
     {
        return TRUE;
     }


     // ------------------------------------------------------------------------
     // No dealing damage in cutscene or dialog unless damage type is plot
     // ------------------------------------------------------------------------
     if (nDamageType != DAMAGE_TYPE_PLOT)
     {
        int nMode = GetGameMode();


        if (nMode == GM_CUTSCENE || nMode == GM_DIALOG)
        {
          #ifdef DEBUG
          Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE,"effect_damage_h.IsDamageAllowed","Game mode is CUTSCENE or DIALOG and damage type is not PLOT - not allowing damage");
          #endif
          return FALSE;
        }

        // ---------------------------------------------------------------------
        // DIFFICULTY: No friendly fire in easy difficulty
        // ---------------------------------------------------------------------
        if (GetGameDifficulty() == GAME_DIFFICULTY_CASUAL)
        {
            int bUnresistable = (nDamageFlags &  DAMAGE_EFFECT_FLAG_UNRESISTABLE) == DAMAGE_EFFECT_FLAG_UNRESISTABLE;
            int bDot = (nDamageFlags &  DAMAGE_EFFECT_FLAG_FROM_DOT) == DAMAGE_EFFECT_FLAG_FROM_DOT;

            // Unresistable damage still gets through, unless it's from a dot
            if (!bUnresistable || bDot)
            {
                if (IsFriendlyFireParty(oTarget,oDamager))
                {
                    #ifdef DEBUG
                      Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE,"effect_damage_h.IsDamageAllowed",
                        "Easy Difficulty, Not allowing damage between members of the player's party");
                    #endif

                    return FALSE;
                }
            }

        }
        // ---------------------------------------------------------------------
        // DIFFICULTY END
        // ---------------------------------------------------------------------


     }


     int bValid = TRUE;


     if (IsObjectValid(oDamager) && GetObjectType(oDamager) == OBJECT_TYPE_CREATURE )
     {

        // ---------------------------------------------------------------------
        // Only creatures care about hostility settings
        // ---------------------------------------------------------------------
        if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
        {
           bValid = bValid &&IsHostileEffectAllowed(oTarget, oDamager, nAbility);
        }
     }

    // -----------------------------------------------------------------
    // ... neither can plot objects.
    // -----------------------------------------------------------------
    if (IsPlot(oTarget))
    {
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE,"effect_damage_h.IsDamageAllowed","Plot:" + ToString(oTarget) +" - true: False");
        #endif

        bValid = FALSE;
    }

    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE,"effect_damage_h.IsDamageAllowed","Result:" + ToString(bValid));
    #endif

    return bValid;
}




float GetModifiedDamage(object oDamager, int nDamageType, float fAmount)
{

    int nProperty = 0;

    switch (nDamageType)
    {
        case        DAMAGE_TYPE_FIRE:
                        nProperty = PROPERTY_ATTRIBUTE_FIRE_DAMAGE_BONUS;
                        break;
        case        DAMAGE_TYPE_ELECTRICITY:
                        nProperty = PROPERTY_ATTRIBUTE_ELECTRICITY_DAMAGE_BONUS;
                        break;
        case        DAMAGE_TYPE_SPIRIT:
                        nProperty = PROPERTY_ATTRIBUTE_SPIRIT_DAMAGE_BONUS;
                        break;
        case        DAMAGE_TYPE_NATURE:
                        nProperty = PROPERTY_ATTRIBUTE_NATURE_DAMAGE_BONUS;
                        break;
        case        DAMAGE_TYPE_COLD:
                        nProperty = PROPERTY_ATTRIBUTE_COLD_DAMAGE_BONUS;
                        break;

    }

    if (nProperty)
    {
        float fMultiplier = 1.0f  + (GetCreatureProperty(oDamager, nProperty) / 100.0f);
        return fAmount * fMultiplier;
    }


    return fAmount;

}



//===========================================================================//
//                              Effect Damage                                //
//===========================================================================//

/*
* @brief Instant Damage - Inline version of EffectDamage
*
*
*
* @author Georg
*/
int  Effects_ApplyInstantEffectDamage(object oTarget, object oDamager, float fDamage, int nDamageType = DAMAGE_TYPE_PHYSICAL, int nDamageFlags = DAMAGE_EFFECT_FLAG_NONE, int nAbility = 0, int nImpactVfx = 0 )
{

    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_EFFECTS,"effect_damage_h.Effects_ApplyInstantEffectDamage","damage:" +  FloatToString(fDamage) + " flags: " + IntToHexString(nDamageFlags) + " abi: " + ToString(nAbility) + ", current health: " + IntToString(GetHealth(oTarget)), oTarget);
    #endif

    float fOldHealth = GetCurrentHealth(oTarget);
    int bReturn = FALSE;
    int bFatal = FALSE;

    // GXA Override
    if (nDamageType == DAMAGE_TYPE_PHYSICAL)
    {
        if (HasAbility(oDamager, 401101) == TRUE) // GXA Spirit Damage
        {
            if (IsModalAbilityActive(oDamager, 401100) == TRUE) // GXA Spirit Warrior
            {
                // normal physical damage is converted to spirit damage
                nDamageType = DAMAGE_TYPE_SPIRIT;
            }
        }
    }
    // GXA Override

    if (!IsDamageAllowed(oTarget, oDamager, nAbility, nDamageType, nDamageFlags))
    {
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE,"effect_damage_h.Effects_ApplyInstantEffectDamage","Damage nullified, target creature does not meet valid target requirements.");
        #endif
        fDamage = 0.0f;
    }




    if (nDamageType != DAMAGE_TYPE_PHYSICAL && nDamageType != DAMAGE_TYPE_PLOT)
    {
        fDamage = GetModifiedDamage(oDamager, nDamageType, fDamage);

    }

    // -------------------------------------------------------------------------
    // Mana Shield: Take 1.5x the damage in mana. Reduce damage by the amount
    // reduced.
    // -------------------------------------------------------------------------
    if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
    {
        if (fDamage >= 1.0f)
        {
            if (nDamageType != DAMAGE_TYPE_PLOT && GetHasEffects(oTarget, EFFECT_TYPE_MANA_SHIELD))
            {
                float fMana = GetCreatureProperty(oTarget, PROPERTY_DEPLETABLE_MANA_STAMINA);

                // GXA Override
                effect[] eEffects = GetEffects(oTarget, EFFECT_TYPE_MANA_SHIELD);
                float fManaFactor = GetEffectFloat(eEffects[0], 0);
                if (fManaFactor <= 0.0f) // default
                {
                    fManaFactor = 1.5f;
                }
                float fManaDamage = MinF(fDamage * fManaFactor, fMana);
                // GXA Override

                UpdateCreatureProperty(oTarget, PROPERTY_DEPLETABLE_MANA_STAMINA,fManaDamage * -1.0f, PROPERTY_VALUE_CURRENT);
                UI_DisplayDamageFloaty(oTarget, oDamager, FloatToInt(fManaDamage), 1, 0, 0, 1);

                // GXA Override
                float fDamageFactor = GetEffectFloat(eEffects[0], 1);
                if (fDamageFactor <= 0.0f) // default
                {
                    fDamageFactor = 0.75f;
                }
                fDamage = MaxF(0.0f, fDamage - (fManaDamage * fDamageFactor));
                // GXA Override

                #ifdef DEBUG
                    Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE,"effect_damage_h.Effects_ApplyInstantEffectDamage","Damage aborbed by mana shield. Remaining Damage "+ ToString(fDamage));
                #endif

                if (fDamage < 1.0f)
                {
                    return TRUE;
                }
            }
        }
    }


    // -------------------------------------------------------------------------
    // DIFFICULTY: 50% friendly fire in normal difficulty
    // -------------------------------------------------------------------------
    if ((GetGameDifficulty() == GAME_DIFFICULTY_NORMAL) && nDamageType != DAMAGE_TYPE_PLOT)
    {
        if (GetObjectType(oDamager) == OBJECT_TYPE_CREATURE)
        {
            // Unresistable damage still gets through
            int bUnresistable = (nDamageFlags &  DAMAGE_EFFECT_FLAG_UNRESISTABLE) == DAMAGE_EFFECT_FLAG_UNRESISTABLE;
            int bDot = (nDamageFlags &  DAMAGE_EFFECT_FLAG_FROM_DOT) == DAMAGE_EFFECT_FLAG_FROM_DOT;

            if (!bUnresistable || bDot)
            {
                if (IsFriendlyFireParty(oTarget,oDamager))
                {

                    DEBUG_PrintToScreen("BBB2",5);

                    #ifdef DEBUG
                      Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE,"effect_damage_h.Effects_ApplyInstantEffectDamage", "Medium Difficulty, scaling FF back to 50%");
                    #endif

                    fDamage *= 0.5;
                }
            }

        }
    }
    // -------------------------------------------------------------------------
    // DIFFICULTY END
    // -------------------------------------------------------------------------





    // -------------------------------------------------------------------------
    // Creatures may have damage shield or scale
    // -------------------------------------------------------------------------
    if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
    {
        float fScale =  GetCreatureProperty(oTarget,PROPERTY_ATTRIBUTE_DAMAGE_SCALE);
        if (fScale >1.0f)
        {
            fDamage *= fScale;
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE,"effect_damage_h","Increase through DAMAGE VULNERABILITY EFFECT: x" + ToString(fScale),oTarget);
            #endif
        }

        // damage shield
        float fShieldPoints = GetCreatureProperty(oTarget, PROPERTY_ATTRIBUTE_DAMAGE_SHIELD_POINTS);
        if (fShieldPoints > 0.0f)
        {
            float fReduction;

            // if shield has a strength, that is the maximum amount deducted
            float fShieldStrength = GetCreatureProperty(oTarget,PROPERTY_ATTRIBUTE_DAMAGE_SHIELD_STRENGTH);
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE, "effect_damage_h", "fShieldPoints = " + ToString(fShieldPoints), oTarget);
            Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE, "effect_damage_h", "fShieldStrength = " + ToString(fShieldStrength), oTarget);
            #endif
            if (fShieldStrength > 0.0f)
            {
                fReduction = MinF(fShieldPoints, fShieldStrength);
            } else
            {
                fReduction = fShieldPoints;
            }

            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE, "effect_damage_h", "Reduction through DAMAGE SHIELD: " + ToString(fReduction), oTarget);
            #endif
            if (fReduction >= fDamage)
            {
                UpdateCreatureProperty(oTarget,PROPERTY_ATTRIBUTE_DAMAGE_SHIELD_POINTS, (fDamage * -1.0f), PROPERTY_VALUE_MODIFIER);
                
                // AB: this has to be AFTER subtracting fDamage from shield points
                // otherwise we're just subtracting 0...
                fDamage = 0.0f;

                #ifdef DEBUG
                Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE, "effect_damage_h", "  Reducing damage to 0", oTarget);
                #endif
            } else
            {
                fDamage -= fReduction;

                if (fReduction >= fShieldPoints)
                {
                    SetCreatureProperty(oTarget, PROPERTY_ATTRIBUTE_DAMAGE_SHIELD_POINTS, 0.0f, PROPERTY_VALUE_MODIFIER);

                    #ifdef DEBUG
                    Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE, "effect_damage_h", "  Reducing shield to 0", oTarget);
                    #endif
                } else
                {
                    UpdateCreatureProperty(oTarget, PROPERTY_ATTRIBUTE_DAMAGE_SHIELD_POINTS, (fReduction * -1.0f), PROPERTY_VALUE_MODIFIER);

                    #ifdef DEBUG
                    Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE, "effect_damage_h", "  Reducing damage by reduction", oTarget);
                    #endif
                }
            }

            #ifdef DEBUG
            fShieldPoints = GetCreatureProperty(oTarget, PROPERTY_ATTRIBUTE_DAMAGE_SHIELD_POINTS);
            Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE, "effect_damage_h", "Remaining DAMAGE SHIELD: " + ToString(fShieldPoints - fReduction), oTarget);
            #endif
       }
    }



    if ((nDamageFlags &  DAMAGE_EFFECT_FLAG_UNRESISTABLE) == DAMAGE_EFFECT_FLAG_UNRESISTABLE)
    {
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE,"effect_damage_h.Effects_ApplyInstantEffectDamage","Damage flagged as unresistable!");
        #endif
    }
    else
    {
        if (fDamage > 0.0f)
        {

            // -------------------------------------------------------------------------
            // Handle Damage Immunity
            // -------------------------------------------------------------------------
            if (DamageIsImmuneToType(oTarget, nDamageType))
            {
                  if (GetObjectType(oTarget) != OBJECT_TYPE_PLACEABLE)
                  {
                      // -------------------------------------------------------
                      // Only message immunity if a PC is involved
                      // -------------------------------------------------------
                      if (IsPartyMember(oTarget) || IsPartyMember(oDamager))
                      {
                          if  (fDamage>DAMAGE_IMMUNITY_MESSAGE_THRESHOLD)
                          {
                             UI_DisplayMessage(oTarget,  UI_MESSAGE_IMMUNE,"", GetColorByDamageType(nDamageType));
                          }
                      }
                  }
                  return TRUE;
            }
            else if (GetHasEffects(oTarget,EFFECT_TYPE_DAMAGE_WARD))
            {
                // -------------------------------------------------------
                // Only message immunity if a PC is involved
                // -------------------------------------------------------
                if (IsPartyMember(oTarget) || IsPartyMember(oDamager))
                {
                    UI_DisplayMessage(oTarget, UI_MESSAGE_NO_EFFECT);

                    if (IsPartyMember(oDamager))
                    {
                         PlaySoundSet(oDamager,SS_COMBAT_WEAPON_INEFFECTIVE, 0.3f);
                    }
                }



                #ifdef DEBUG
                Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE,"effect_damage_h", ToString(oTarget) +" DAMAGE ZEROED because of DAMAGE_WARD_EFFECT") ;
                #endif
                return TRUE;
            }
            else
            {
                // -------------------------------------------------------------------------
                // Resist and nullify negative damage
                // -------------------------------------------------------------------------
                fDamage = ResistDamage(oDamager, oTarget, nAbility, fDamage,nDamageType);
            }
        }
    }





    if (GetHasEffects(oTarget, EFFECT_TYPE_LIFE_WARD))
    {
        if ((fOldHealth - fDamage) < (GetMaxHealth(oTarget)* LIFEWARD_HEALTH_FRACTION))
        {

            // play healing vfx
            // ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, EffectVisualEffect(LIFEWARD_HEALING_VFX), oTarget, 0.0f, oTarget, ABILITY_SPELL_LIFEWARD));
            effect[] aWards = GetEffects(oTarget, EFFECT_TYPE_LIFE_WARD);
            float fWardHealth = GetEffectFloat(aWards[0],0);
            Effect_ApplyInstantEffectHeal(oTarget,GetEffectCreator(aWards[0]), fWardHealth);
            RemoveEffect(oTarget,aWards[0]);
            fOldHealth = GetCurrentHealth(oTarget);
        }
    }

    // -------------------------------------------------------------------------
    // Calculate the new health
    // -------------------------------------------------------------------------
    float fNewHealth = fOldHealth - fDamage;




    float fFloatyValue = IntToFloat(FloatToInt(fDamage));
    // -------------------------------------------------------------------------
    // Anything lower than 1.0 is treated as 0
    // -------------------------------------------------------------------------
    if ( FloatToInt(fNewHealth) < 1)
    {
        if ( IsImmortal(oTarget) && GetObjectType(oTarget) == OBJECT_TYPE_CREATURE )
        {
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE,"effect_damage_h","Immortal Target, fatal damage changed to nonfatal",oTarget);
            #endif

            UI_DisplayMessage(oTarget, UI_DEBUG_CREATURE_IMMORTAL);

            fNewHealth = 1.0f;
            fFloatyValue = 0.0f;
        }
        else
        {
            fNewHealth = 0.0f;
            bFatal = TRUE;
        }
    }

    // -------------------------------------------------------------------------
    // Edge case due to fractions.
    // -------------------------------------------------------------------------
    if (fDamage>0.0f && fDamage <1.0f)
    {
        fDamage = 1.0f;
        fFloatyValue = 1.0f;
    }





    // -------------------------------------------------------------------------
    // Display the damage floaty
    // -------------------------------------------------------------------------
    int bBonusDamage = ((nDamageFlags & DAMAGE_EFFECT_FLAG_BONUS_DMG) == DAMAGE_EFFECT_FLAG_BONUS_DMG);
    int bBackstab    = ((nDamageFlags &  DAMAGE_EFFECT_FLAG_BACKSTAB) == DAMAGE_EFFECT_FLAG_BACKSTAB);
    int bCritical    = ((((nDamageFlags &  DAMAGE_EFFECT_FLAG_CRITICAL) == DAMAGE_EFFECT_FLAG_CRITICAL) || bBackstab) && fFloatyValue>=DAMAGE_CRITICAL_DISPLAY_THRESHOLD);
    int bDeathblow   = ((nDamageFlags &  DAMAGE_EFFECT_FLAG_DEATHBLOW) == DAMAGE_EFFECT_FLAG_DEATHBLOW);

    UI_DisplayDamageFloaty(oTarget, oDamager, FloatToInt(fFloatyValue),
                           bCritical, nAbility, bBonusDamage, 0, bBackstab, nDamageType );


    // -------------------------------------------------------------------------
    // Only proceed if there's actually damage dealt.
    // -------------------------------------------------------------------------
    if (fDamage > 0.0f)
    {


        if ( fNewHealth < fOldHealth)
        {


            // -------------------------------------------------------------------------
            // Set the new health for non-fatal blows
            // If the blow is fatal, then the health will be lowered when the target dies (applies the death effect)
            // This is needed since the engine considers a target as 'dead' when it's health is 0.
            // -------------------------------------------------------------------------
            if ( !bFatal)
            {

                #ifdef DEBUG
                Log_Trace(LOG_CHANNEL_EFFECTS,"effect_damage_h.Effects_ApplyInstantEffectDamage","damage:" +  FloatToString(fDamage) + " flags: " + IntToHexString(nDamageFlags) + " setting health to: " + FloatToString(fNewHealth), oTarget);
                #endif



                // -------------------------------------------------------------
                // THIS IS THE ONLY SINGLE POINT IN GAME THAT MODIFIES HEALTH
                // IN THE GAME AFTER CHARACTER GENERATION!
                // -------------------------------------------------------------
                SetCurrentHealth(oTarget,fNewHealth);

                // -------------------------------------------------------------
                // Notify the UI system to indicate damage to a party member
                // -------------------------------------------------------------
                if(GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
                    SignalDamage(oDamager,oTarget);

                // -------------------------------------------------------------
                // It really makes only sense to send OnDamage if you're not
                // getting OnDeath the next frame, so this is signalled here.
                // -------------------------------------------------------------
                SendEventOnDamaged(oTarget, oDamager, fDamage, nDamageType, nAbility );

            }

            bReturn = TRUE;
        }
        else
        {
            return FALSE;
        }




        if (GetObjectType(oTarget) ==  OBJECT_TYPE_CREATURE)
        {

            // Stats - handle damage dealt
            STATS_HandleDamageDealt(oDamager, oTarget, fDamage);

            // ---------------------------------------------------------------------
            // Allow some of the soundsets to play again
            // ---------------------------------------------------------------------
            SSResetSoundsetRestrictionsOnDamage(oTarget, fOldHealth);


            // Apply the death effect for fatal blows
            if ( bFatal )
            {
                #ifdef DEBUG
                Log_Trace(LOG_CHANNEL_EFFECTS,"effect_damage_h.Effects_ApplyInstantEffectDamage","damage " +  FloatToString(fDamage) + " fatal, killing target.", oTarget);
                #endif

                // -------------------------------------------------------------
                // Feast of the fallen: regain stamina on backstab
                // -------------------------------------------------------------
                if (bBackstab || bDeathblow)
                {
                    if (IsObjectValid(oDamager) && GetObjectType(oDamager) == OBJECT_TYPE_CREATURE)
                    {
                        if (HasAbility(oDamager, ABILITY_TALENT_FEAST_OF_THE_FALLEN))
                        {
                            float fMax     = GetCreatureProperty(oDamager, PROPERTY_DEPLETABLE_MANA_STAMINA,PROPERTY_VALUE_TOTAL);
                            float fCurrent = GetCreatureProperty(oDamager, PROPERTY_DEPLETABLE_MANA_STAMINA,PROPERTY_VALUE_CURRENT);
                            float fValue =   GetLevel(oTarget) * 5.0f * GetM2DAFloat(Diff_GetAutoScaleTable(),"fScale", GetCreatureRank(oTarget)) ;
                            float fRegain = MinF(fMax - fCurrent, fValue);

                            UpdateCreatureProperty(oDamager, PROPERTY_DEPLETABLE_MANA_STAMINA,  fRegain, PROPERTY_VALUE_CURRENT);

                            //UI_DisplayDamageFloaty(oDamager, oTarget, FloatToInt(fRegain), 1, 0, 0, 2);

                            // vfx
                            ApplyEffectVisualEffect(oDamager, oDamager, FEAST_OF_THE_FALLEN_VFX, EFFECT_DURATION_TYPE_INSTANT, 0.0f, ABILITY_TALENT_FEAST_OF_THE_FALLEN);
                         }
                    }
                }

                KillCreature(oTarget, oDamager, nAbility, FALSE, FloatToInt(fDamage));
            }
            else
            {

                // -------------------------------------------------------------
                // Damage must be significant enough to trigger anim
                // -------------------------------------------------------------
                if (fDamage >= 3.0f)
                {
                    PlayAdditiveAnimation(oTarget, ANIMATION_DAMAGE_ADDITIVE);
                }

                // -------------------------------------------------------------
                // EL: Tracking required for the TACTICIAN Achievement
                // -------------------------------------------------------------
                if (IsHero(oTarget) == TRUE)
                {
                    SetLocalInt(oDamager, CREATURE_DAMAGED_THE_HERO, TRUE);
                }

            }

            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE,"effect_damage_h.ApplyInstantEffectDamage", "Damage: " + FloatToString(fDamage), oDamager);
            #endif


            // -------------------------------------------------------------------------
            //                          *** Gore Handling ***
            // -------------------------------------------------------------------------
            if ( (nDamageFlags &  DAMAGE_EFFECT_FLAG_UPDATE_GORE) == DAMAGE_EFFECT_FLAG_UPDATE_GORE)
            {

                float fAmount = GORE_CHANGE_HIT;
                int nVfx = 1016;
                // ---------------------------------------------------------------------
                // Crits and Deathblows apply different gorelevels than mere hits
                // ---------------------------------------------------------------------
                if ( (nDamageFlags &  DAMAGE_EFFECT_FLAG_CRITICAL) == DAMAGE_EFFECT_FLAG_CRITICAL)
                {
                    fAmount = GORE_CHANGE_CRITICAL;
                    nVfx = 1015;
                }
                else if ( (nDamageFlags &  DAMAGE_EFFECT_FLAG_DEATHBLOW) == DAMAGE_EFFECT_FLAG_DEATHBLOW)
                {
                    fAmount = GORE_CHANGE_DEATHBLOW;
                }

                // ---------------------------------------------------------------------
                // Change the gore level to the requested amount and display VFX
                // ---------------------------------------------------------------------
                if (nDamageType == DAMAGE_TYPE_PHYSICAL && CanCreatureBleed(oTarget) )
                {
                    ApplyEffectVisualEffect(oDamager, oTarget, nVfx, EFFECT_DURATION_TYPE_INSTANT, 0.0f);
                }

                Gore_ModifyGoreLevel (oDamager,fAmount);

            }

            float fAmount = 0.0f;
            // -------------------------------------------------------------------------
            // If the Leech flag is set, heal the caster by the amount of damage
            // done
            // -------------------------------------------------------------------------
            if (fDamage >0.0f)
            {
                // GXA Override
                if (HasAbility(oTarget, 401212) == TRUE) // GXA Inner Power
                {
                    UpdateCreatureProperty(oTarget, PROPERTY_DEPLETABLE_MANA_STAMINA, (fDamage * 0.5f), PROPERTY_VALUE_CURRENT);
                }
                // GXA Override

                // -------------------------------------------------------------
                // Electricity based spells deal additional stamina damage
                // -------------------------------------------------------------
                if (nDamageType == DAMAGE_TYPE_ELECTRICITY)
                {
                    if (GetCreatureCoreClass(oTarget) != CLASS_WIZARD)
                    {
                        UpdateCreatureProperty(oTarget, PROPERTY_DEPLETABLE_MANA_STAMINA, (-1.0f * fDamage), PROPERTY_VALUE_CURRENT);
                    }
                }



                int   bDrain = FALSE;

                if ( (nDamageFlags &  DAMAGE_EFFECT_FLAG_LEECH_100) == DAMAGE_EFFECT_FLAG_LEECH_100 )
                {
                    fAmount = fDamage;
                    bDrain = TRUE;

                }
                else if ( (nDamageFlags &  DAMAGE_EFFECT_FLAG_LEECH_75) == DAMAGE_EFFECT_FLAG_LEECH_75 )
                {
                    fAmount = fDamage * 0.75;
                    bDrain = TRUE;

                }
                else if ((nDamageFlags &  DAMAGE_EFFECT_FLAG_LEECH_50) == DAMAGE_EFFECT_FLAG_LEECH_50 )
                {
                    fAmount = fDamage * 0.5;
                    bDrain = TRUE;

                }
                 else if ((nDamageFlags &  DAMAGE_EFFECT_FLAG_LEECH_25) == DAMAGE_EFFECT_FLAG_LEECH_25 )
                {
                    fAmount = fDamage * 0.25;
                    bDrain = TRUE;
                }

               if (nImpactVfx == 0)
               {

                    if (nDamageType == DAMAGE_TYPE_ELECTRICITY)
                    {
                            nImpactVfx = 1006;
                    }
                    else if (nDamageType == DAMAGE_TYPE_COLD)
                    {
                            nImpactVfx = 1013;

                         ApplyEffectVisualEffect(oDamager, oTarget, 1013, EFFECT_DURATION_TYPE_INSTANT, 0.0f);
                    }
                    else if (nDamageType == DAMAGE_TYPE_FIRE)
                    {
                        nImpactVfx = (fDamage > 20.0f) ? 1107 : 1108;
                    }
                    else if (nDamageType == DAMAGE_TYPE_NATURE)
                    {
                        nImpactVfx = 1504; // (PeterT) changed to smaller vfx
                    }
                    else if (nDamageType == DAMAGE_TYPE_SPIRIT)
                    {
                        nImpactVfx = 1514;
                    }

                    if (nImpactVfx)
                    {
                        ApplyEffectVisualEffect(oDamager, oTarget, nImpactVfx, EFFECT_DURATION_TYPE_INSTANT, 0.0f);
                    }
                }
                else if (nImpactVfx >0)
                {
                    ApplyEffectVisualEffect(oDamager, oTarget, nImpactVfx, EFFECT_DURATION_TYPE_INSTANT, 0.0f);
                }


                // -------------------------------------------------------------------------
                // If we have a leech effect flag set, drain here
                // -------------------------------------------------------------------------
                if (bDrain)
                {
                    #ifdef DEBUG
                    Log_Trace(LOG_CHANNEL_EFFECTS,"effect_damage_h.Effects_ApplyInstantEffectDamage","health leech:" +  FloatToString(fAmount), oTarget);
                    #endif

                    if (fAmount >0.0)
                    {

                        if ( (nDamageFlags & DAMAGE_EFFECT_FLAG_LEECH_MANA) == DAMAGE_EFFECT_FLAG_LEECH_MANA)
                        {
                            effect eEffect = EffectModifyManaStamina(fAmount);
                            ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT,eEffect,oDamager,0.0,oTarget,0);
                            // Only show this floaty when it happens to the player.
                            if  (IsControlled(oTarget))
                            {
                                UI_DisplayDamageFloaty(oTarget, oDamager, FloatToInt(fAmount), 1, 0, 0, 2);
                            }
                            UpdateCreatureProperty(oTarget, PROPERTY_DEPLETABLE_MANA_STAMINA, (-1.0f * fAmount), PROPERTY_VALUE_CURRENT);

                        }
                        else
                        {
                            Effect_ApplyInstantEffectHeal(oDamager,oTarget,fAmount, TRUE);
                        }
                    }
                }



            }
        }
        else if (GetObjectType(oTarget) == OBJECT_TYPE_PLACEABLE)
        {
            // Apply the death effect for fatal blows
            if ( bFatal )
            {
                #ifdef DEBUG
                Log_Trace(LOG_CHANNEL_EFFECTS,"effect_damage_h.Effects_ApplyInstantEffectDamage","damage " +  FloatToString(fDamage) + " fatal, killing placeable.", oTarget);
                #endif
                DestroyPlaceable(oTarget, oDamager, nAbility);
            }
            else
            {
                // Apparently Placeables do have a damage additive too.
                PlayAdditiveAnimation(oTarget, ANIMATION_DAMAGE_ADDITIVE);
            }

        }

    }
    else
    {
        #ifdef DEBUG
            DisplayFloatyMessage(oTarget,"Debug: Zero damage dealt.");
        #endif
    }

    return TRUE;

}

// MGB - February 23, 2009
// EffectDamage Constructor moved into Engine.

///////////////////////////////////////////////////////////////////////////////
//  Effects_HandleApplyEffectDamage
///////////////////////////////////////////////////////////////////////////////
//  Created By: David Sims
//  Created On: July 11, 2006
///////////////////////////////////////////////////////////////////////////////
int Effects_HandleApplyEffectDamage(effect eEffect, object oTarget = OBJECT_SELF)
{
    object oDamager = GetEffectCreator(eEffect);

    float fDamage = GetEffectFloat(eEffect, 0);
    int nDamageType = GetEffectInteger(eEffect, 0);
    int nDamageFlags = GetEffectInteger(eEffect, 1);
    int nImpactVfx = GetEffectInteger(eEffect, 2);

    #ifdef DEBUG
    //catch instances of where we use DAMAGE_TYPE_TBD
    if (nDamageType == DAMAGE_TYPE_TBD && LOG_ENABLED)
    {
        Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE,"effect_damage_h.EffectDamage","damage applied with DAMAGE_TYPE_TBD", oTarget, LOG_SEVERITY_WARNING );
    }
    #endif



    return  Effects_ApplyInstantEffectDamage(oTarget, oDamager, fDamage, nDamageType, nDamageFlags, GetEffectAbilityID(eEffect), nImpactVfx);

}


void DamageCreature(object oTarget, object oDamager, float fDamage, int nDamageType = DAMAGE_TYPE_PLOT, int bUnresistable = FALSE);
void DamageCreature(object oTarget, object oDamager, float fDamage, int nDamageType = DAMAGE_TYPE_PLOT, int bUnresistable = FALSE)
{
    Effects_ApplyInstantEffectDamage(oTarget, oDamager, fDamage, nDamageType, bUnresistable? DAMAGE_EFFECT_FLAG_UNRESISTABLE: DAMAGE_EFFECT_FLAG_NONE, 0, 0);
}