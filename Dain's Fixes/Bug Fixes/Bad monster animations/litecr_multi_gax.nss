//::///////////////////////////////////////////////
//:: Creature Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creature events
*/
//:://////////////////////////////////////////////
//:: Created By:
//:: Created On:
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "ai_main_h_2"

#include "plt_lite_multi_gax"

void SwitchForm()
{
    int nNewAppearance;
    effect eStrBuff = EffectModifyAttribute(ATTRIBUTE_STR, 35);
    effect eStrDebuff = EffectModifyAttribute(ATTRIBUTE_STR, -35);
    effect eMagBuff = EffectModifyAttribute(ATTRIBUTE_MAG, 20);
    effect eMagDebuff = EffectModifyAttribute(ATTRIBUTE_MAG, -20);
    effect eArmorbuff = EffectModifyProperty(PROPERTY_ATTRIBUTE_ARMOR, 20.0);
    effect eArmorDebuff = EffectModifyProperty(PROPERTY_ATTRIBUTE_ARMOR, -20.0);
    if(GetAppearanceType(OBJECT_SELF) == 12)
    {
        nNewAppearance = 26;
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eStrBuff, OBJECT_SELF);
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eArmorbuff, OBJECT_SELF);
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eMagDebuff, OBJECT_SELF);
    }
    else
    {
        nNewAppearance = 12;
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eStrDebuff, OBJECT_SELF);
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eArmorDebuff, OBJECT_SELF);
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eMagBuff, OBJECT_SELF);
    }

    ApplyEffectVisualEffect(OBJECT_SELF, OBJECT_SELF, 1135, EFFECT_DURATION_TYPE_INSTANT, 0.0);

    SetAppearanceType(OBJECT_SELF, nNewAppearance);
    //float fMaxManaStamina = GetCreatureProperty(OBJECT_SELF, PROPERTY_DEPLETABLE_MANA_STAMINA, PROPERTY_VALUE_TOTAL);
    SetCreatureProperty(OBJECT_SELF, PROPERTY_DEPLETABLE_MANA_STAMINA, 200.0, PROPERTY_VALUE_CURRENT);

    if(nNewAppearance == 26) // revenant -> remove arcane horror abilities and add revenant
    {
        RemoveAbility(OBJECT_SELF, ABILITY_SPELL_SLOW);
        RemoveAbility(OBJECT_SELF, ABILITY_SPELL_SHARED_FATE);
        RemoveAbility(OBJECT_SELF, ABILITY_SPELL_HORROR);
        RemoveAbility(OBJECT_SELF, ABILITY_SPELL_ARCANE_HORROR_ATTACK);
        RemoveAbility(OBJECT_SELF, ABILITY_TALENT_MONSTER_ARCANEHORROR_AOE);
        RemoveAbility(OBJECT_SELF, ABILITY_MONSTER_ARCANEHORROR_SWARM);
        RemoveAbility(OBJECT_SELF, ABILITY_SPELL_INFERNO);
        RemoveAbility(OBJECT_SELF, ABILITY_SPELL_CONE_OF_COLD);
        RemoveAbility(OBJECT_SELF, ABILITY_SPELL_WINTERS_GRASP);
        RemoveAbility(OBJECT_SELF, ABILITY_SPELL_MIND_BLAST);
        RemoveAbility(OBJECT_SELF, ABILITY_SPELL_WALKING_BOMB);
        RemoveAbility(OBJECT_SELF, ABILITY_SPELL_TBD_WAS_DANCE_OF_MADNESS);
        RemoveAbility(OBJECT_SELF, ABILITY_SPELL_DRAIN_LIFE);
        RemoveAbility(OBJECT_SELF, ABILITY_SPELL_ANTIMAGIC_BURST);
        RemoveAbility(OBJECT_SELF, 10401); // Dispel Magic
        RemoveAbility(OBJECT_SELF, 11114); // Misdirection Hex

        AddAbility(OBJECT_SELF, ABILITY_TALENT_SHIELD_WALL);
        AddAbility(OBJECT_SELF, ABILITY_TALENT_MONSTER_REVENANT_DOUBLESTRIKE);
        AddAbility(OBJECT_SELF, ABILITY_TALENT_MONSTER_REVENANT_MASS_PULL);
        AddAbility(OBJECT_SELF, ABILITY_TALENT_MONSTER_REVENANT_PULL);
        AddAbility(OBJECT_SELF, ABILITY_TALENT_MONSTER_AURA_WEAKNESS);
    }
    else
    {
        AddAbility(OBJECT_SELF, ABILITY_SPELL_SLOW);
        AddAbility(OBJECT_SELF, ABILITY_SPELL_SHARED_FATE);
        AddAbility(OBJECT_SELF, ABILITY_SPELL_HORROR);
        AddAbility(OBJECT_SELF, ABILITY_SPELL_ARCANE_HORROR_ATTACK);
        AddAbility(OBJECT_SELF, ABILITY_TALENT_MONSTER_ARCANEHORROR_AOE);
        AddAbility(OBJECT_SELF, ABILITY_MONSTER_ARCANEHORROR_SWARM);
        AddAbility(OBJECT_SELF, ABILITY_SPELL_INFERNO);
        AddAbility(OBJECT_SELF, ABILITY_SPELL_CONE_OF_COLD);
        AddAbility(OBJECT_SELF, ABILITY_SPELL_WINTERS_GRASP);
        AddAbility(OBJECT_SELF, ABILITY_SPELL_MIND_BLAST);
        AddAbility(OBJECT_SELF, ABILITY_SPELL_WALKING_BOMB);
        AddAbility(OBJECT_SELF, ABILITY_SPELL_TBD_WAS_DANCE_OF_MADNESS);
        AddAbility(OBJECT_SELF, ABILITY_SPELL_DRAIN_LIFE);
        AddAbility(OBJECT_SELF, ABILITY_SPELL_ANTIMAGIC_BURST);
        AddAbility(OBJECT_SELF, 10401); // Dispel Magic
        AddAbility(OBJECT_SELF, 11114); // Misdirection Hex

        RemoveAbility(OBJECT_SELF, ABILITY_TALENT_SHIELD_WALL);
        RemoveAbility(OBJECT_SELF, ABILITY_TALENT_MONSTER_REVENANT_DOUBLESTRIKE);
        RemoveAbility(OBJECT_SELF, ABILITY_TALENT_MONSTER_REVENANT_MASS_PULL);
        RemoveAbility(OBJECT_SELF, ABILITY_TALENT_MONSTER_REVENANT_PULL);
        // not removing aura of weakness ***
    }
    command cWait = CommandWait(0.25);
    WR_AddCommand(OBJECT_SELF, cWait);

}

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    int nEventHandled = FALSE;

    switch(nEventType)
    {
        case EVENT_TYPE_HANDLE_CUSTOM_AI:
        {
            object oLastTarget = GetEventObject(ev, 0);
            int nLastCommand = GetEventInteger(ev, 1);
            int nLastCommandStatus = GetEventInteger(ev, 2);
            int nLastSubCommand = GetEventInteger(ev, 3);
            int nAITargetType = GetEventInteger(ev, 4);
            int nAIParameter = GetEventInteger(ev, 5);
            int nTacticID = GetEventInteger(ev, 6);

            float fCurrentHealth = GetCurrentHealth(OBJECT_SELF);
            float fMaxHealth = GetMaxHealth(OBJECT_SELF);
            float fHealthLevel = fCurrentHealth / fMaxHealth;

            // Each round there is a a chance he'd switch forms based on his healt levels:

            // each time he changes he gets back full mana/stamina

            if(GetAppearanceType(OBJECT_SELF) == 12)
            {
                if(GetHasEffects(OBJECT_SELF, EFFECT_TYPE_INVALID, ABILITY_SPELL_IMMOBILIZE))
                {
                    command cCast = CommandUseAbility(ABILITY_SPELL_ANTIMAGIC_BURST, OBJECT_SELF);
                    WR_AddCommand(OBJECT_SELF, cCast);
                    break;
                }
                else if(GetHasEffects(OBJECT_SELF, EFFECT_TYPE_INVALID, ABILITY_SPELL_ROOT) ||
                        GetHasEffects(OBJECT_SELF, EFFECT_TYPE_INVALID, ABILITY_SPELL_SLOW) ||
                        GetHasEffects(OBJECT_SELF, EFFECT_TYPE_INVALID, ABILITY_SPELL_MASS_SLOW))
                {
                    if(_AI_IsAbilityValid(10401))
                    {
                        command cCast = CommandUseAbility(10401, OBJECT_SELF);
                        WR_AddCommand(OBJECT_SELF, cCast);
                        break;
                    }
                }
            }

            int nSwitchChance = 0;

            if(fHealthLevel < 0.8 && fHealthLevel > 0.60 && GetAppearanceType(OBJECT_SELF) == 12)
                SwitchForm();
            else if(fHealthLevel <= 0.6 && fHealthLevel > 0.4 && GetAppearanceType(OBJECT_SELF) == 26)
                SwitchForm();
            else if(fHealthLevel <= 0.4 && fHealthLevel > 0.3 && GetAppearanceType(OBJECT_SELF) == 12)
                SwitchForm();
            else if(fHealthLevel <= 0.3 && fHealthLevel > 0.15 && GetAppearanceType(OBJECT_SELF) == 26)
                SwitchForm();
            else if(fHealthLevel <= 0.15 && GetAppearanceType(OBJECT_SELF) == 12)
                SwitchForm();
            else
                AI_DetermineCombatRound(oLastTarget, nLastCommand, nLastCommandStatus, nLastSubCommand);


            /*if(fHealthLevel < 0.95 && fHealthLevel >= 0.3)
                nSwitchChance = 10;
            else if(fHealthLevel < 0.3 && GetAppearanceType(OBJECT_SELF) != 26)
                nSwitchChance = 30;
            else if(fHealthLevel < 0.3)
                nSwitchChance = 15;


            int nRand = Random(100) + 1;
            Log_Trace(LOG_CHANNEL_TEMP, "boom", "switch chance: " + IntToString(nSwitchChance) + ", rand: " + IntToString(nRand));

            if(nRand <= nSwitchChance)
                SwitchForm();
            else
                AI_DetermineCombatRound(oLastTarget, nLastCommand, nLastCommandStatus, nLastSubCommand);

            */
            break;
        }

        ////////////////////////////////////////////////////////////////////////
        // Sent by: AI scripts
        // When: The current creature dies
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_DEATH:
        {
            object oKiller = GetEventCreator(ev);

            WR_SetPlotFlag(PLT_LITE_MULTI_GAX, MULTI_GAX_DEAD, TRUE, TRUE);

            break;
        }


    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_CREATURE_CORE);
    }
}