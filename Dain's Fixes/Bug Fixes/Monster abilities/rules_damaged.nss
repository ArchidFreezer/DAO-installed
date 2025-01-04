#include "rules_h"
#include "events_h"
#include "sys_soundset_h"
#include "sys_stealth_h"
#include "ability_h"

void main()
{

    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    // -------------------------------------------------------------------------
    // Generic event message
    // -------------------------------------------------------------------------
    #ifdef DEBUG
    Log_Events("", ev);
    #endif

    if (nEventType = EVENT_TYPE_DAMAGED)
    {
        // This object lost 1 hit point or more

        if (IsDeadOrDying(OBJECT_SELF))
        {
             return;
        }

        int bSound = TRUE;

        object oDamager = GetEventCreator(ev);
        float fDamage = GetEventFloat(ev, 0);
        int nDamageType = GetEventInteger(ev, 0);
        int nAbility  = GetEventInteger(ev, 1);

        if(!IsFollower(OBJECT_SELF))
            AI_Threat_UpdateDamage(OBJECT_SELF, oDamager, fDamage);


        if (IsStealthy(OBJECT_SELF) && nDamageType != DAMAGE_TYPE_PHYSICAL)
        {
            // stealth 3 and 4 have a chance to not drop on non-physical damage
            int nLevel = GetLevel(OBJECT_SELF);
            float fChance = -1.0f;
            if (HasAbility(OBJECT_SELF, ABILITY_SKILL_STEALTH_4) == TRUE)
            {
                fChance = nLevel * 0.02f;
            } else if (HasAbility(OBJECT_SELF, ABILITY_SKILL_STEALTH_3) == TRUE)
            {
                fChance = nLevel * 0.01f;
            }
            fChance = MinF(fChance, 0.8f);

            if (RandomFloat() > fChance)
            {
                DropStealth(OBJECT_SELF);
            }
        }

        // If not a follower and damaged outside of combat and does not perceive the damager
        // then try to move to damager.
        // the following check needs to be outside of gamemode=combat check because it can happen when the gamemode is not combat
        // for example: around a corner where no one perceives each other yet
        if(GetObjectType(oDamager) == OBJECT_TYPE_CREATURE &&
            GetCombatState(OBJECT_SELF) == FALSE && !IsFollower(OBJECT_SELF) && !IsPerceiving(OBJECT_SELF, oDamager))
        {
            location lLoc = GetLocation(oDamager);
            WR_ClearAllCommands(OBJECT_SELF, TRUE);
            command cMove = CommandMoveToLocation(lLoc, TRUE);
            WR_AddCommand(OBJECT_SELF, cMove);
        }


        // -----------------------------------------------------------------
        // Attack Interruption
        // This should only ever happen in combat.
        // @author georg
        // -----------------------------------------------------------------
        if (GetGameMode() == GM_COMBAT)
        {
            // -------------------------------------------------------------
            // Only significant damage disrupts
            // -------------------------------------------------------------
            if (nDamageType == DAMAGE_TYPE_PHYSICAL)
            {

                command cmd = GetCurrentCommand(OBJECT_SELF);
                int nCmdType = GetCommandType(cmd);

                // ---------------------------------------------------------
                // We only interrupt attack commands at this point
                // ---------------------------------------------------------
                if (nCmdType == COMMAND_TYPE_ATTACK)
                {
                    //---------------------------------------------------------
                    // Damage needs to exceed dexterity modifier/3 to interrupt
                    //----------------------------------------------------------
                    float fModifier= GetAttributeModifier(OBJECT_SELF, ATTRIBUTE_DEX) * (1.0 / 3.0);
                    if (fDamage > fModifier)
                    {

                        // -------------------------------------------------
                        // Melee archers ignore interruptions
                        // -------------------------------------------------
                        if (!HasAbility(OBJECT_SELF,ABILITY_TALENT_MELEE_ARCHER))
                        {

                            if (IsUsingMeleeWeapon(oDamager, OBJECT_INVALID))
                            {
                                if (IsUsingRangedWeapon(OBJECT_SELF,OBJECT_INVALID,TRUE))
                                {
                                    UI_DisplayMessage(OBJECT_SELF, UI_MESSAGE_INTERRUPTED);
                                    #ifdef DEBUG
                                    Log_Trace(LOG_CHANNEL_COMBAT,"rules_core.OnDamage","Ranged attack interrupted by damage");
                                    #endif
                                    WR_ClearAllCommands(OBJECT_SELF, TRUE);
                                }
                            }

                        }
                    }
                }
                // ---------------------------------------------------------
                // Experimental: Taking any damage > 1 causes spell interruption
                // ---------------------------------------------------------
                else if (nCmdType == COMMAND_TYPE_USE_ABILITY)
                {

                    int nAbi = GetCommandInt(cmd,0);

                    // Only abilities with speed >0 can be interrupted.
                    if (CanInterruptSpell(nAbi))
                    {

                        int nCombatTrainingRank = 0 ;
                        int nModifier = 0;
                        float fThres = 0.0f;

                        // -----------------------------------------------------

                        if (!IsPartyMember(OBJECT_SELF))
                        {
                            nCombatTrainingRank = GetM2DAInt(Diff_GetAutoScaleTable(),"nCombatTraining",GetCreatureRank(OBJECT_SELF));
                            nModifier = GetLevel(OBJECT_SELF);
                        }
                        else
                        {
                            nCombatTrainingRank = (HasAbility(OBJECT_SELF,ABILITY_SKILL_COMBAT_TRAINING_1))  + (HasAbility(OBJECT_SELF,ABILITY_SKILL_COMBAT_TRAINING_2)) + (HasAbility(OBJECT_SELF,ABILITY_SKILL_COMBAT_TRAINING_3)) + (HasAbility(OBJECT_SELF,ABILITY_SKILL_COMBAT_TRAINING_4));
                            nModifier = 5 + GetLevel(OBJECT_SELF)/2;
                        }

                        fThres = (nCombatTrainingRank * 10.0f) + nModifier;


                        // -----------------------------------------------------
                        // Damage needs to exceed a certain threshold before it
                        // can interrupt. Otherwise playing mages gets very
                        // frustrating.
                        // -----------------------------------------------------
                        if (fDamage >  fThres)
                        {
                            // ---------------------------------------------
                            // Since COMMAND_USEABILITY can be in a movement
                            // subaction, filter additionally for conjure
                            // phase.
                            // ---------------------------------------------
                            if (IsConjuring(OBJECT_SELF))
                             {
                                 UI_DisplayMessage(OBJECT_SELF, UI_MESSAGE_INTERRUPTED);
                                 #ifdef DEBUG
                                 Log_Trace(LOG_CHANNEL_COMBAT,"rules_core.OnDamage","Spell interrupted by damage");
                                 #endif

                                 SSPlaySituationalSound(OBJECT_SELF, SOUND_SITUATION_SPELL_INTERRUPTED);
                                 bSound = FALSE;
                                 WR_ClearAllCommands(OBJECT_SELF, TRUE);
                             }
                        }
                        else
                        {
                            #ifdef DEBUG
                            Log_Trace(LOG_CHANNEL_COMBAT,"rules_core.OnDamage","Spell not interrupted, dmg " + ToString(fDamage) + " below threshold: " + ToString(fThres) );
                            #endif
                        }
                    }
                }
            }


            if (fDamage >= SOUND_THRESH_DAMAGE_AMOUNT && bSound)
            {
                SSPlaySituationalSound(OBJECT_SELF, SOUND_SITUATION_GOT_DAMAGED, oDamager);
            }

            // -------------------------------------------------------------
            // Handle various effects
            // -------------------------------------------------------------
            Ability_HandleOnDamageAbilities(OBJECT_SELF, oDamager, fDamage, nDamageType, nAbility);
        }
    }
}