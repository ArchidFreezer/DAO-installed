//::///////////////////////////////////////////////
//:: Area Core
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Handles global area events
*/
//:://////////////////////////////////////////////
//:: Created By: Yaron
//:: Created On: July 17th, 2006
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"

#include "den_functions_h"
#include "plt_denpt_captured"
#include "cutscenes_h"
#include "party_h"


void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    int nEventHandled = FALSE;

    switch(nEventType)
    {
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: it is for playing things like cutscenes and movies when
        // you enter an area, things that do not involve AI or actual game play
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_SPECIAL:
        {
            break;
        }
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            if (!GetLocalInt(OBJECT_SELF, ENTERED_FOR_THE_FIRST_TIME))
            {
                object oAlistair = Party_GetFollowerByTag(GEN_FL_ALISTAIR);
                object oPrisoner = UT_GetNearestCreatureByTag(oPC, DEN_CR_PRISONER);
                DEN_StoreInventory(oPC);
                object oPrisonClothes = UT_AddItemToInventory( BDN_IM_PRISON_CLOTHES_R );
                EquipItem( oPC, oPrisonClothes, INVENTORY_SLOT_CHEST );
                HealPartyMembers();
                Injury_RemoveAllInjuriesFromParty();
                object[] arrParty = GetPartyList(oPC);
                int n;
                for (n = 0; n < GetArraySize(arrParty); n++)
                {
                    Effects_RemoveUpkeepEffect(arrParty[n], 0);
                    RemoveEffectsDueToPlotEvent(arrParty[n]);
                }

                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_ALISTAIR_CAPTURED))
                {
                    DEN_StoreInventory(oAlistair);
                    object oPrisonClothes = UT_AddItemToInventory( BDN_IM_PRISON_CLOTHES_R );
                    EquipItem( oAlistair, oPrisonClothes, INVENTORY_SLOT_CHEST );

                    WR_SetObjectActive(oPrisoner, FALSE);
                    UT_LocalJump(oAlistair, DEN_WP_CAPTURED_ALISTAIR);
                }

                int         nIndex;
                int         nTeamSize;
                object []   arTeam;
                arTeam = UT_GetTeam( DEN_TEAM_CAPTURED_DEAD_PRISONERS );
                nTeamSize = GetArraySize(arTeam);
                for ( nIndex = 0; nIndex < nTeamSize; nIndex++ )
                    SetCreatureGoreLevel( arTeam[nIndex], 0.75 );

                WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_AWAKE, TRUE, TRUE);

                // Qwinn added
                object oTrig = UT_GetNearestObjectByTag(oPC,"den400tr_augustine_ambient");
                SetLocalInt(oTrig, TRIG_TALK_ACTIVE_FOR_FLAG, 0);                
            }

            break;
        }

        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        ///////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOADSAVE_PRELOADEXIT:
        {
            if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PARTY_COMING_IN)
                && !WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_REJOINS))
            {
                // PC group id isn't saved, so reset it until the player rejoins
                SetGroupId(oPC, GROUP_NEUTRAL);
            }
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: fires at the same time that the load screen is going away,
        // and can be used for things that you want to make sure the player sees.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature enters the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_ENTER:
        {
            object oCreature = GetEventCreator(ev);
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature exits the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_EXIT:
        {
            object oCreature = GetEventCreator(ev);

            break;
        }
    }
    if (!nEventHandled)
    {
        HandleEvent(ev, DEN_SCRIPT_AREA_CORE);
    }
}