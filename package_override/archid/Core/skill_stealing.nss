// -----------------------------------------------------------------------------
// talent_single_target.nss
// -----------------------------------------------------------------------------
/*
    Generic Ability Script for single target abilities
*/
// -----------------------------------------------------------------------------
// georg@2006/11/28
// -----------------------------------------------------------------------------

#include "log_h"
#include "abi_templates"
#include "sys_treasure_h"
#include "sys_areabalance"
#include "achievement_core_h"
#include "stats_core_h"
const float STEALING_STEALING_RANK_MODIFIER = 5.0f;
const float STEALING_STEALTH_RANK_MODIFIER = 5.0f;
const float STEALING_LEVEL_MODIFIER = -2.0f;
const float STEALING_COMBAT_MODIFIER = 10.0f;
const float STEALING_NONCOMBATANT_RESISTANCE_FACTOR = 1.5f;

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName(), "Stealing skill used.");

    // is target a creature
    if (GetObjectType(stEvent.oTarget) == OBJECT_TYPE_CREATURE)
    {
        Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName(), "Target is creature. " + GetTag(stEvent.oTarget));

        // can creature be stolen from?
        int bStolenFrom = GetLocalInt(stEvent.oTarget, FLAG_STOLEN_FROM);

        // if creature is a party member, automatically fail
        if (IsPartyMember(stEvent.oTarget) == TRUE)
        {
            PlaySoundSet(stEvent.oTarget, SS_NO);

            bStolenFrom = TRUE;
        } else

        Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName(), "bStolenFrom = " + ToString(bStolenFrom));
        if (bStolenFrom == FALSE)
        {
            // determine stealing level
            int nStealingRank = 0;
            if (HasAbility(stEvent.oCaster, ABILITY_SKILL_STEALING_4) == TRUE)
            {
                nStealingRank = 4;
            } else if (HasAbility(stEvent.oCaster, ABILITY_SKILL_STEALING_3) == TRUE)
            {
                nStealingRank = 3;
            } else if (HasAbility(stEvent.oCaster, ABILITY_SKILL_STEALING_2) == TRUE)
            {
                nStealingRank = 2;
            } else if (HasAbility(stEvent.oCaster, ABILITY_SKILL_STEALING_1) == TRUE)
            {
                nStealingRank = 1;
            }
            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName(), "nStealingRank = " + ToString(nStealingRank));

            // does the character have the skill?
            if (nStealingRank > 0)
            {
                int bCasterCombat = GetCombatState(stEvent.oCaster);
                int bTargetCombat = GetCombatState(stEvent.oTarget);
                Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName(), "bCasterCombat = " + ToString(bCasterCombat));
                Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName(), "bTargetCombat = " + ToString(bTargetCombat));

                // if not in combat, or stealing rank 4 or greater
                if (((bCasterCombat != TRUE) && (bTargetCombat != TRUE)) || (nStealingRank >= 4))
                {
                    // is target hostile?
                    int bTargetFriendly = FALSE;
                    if (IsObjectHostile(stEvent.oCaster, stEvent.oTarget) == FALSE)
                    {
                        bTargetFriendly = TRUE;
                    }

                    // play sound
                    PlaySound(stEvent.oCaster, "glo_fly_mv/gui_steal/steal");

                    // is stealthed?
                    int nStealthRank = 0;
                    if (IsModalAbilityActive(stEvent.oCaster, ABILITY_SKILL_STEALTH_1) == TRUE)
                    {
                        // determine stealing level
                        if (HasAbility(stEvent.oCaster, ABILITY_SKILL_STEALTH_4) == TRUE)
                        {
                            nStealthRank = 4;
                        } else if (HasAbility(stEvent.oCaster, ABILITY_SKILL_STEALTH_3) == TRUE)
                        {
                            nStealthRank = 3;
                        } else  if (HasAbility(stEvent.oCaster, ABILITY_SKILL_STEALTH_2) == TRUE)
                        {
                            nStealthRank = 2;
                        } else if (HasAbility(stEvent.oCaster, ABILITY_SKILL_STEALTH_1) == TRUE)
                        {
                            nStealthRank = 1;
                        }
                        Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName(), "nStealthRank = " + ToString(nStealthRank));

                        // cancel stealth
                        //DropStealth(stEvent.oCaster);
                    }

                    // player score = intelligence modifier + stealing rank + stealth rank
                    float fThiefScore = GetAttributeModifier(stEvent.oCaster, PROPERTY_ATTRIBUTE_INTELLIGENCE);
                    Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName(), "Thief Intelligence Modifier = " + ToString(fThiefScore));
                    fThiefScore += nStealingRank * STEALING_STEALING_RANK_MODIFIER;
                    Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName(), "Thief With Stealing = " + ToString(fThiefScore));
                    fThiefScore += nStealthRank * STEALING_STEALTH_RANK_MODIFIER;
                    Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName(), "Thief With Stealth = " + ToString(fThiefScore));

                    // target score = mental resistance + rank modifier + level modifier + combat modifier
                    float fTargetScore = 0.0f;
                    int nTargetLevel = GetLevel(stEvent.oTarget);
                    int nThiefLevel = GetLevel(stEvent.oCaster);
                    if (nTargetLevel == 0)
                    {
                        nTargetLevel = AB_GetAreaTargetLevel(stEvent.oTarget);
                        Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName(), "Target Non-Combatant With Area Level = " + ToString(nThiefLevel));

                        fTargetScore += nTargetLevel * STEALING_NONCOMBATANT_RESISTANCE_FACTOR;
                        Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName(), "Target Mental Resistance = " + ToString(fTargetScore));
                    } else
                    {
                        fTargetScore += GetCreatureProperty(stEvent.oTarget, PROPERTY_ATTRIBUTE_RESISTANCE_MENTAL);
                        Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName(), "Target Mental Resistance = " + ToString(fTargetScore));
                    }
                    fTargetScore += GetM2DAFloat(TABLE_AUTOSCALE, "fStealingModifier", GetCreatureRank(stEvent.oTarget));
                    Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName(), "Target With Rank = " + ToString(fTargetScore));
                    fTargetScore += (nThiefLevel - nTargetLevel) * STEALING_LEVEL_MODIFIER;
                    Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName(), "Target With Level ( " + ToString(nThiefLevel) + " vs " + ToString(nTargetLevel) + " ) = " + ToString(fTargetScore));
                    if ((bCasterCombat == TRUE) || (bTargetCombat == TRUE))
                    {
                        fTargetScore += STEALING_COMBAT_MODIFIER;
                    }
                    Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName(), "Target With Combat = " + ToString(fTargetScore));

                    // final value
                    fThiefScore *= (0.8f + (RandomFloat() * 0.4f)); // 0.8-1.2 multiplier
                    Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName(), "Thief Final Value = " + ToString(fThiefScore));

                    // determine outcome
                    if (fThiefScore > fTargetScore)
                    {
                        // if there is space in inventory
                        int nCurrentInventory = GetArraySize(GetItemsInInventory(stEvent.oCaster, GET_ITEMS_OPTION_BACKPACK, 0, "", TRUE));
                        int nMaxInventory = GetMaxInventorySize(stEvent.oCaster);
                        if (nCurrentInventory < nMaxInventory)
                        {
                            // mark as stolen from
                            SetLocalInt(stEvent.oTarget, FLAG_STOLEN_FROM, TRUE);

                            // generate new stolen treasure
                            TreasureStolen(stEvent.oTarget, stEvent.oCaster);

                            // signal area if friendly
                            if (bTargetFriendly == TRUE)
                            {
                                // signal area
                                event ev = Event(EVENT_TYPE_STEALING_SUCCESS);
                                ev = SetEventObject(ev, 0, stEvent.oCaster);
                                ev = SetEventObject(ev, 1, stEvent.oTarget);
                                SignalEvent(GetArea(stEvent.oCaster), ev);
                            }

                            // Track success stat
                            STATS_TrackStealing(TRUE);

                            // unlock "getting caught" achievement
                            ACH_MuggerAchievement();

                        } else
                        {
                            // insufficient space
                            UI_DisplayMessage(stEvent.oCaster, 3515);
                        }

                    } else
                    {
                        UI_DisplayMessage(stEvent.oCaster, 3503);

                        // add animation
                        int nQueueSize = GetCommandQueueSize(stEvent.oTarget);
                        int nCurrent = GetCommandType(GetCurrentCommand(stEvent.oTarget));
                        if ((nCurrent == COMMAND_TYPE_INVALID) && (nQueueSize == 0))
                        {
                            AddCommand(stEvent.oTarget, CommandPlayAnimation(256), TRUE, TRUE);
                        }

                        // Track failure stat
                        STATS_TrackStealing(FALSE);

                        // signal area if friendly
                        if (bTargetFriendly == TRUE)
                        {
                            // signal area
                            event ev = Event(EVENT_TYPE_STEALING_FAILURE);
                            ev = SetEventObject(ev, 0, stEvent.oCaster);
                            ev = SetEventObject(ev, 1, stEvent.oTarget);
                            SignalEvent(GetArea(stEvent.oCaster), ev);

                        }
                    }
                } else
                {
                    UI_DisplayMessage(stEvent.oCaster, 3501);
                }
            } else
            {
                UI_DisplayMessage(stEvent.oCaster, 3500);
            }
        } else
        {
            UI_DisplayMessage(stEvent.oCaster, 3514);
        }
    } else
    {
        Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_IMPACT","Target is NOT creature.");
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
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);
            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_CAST",Log_GetAbilityNameById(stEvent.nAbility));

            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_IMPACT",Log_GetAbilityNameById(stEvent.nAbility));

            _HandleImpact(stEvent);

            break;
        }
    }
}