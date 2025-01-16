//:://////////////////////////////////////////////
/*
    Generic Actions plots
*/
//:://////////////////////////////////////////////
//:: Created By: Ferret
//:: Created On: Sept 27th, 2006
//:://////////////////////////////////////////////

#include "plt_gen00pt_generic_actions"

#include "sys_injury"
#include "wrappers_h"
#include "utility_h"
#include "plot_h"

#include "af_scalestorefix_h"

const string STORE_PREFIX = "store_";

int StartingConditional()
{
    event eParms = GetCurrentEvent();               // Contains all input parameters
    int nType = GetEventType(eParms);               // GET or SET call
    string strPlot = GetEventString(eParms, 0);     // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);         // The bit flag # being affected
    object oParty = GetEventCreator(eParms);           // The owner of the plot table for this script
    object oConversationOwner = GetEventObject(eParms, 0); // Owner on the conversation, if any
    int nGetResult = FALSE;


    plot_GlobalPlotHandler(eParms);                 // any global plot operations, including debug info

    object oPC = GetHero();
    object oThis = oConversationOwner;

    if(nType == EVENT_TYPE_SET_PLOT)                // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);    // On SET call, the value about to be written
        int nOldValue = GetEventInteger(eParms, 3); // On SET call, the current flag value

        switch(nFlag)
        {
            case GEN_START_CHARGEN:
            {
                StartCharGen(GetHero(),0);
                break;
            }
            case GEN_OPEN_STORE:
            {
                object oStore = GetObjectByTag(STORE_PREFIX + GetTag(oConversationOwner));
                if (IsObjectValid(oStore))
                {
                    ScaleStoreEdited(oStore);
                    OpenStore(oStore);
                }
                else
                {
                    Log_Trace(LOG_CHANNEL_SYSTEMS, GetCurrentScriptName(), "INVALID STORE OBJECT");
                }
                break;
            }

            case GEN_OPEN_ENCHANTING:
            {
                OpenItemUpgradeGUI();

                break;
            }

            case GEN_CURE_PC_INJURIES:
            {
                // Remove all injuries from party members
                Injury_RemoveAllInjuriesFromParty();
                ApplyEffectOnParty(EFFECT_DURATION_TYPE_TEMPORARY,EffectVisualEffect(1021),2.0f);
                break;
            }

            case GEN_EXIT_DESTROY:
            {
                UT_ExitDestroy(oConversationOwner, FALSE );
                break;
            }

            case GEN_OWNER_DISAPPEARS:
            {
                DestroyObject(oConversationOwner, 0);
                break;
            }

            case GEN_OWNER_TURNS_HOSTILE:
            {
                // The owner turns hostile and attacks the player
                UT_CombatStart(oThis, oPC);
                break;
            }

            case GEN_OWNER_DIES:
            {
                KillCreature(oConversationOwner);
                break;
            }

            case GEN_TEAM_TURNS_HOSTILE:
            {
                UT_TeamGoesHostile(GetTeamId(oThis));
                break;
            }

            case GEN_TEAM_WALKS_TO_EXIT:
            {
                UT_TeamExit(GetTeamId(oThis));
                break;
            }

            case GEN_OWNER_MOVES_HOME:
            {
                Rubber_GoHome(oThis);
                break;
            }

            case GEN_AUTOSAVE:
            {
                DoAutoSave();
                break;
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        switch(nFlag)
        {
            case GEN_PC_HAS_HEALING:
            {
                if(HasAbility(oPC, ABILITY_SPELL_HEAL) || HasAbility(oPC, ABILITY_SPELL_CURE)
                    || HasAbility(oPC, ABILITY_SPELL_PURIFY) || HasAbility(oPC, ABILITY_SPELL_REGENERATION))
                    nGetResult = TRUE;
                break;
            }
            case GEN_PC_IN_COMBAT:
            {
                if ( GetCombatState(oPC) )
                    nGetResult = TRUE;
                break;
            }
            case GEN_PC_GORE_COVERED:
            {
                if(GetCreatureGoreLevel(oPC) > 0.0)
                {
                    nGetResult = TRUE;
                }
                break;
            }

        }

    }
    plot_OutputDefinedFlag(eParms, nGetResult);

    return nGetResult;
}