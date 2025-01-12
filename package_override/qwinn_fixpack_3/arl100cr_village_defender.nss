//::///////////////////////////////////////////////
//:: Creature Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creature events script for the defenders of the village in the Arl Eamon
    undead siege. This includes the miltia, the knights and any additional
    people convinced to fight.

    Keeps track of who died in the fight so they can be dead when the player
    returns to the day version of the village.
*/
//:://////////////////////////////////////////////
//:: Created By: David Sims
//:: Created On: April 15, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"

#include "arl_constants_h"
#include "plt_arl100pt_siege"
#include "plt_arl130pt_recruit_dwyn"
#include "plt_arl150pt_loghain_spy"
#include "plt_arl150pt_tavern_drinks"
#include "plt_arl100pt_post_plot"

#include "arl_functions_h"

#include "plt_qwinn_siege"
#include "plt_arl100pt_siege_prep"
#include "plt_arl100pt_siege"

int QwinnGetWoundedFlag(string sTag);
int QwinnGetWoundedFlag(string sTag)
{
   if (sTag == ARL_CR_KNIGHT_1)        return KNIGHT_1_WOUNDED;
   if (sTag == ARL_CR_KNIGHT_2)        return KNIGHT_2_WOUNDED;
   if (sTag == ARL_CR_KNIGHT_3)        return KNIGHT_3_WOUNDED;
   if (sTag == ARL_CR_MILITIA_1)       return MILITIA_1_WOUNDED;
   if (sTag == ARL_CR_MILITIA_2)       return MILITIA_2_WOUNDED;
   if (sTag == ARL_CR_MILITIA_3)       return MILITIA_3_WOUNDED;
   if (sTag == ARL_CR_MILITIA_4)       return MILITIA_4_WOUNDED;
   if (sTag == ARL_CR_MILITIA_5)       return MILITIA_5_WOUNDED;
   if (sTag == ARL_CR_MILITIA_DRUNK_1) return DRUNK_1_WOUNDED;
   if (sTag == ARL_CR_MILITIA_DRUNK_2) return DRUNK_2_WOUNDED;
   if (sTag == ARL_CR_MILITIA_DRUNK_3) return DRUNK_3_WOUNDED;
   if (sTag == ARL_CR_LLOYD)           return LLOYD_WOUNDED;
   if (sTag == ARL_CR_DWYN)            return DWYN_WOUNDED;
   if (sTag == ARL_CR_THUG_1)          return THUG_1_WOUNDED;
   if (sTag == ARL_CR_THUG_2)          return THUG_2_WOUNDED;
   if (sTag == ARL_CR_BERWICK)         return BERWICK_WOUNDED;
   return -1;
}

int QwinnGetCalledFlag(string sTag);
int QwinnGetCalledFlag(string sTag)
{
   if (sTag == ARL_CR_KNIGHT_1)        return KNIGHT_1_CALLED_FOR_HELP;
   if (sTag == ARL_CR_KNIGHT_2)        return KNIGHT_2_CALLED_FOR_HELP;
   if (sTag == ARL_CR_KNIGHT_3)        return KNIGHT_3_CALLED_FOR_HELP;
   if (sTag == ARL_CR_MILITIA_1)       return MILITIA_1_CALLED_FOR_HELP;
   if (sTag == ARL_CR_MILITIA_2)       return MILITIA_2_CALLED_FOR_HELP;
   if (sTag == ARL_CR_MILITIA_3)       return MILITIA_3_CALLED_FOR_HELP;
   if (sTag == ARL_CR_MILITIA_4)       return MILITIA_4_CALLED_FOR_HELP;
   if (sTag == ARL_CR_MILITIA_5)       return MILITIA_5_CALLED_FOR_HELP;
   if (sTag == ARL_CR_MILITIA_DRUNK_1) return DRUNK_1_CALLED_FOR_HELP;
   if (sTag == ARL_CR_MILITIA_DRUNK_2) return DRUNK_2_CALLED_FOR_HELP;
   if (sTag == ARL_CR_MILITIA_DRUNK_3) return DRUNK_3_CALLED_FOR_HELP;
   if (sTag == ARL_CR_LLOYD)           return LLOYD_CALLED_FOR_HELP;
   if (sTag == ARL_CR_DWYN)            return DWYN_CALLED_FOR_HELP;
   if (sTag == ARL_CR_THUG_1)          return THUG_1_CALLED_FOR_HELP;
   if (sTag == ARL_CR_THUG_2)          return THUG_2_CALLED_FOR_HELP;
   if (sTag == ARL_CR_BERWICK)         return BERWICK_CALLED_FOR_HELP;
   return -1;
}

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    int nEventHandled = FALSE;
    object oThis = OBJECT_SELF;

    switch(nEventType)
    {
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: The creature spawns into the game. This can happen only once,
        //       regardless of save games.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_SPAWN:
        {
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature enters the perception area of this creature.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_PERCEPTION_APPEAR:
        {
            int bStealth = GetEventInteger(ev, 0);
            object oCreature = GetEventObject(ev, 0); // the appearing creature
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature exits the perception area of this creature.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_PERCEPTION_DISAPPEAR:
        {
            object oCreature = GetEventObject(ev, 0); // the disappeating creature
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: AI scripts
        // When: The current creatures suffered 1 or more points of damage in a
        //       single attack
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_DAMAGED:
        {
            int bSiegeOnly =
               WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_SIEGE_BEGINS) &&
               !WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_SIEGE_OVER);
            if (bSiegeOnly)
            {
               object oDamager = GetEventCreator(ev);
               int nDamage = GetEventInteger(ev, 0);
               int nDamageType = GetEventInteger(ev, 1);

               float fTotal = GetMaxHealth(oThis);
               float fThird = fTotal/3;
               float fCurrent = GetCurrentHealth(oThis);

               string sTag = GetTag(oThis);
               int nWoundedFlag = QwinnGetWoundedFlag(sTag);
               if (nWoundedFlag < 0) break;
               int nCalledFlag = QwinnGetCalledFlag(sTag);
               if (nCalledFlag < 0) break;

               int nWounded = WR_GetPlotFlag(PLT_QWINN_SIEGE,nWoundedFlag);
               int nCalled  = WR_GetPlotFlag(PLT_QWINN_SIEGE,nCalledFlag);

               if ((fCurrent > fThird) && nWounded && nCalled)
               {
                   WR_SetPlotFlag(PLT_QWINN_SIEGE,nWoundedFlag,FALSE,TRUE);
                   WR_SetPlotFlag(PLT_QWINN_SIEGE,nCalledFlag,FALSE,TRUE);
                   break;
               }
 
               if ((fCurrent <= fThird) && (nCalled == FALSE))
               {
                   WR_SetPlotFlag(PLT_QWINN_SIEGE,nWoundedFlag,TRUE,TRUE);
                   UT_Talk(OBJECT_SELF, OBJECT_SELF);
               }
            }   
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: AI scripts
        // When: Another object tried attacking this creature using melee/ranged
        //       weapons (hit or miss), talents or spells.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_ATTACKED:
        {
            object oAttacker = GetEventObject(ev, 0);



            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: AI scripts
        // When: The current creature dies
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_DEATH:
        {
            object oKiller = GetEventCreator(ev);
            string sTag = GetTag(oThis);
            int bSiegeStarted = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_AREA_ENTERED);
            int bSiegeOver = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_SIEGE_OVER);

            if (sTag == ARL_CR_MURDOCK)
            {
                WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_MURDOCK_DIED_IN_SIEGE, TRUE, TRUE);
            }
            if (sTag == ARL_CR_PERTH)
            {
                if (bSiegeOver == TRUE)
                {
                    WR_SetPlotFlag(PLT_ARL100PT_POST_PLOT, ARL_POST_PLOT_PERTH_DIED, TRUE, TRUE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_PERTH_DIED_IN_SIEGE, TRUE, TRUE);
                }
            }
            if (sTag == ARL_CR_DWYN)
            {
                if (bSiegeStarted == TRUE)
                {
                    WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_DWYN_DIED_IN_SIEGE, TRUE, TRUE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_ARL130PT_RECRUIT_DWYN, ARL_RECRUIT_DWYN_DWYN_IS_DEAD, TRUE, TRUE);
                }
            }
            if (sTag == ARL_CR_LLOYD)
            {
                if (bSiegeStarted == TRUE)
                {
                    WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_LLOYD_DIED_IN_SIEGE, TRUE, TRUE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_ARL150PT_TAVERN_DRINKS, ARL_TAVERN_DRINKS_LLOYD_KILLED, TRUE, TRUE);
                }
            }
            if (sTag == ARL_CR_TOMAS)
            {
                WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_TOMAS_DIED_IN_SIEGE, TRUE, TRUE);
            }
            if (sTag == ARL_CR_BERWICK)
            {
                if (bSiegeStarted == TRUE)
                {
                    WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_BERWICK_DIED_IN_SIEGE, TRUE, TRUE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_ARL150PT_LOGHAIN_SPY, ARL_LOGHAIN_SPY_BERWICK_KILLED, TRUE, TRUE);
                }
            }
            if (sTag == ARL_CR_KNIGHT_1)
            {
                if (bSiegeOver == TRUE)
                {
                    WR_SetPlotFlag(PLT_ARL100PT_POST_PLOT, ARL_POST_PLOT_KNIGHT_1_DIED, TRUE, TRUE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_KNIGHT_1_DIED_IN_SIEGE, TRUE, TRUE);
                }
            }
            if (sTag == ARL_CR_KNIGHT_2)
            {
                if (bSiegeOver == TRUE)
                {
                    WR_SetPlotFlag(PLT_ARL100PT_POST_PLOT, ARL_POST_PLOT_KNIGHT_2_DIED, TRUE, TRUE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_KNIGHT_2_DIED_IN_SIEGE, TRUE, TRUE);
                }
            }
            if (sTag == ARL_CR_KNIGHT_3)
            {
                if (bSiegeOver == TRUE)
                {
                    WR_SetPlotFlag(PLT_ARL100PT_POST_PLOT, ARL_POST_PLOT_KNIGHT_3_DIED, TRUE, TRUE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_KNIGHT_3_DIED_IN_SIEGE, TRUE, TRUE);
                }
            }

            if (sTag == ARL_CR_MILITIA_1)
            {
                WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_MILITIA_1_DIED_IN_SIEGE, TRUE, TRUE);
            }
            if (sTag == ARL_CR_MILITIA_2)
            {
                WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_MILITIA_2_DIED_IN_SIEGE, TRUE, TRUE);
            }
            if (sTag == ARL_CR_MILITIA_3)
            {
                WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_MILITIA_3_DIED_IN_SIEGE, TRUE, TRUE);
            }
            if (sTag == ARL_CR_MILITIA_4)
            {
                WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_MILITIA_4_DIED_IN_SIEGE, TRUE, TRUE);
            }
            if (sTag == ARL_CR_MILITIA_5)
            {
                WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_MILITIA_5_DIED_IN_SIEGE, TRUE, TRUE);
            }
            if (sTag == ARL_CR_MILITIA_DRUNK_1)
            {
                WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_DRUNK_1_DIED_IN_SIEGE, TRUE, TRUE);
            }
            if (sTag == ARL_CR_MILITIA_DRUNK_2)
            {
                WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_DRUNK_2_DIED_IN_SIEGE, TRUE, TRUE);
            }
            if (sTag == ARL_CR_MILITIA_DRUNK_3)
            {
                WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_DRUNK_3_DIED_IN_SIEGE, TRUE, TRUE);
            }

            if (sTag == ARL_CR_THUG_1)
            {
                WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_THUG_1_DIED_IN_SIEGE, TRUE, TRUE);
            }
            if (sTag == ARL_CR_THUG_2)
            {
                WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_THUG_2_DIED_IN_SIEGE, TRUE, TRUE);
            }

            //Prevent looting if a villager dies
            if ((bSiegeStarted == TRUE) && (bSiegeOver == FALSE))
            {
                SetObjectInteractive(oThis, FALSE);
            }



            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: engine or scripting
        // When: this object is initiating dialog as the main speaker. This can
        //       happen when:
        //       1) (engine) A player object clicked to talk on this object
        //       2) (scripting) A trigger script or other script used the utility function UT_Talk to
        //          trigger dialog with this object
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_DIALOGUE:
        {
            object oTarget = GetEventObject(ev, 0); // player or NPC to talk to.
            resource rConversation = GetEventResource(ev, 0); // conversation to use, "" for default

            break;
        }

        ////////////////////////////////////////////////////////////////////////
        // Sent by: Engine
        // When: An item is added to the personal inventory of the current creature
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_INVENTORY_ADDED:
        {
            object oOwner = GetEventCreator(ev); // old owner of the item
            object oItem = GetEventObject(ev, 0); // item added

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: Engine
        // When: An item is removed from the personal inventory of the current creature
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_INVENTORY_REMOVED:
        {
            object oOwner = GetEventCreator(ev); // old owner of the item
            object oItem = GetEventObject(ev, 0); // item added

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: Engine
        // When: The current creature has equipped an item
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_EQUIP:
        {
            object oItem = GetEventCreator(ev); // the item being equipped
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: Engine
        // When: The current creature has unequipped an item
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_UNEQUIP:
        {
            object oItem = GetEventCreator(ev); // the item being unequipped
            break;
        }

        ////////////////////////////////////////////////////////////////////////
        // Sent by: Scripting
        // When: The last creature of a team dies
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_TEAM_DESTROYED:
        {
            int nTeamID = GetEventInteger(ev, 0); // Team ID
            break;
        }

    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_CREATURE_CORE);
    }
}