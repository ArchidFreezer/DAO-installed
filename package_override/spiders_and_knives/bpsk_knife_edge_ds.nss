//::///////////////////////////////////////////////
//:: Area script for Knife Edge, near Lothering
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "plot_h"
#include "cutscenes_h"
#include "sys_ambient_h"
#include "effects_h"

#include "bhm_constants_h"
#include "plt_bp_spiders_knives"
#include "plt_bpsk_retake_manor"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    object oCreature = GetEventCreator(ev);
    object oKnives = GetObjectByTag("bpsk_knives");

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

        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: all game objects in the area have loaded
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {
            WR_AddCommand(oKnives,CommandStartConversation(oPC));

            break;
        }


        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature enters the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_ENTER:
        {

            break;
        }

        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature exits the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_EXIT:
        {
            // If quest complete then change World Map to go to cleaned-up Knife Edge
            if (WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_QUEST_COMPLETE))
            {
                object oKnifeEdgeDS = GetObjectByTag("bpsk_wow_knife_edge_ds");
                WR_SetWorldMapLocationStatus(oKnifeEdgeDS,WM_LOCATION_INACTIVE);
                object oKnifeEdge = GetObjectByTag("bpsk_wow_knife_edge");
                WR_SetWorldMapLocationStatus(oKnifeEdge,WM_LOCATION_ACTIVE);
            }

            break;
        }

        case EVENT_TYPE_TEAM_DESTROYED:
        {
            int nTeamID = GetEventInteger(ev, 0); // Team ID
//            DisplayFloatyMessage(oPC,"Team destroyed.",FLOATY_MESSAGE,0xff0000,10.0);
            switch (nTeamID)
            {
                case 3:         // Darkspawn in kitchen
                {
                    if (IsDead(oKnives))
                    {
                        //Destroy the old Knives and make a new one. Resurrection is prone to errors.
                        SetTag(oKnives, "bpsk_knives_dead");
                        location lKnives = GetLocation(oKnives);
                        DestroyObject(oKnives);
                        oKnives = CreateObject(OBJECT_TYPE_CREATURE, R"bpsk_knives.utc", lKnives);
                        Gore_ModifyGoreLevel(oKnives, 0.4);
                        if (WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_BLADES_RETURNED))
                        {
                            object oCrane = CreateItemOnObject(R"bpsk_crane_low.uti",oKnives);
                            object oCrow = CreateItemOnObject(R"bpsk_crow_low.uti",oKnives);
                            EquipItem(oKnives,oCrane,INVENTORY_SLOT_MAIN);
                            EquipItem(oKnives,oCrow,INVENTORY_SLOT_OFFHAND);
                        }
                    }
                    UT_Talk(oKnives, oPC);
                    break;
                }

                case 4:         // Darkspawn in main room
                {
                    WR_SetPlotFlag(PLT_BPSK_RETAKE_MANOR,MANOR_RETAKEN,TRUE,TRUE);

                    if (IsDead(oKnives))
                    {
                        //Destroy the old Knives and make a new one. Resurrection is prone to errors.
                        SetTag(oKnives, "bpsk_knives_dead");
                        location lKnives = GetLocation(oKnives);
                        DestroyObject(oKnives);
                        oKnives = CreateObject(OBJECT_TYPE_CREATURE, R"bpsk_knives.utc", lKnives);
                        Gore_ModifyGoreLevel(oKnives, 0.4);
                        if (WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_BLADES_RETURNED))
                        {
                            object oCrane = CreateItemOnObject(R"bpsk_crane_low.uti",oKnives);
                            object oCrow = CreateItemOnObject(R"bpsk_crow_low.uti",oKnives);
                            EquipItem(oKnives,oCrane,INVENTORY_SLOT_MAIN);
                            EquipItem(oKnives,oCrow,INVENTORY_SLOT_OFFHAND);
                        }
                    }
                    RemoveNonPartyFollower(oKnives);
                    object oHome = GetObjectByTag("knives_home");
                    Rubber_SetHome(oKnives,oHome);
                    WR_AddCommand(oKnives,CommandJumpToObject(oPC),TRUE,TRUE);
                    UT_Talk(oKnives, oPC);
                    break;
                }

            }
            break;
        }
    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_AREA_CORE);
    }
}