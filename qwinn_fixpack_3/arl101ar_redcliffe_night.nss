//::///////////////////////////////////////////////
//:: arl101ar_redcliffe_night
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Area events for the night version of redcliffe village. Essentialy, this
    script starts the zombie battle when the player is jumped to the area after
    sundown cutscene.

*/
//:://////////////////////////////////////////////
//:: Created By: David Sims
//:: Created On: April 7th, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"

#include "plt_arl150pt_loghain_spy"
#include "plt_arl150pt_tavern_drinks"
#include "plt_arl130pt_recruit_dwyn"
#include "plt_arl100pt_siege"

#include "arl_constants_h"
#include "cli_constants_h"         

// Qwinn added:
#include "plt_arl150pt_loghain_spy"


void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    int nEventHandled = FALSE;
    object oArea = OBJECT_SELF;

    switch(nEventType)
    {
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: it is for playing things like cutscenes and movies when
        // you enter an area, things that do not involve AI or actual game play
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_SPECIAL:
        {
            WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_AREA_ENTERED, TRUE, TRUE);
        }
        break;
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            CreatePool(ARL_R_CR_SIEGE_CORPSE, 30);
            
            // Qwinn:  Remove letter from berwick if we already have it.
            if (WR_GetPlotFlag(PLT_ARL150PT_LOGHAIN_SPY, ARL_LOGHAIN_SPY_PC_HAS_BERWICKS_LETTER))
            {   object oBerwick = UT_GetNearestCreatureByTag(oPC, ARL_CR_BERWICK);
                UT_RemoveItemFromInventory(ARL_R_IT_SPY_LETTER, 1, oBerwick);
            }
            break;
    
        }
        break;
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: fires at the same time that the load screen is going away,
        // and can be used for things that you want to make sure the player sees.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {


            //Bring forth the zombies!


        }
        break;
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature enters the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_ENTER:
        {
            object oCreature = GetEventCreator(ev);


        }
        break;
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature exits the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_EXIT:
        {
            object oCreature = GetEventCreator(ev);


        }
        break;
        ////////////////////////////////////////////////////////////////////////
        // Sent by: Scripting
        // When: The last creature of a team dies
        ////////////////////////////////////////////////////////////////////////
        case ARL_EVENT_BATTLE_ARMY_DEPLETED:
        {
            int nTeamID = GetEventInteger(ev, 0); // Team ID

            int nPlotFlag = -1;

            //Set a plot flag depending on which team of corpses died.
            switch(nTeamID)
            {
                case ARL_TEAM_SIEGE_WINDMILL_CORPSES_1:
                {
                    nPlotFlag = ARL_SIEGE_WINDMILL_TEAM_1_DEATH;
                }
                break;
                case ARL_TEAM_SIEGE_WINDMILL_CORPSES_2:
                {
                    nPlotFlag = ARL_SIEGE_WINDMILL_TEAM_2_DEATH;
                }
                break;
                case ARL_TEAM_SIEGE_WINDMILL_CORPSES_3:
                {
                    nPlotFlag = ARL_SIEGE_WINDMILL_TEAM_3_DEATH;
                }
                break;
                case ARL_TEAM_SIEGE_VILLAGE_CORPSES:
                {
                    nPlotFlag = ARL_SIEGE_VILLAGE_TEAM_DEATH;
                }
                break;
            }

            if (nPlotFlag != -1)
            {
                if (WR_GetPlotFlag(PLT_ARL100PT_SIEGE, nPlotFlag) == FALSE)
                {
                    WR_SetPlotFlag(PLT_ARL100PT_SIEGE, nPlotFlag, TRUE, TRUE);
                }
            }


        }
        break;

        ////////////////////////////////////////////////////////////////////////
        // Sent by: Scripting (arl100pt_siege.nss)
        // It's time to add another fire vfx to the fire trap
        ////////////////////////////////////////////////////////////////////////
        case ARL_EVENT_FIRE_TRAP_SPREAD:
        {
            location lLocation = GetEventLocation(ev, 0);
            effect effFire = EffectVisualEffect(4014);

            Engine_ApplyEffectAtLocation( EFFECT_DURATION_TYPE_PERMANENT, effFire, lLocation, 0.0f, oArea );

        }
        break;

        ////////////////////////////////////////////////////////////////////////
        // Sent by: Scripting (arl100pt_siege.nss)
        // It's time to add another fire vfx to the fire trap
        ////////////////////////////////////////////////////////////////////////
        case ARL_EVENT_BATTLE_OVER:
        {
            //NOTE: The WR function wrapper is not used here deliberatly.
            //The pc might still be in combat, and this area transition must fire.
            WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_PLAYER_RETURNS_FROM_SIEGE, TRUE, TRUE);
            DoAreaTransition(ARL_AR_REDCLIFFE_VILLAGE, ARL_WP_AFTER_SIEGE);
        }
        break;

    }
    if (!nEventHandled)
    {
        HandleEvent(ev, CLI_AR_ARMY_SCRIPT);
    }
}