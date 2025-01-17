//::///////////////////////////////////////////////
//:: Area script for Lothering Spider Cave
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
#include "plt_bpsk_rescue_knives"

#include "sys_audio_h"

const int VFX_WEB_CRUST = 1097;

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    object oNathan = GetObjectByTag("bpsk_nathan");

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
            break;
        }


        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature enters the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_ENTER:
        {
//            DisplayFloatyMessage(oPC,"Cave entered.",FLOATY_MESSAGE,0xff0000,10.0);
            WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_CAVE_ENTERED,TRUE);
            // Mark cocoon if quest begun
            if ((WR_GetPlotFlag(PLT_BPSK_RESCUE_KNIVES,KNIVES_QUEST_ACCEPTED)) &&
                !(WR_GetPlotFlag(PLT_BPSK_RESCUE_KNIVES,KNIVES_FOUND)))
            {
                object oCocoon = GetObjectByTag("bpsk_cocoon_knives");
                if (IsObjectValid(oCocoon))
                {
                    SetPlotGiver(oCocoon,TRUE);
                }else{
                    DisplayFloatyMessage(oPC,"Cocoon not found.",FLOATY_MESSAGE,0xff0000,10.0);
                }
            }
            ApplyEffectVisualEffect(oNathan,oNathan,VFX_WEB_CRUST,EFFECT_DURATION_TYPE_PERMANENT,0.0);
            break;
        }

        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature exits the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_EXIT:
        {
            object oCreature = GetEventCreator(ev);

            // Force heirlooms found flag set if it failed first time
            if (!WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_HEIRLOOMS_FOUND))
            {
                int nMedallion = UT_CountItemInInventory(R"bpsk_amulet.uti");
                if (nMedallion >=1)
                {
                    DisplayFloatyMessage(oPC,"Fixing heirlooms plot flag!",FLOATY_MESSAGE,0xff0000,10.0);
                    WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_HEIRLOOMS_FOUND,TRUE,TRUE);
                }
            }

            break;
        }

        case EVENT_TYPE_TEAM_DESTROYED:
        {
            int nTeamID = GetEventInteger(ev, 0); // Team ID
//            DisplayFloatyMessage(oPC,"Team destroyed.",FLOATY_MESSAGE,0xff0000,10.0);
            switch (nTeamID)
            {
                case 1:         // Spiders in cocoon area
                {
                    //Highlight moving cocoon
                    WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_COCOONS_FOUND,TRUE,TRUE);
                    UT_Talk(oNathan,oNathan);   // Set Nathan's body position
                    break;
                }

                case 2:         // Spiders guarding spider queen
                {
                    //Stop audio related to spiders
                    AudioTriggerPlotEvent(BHM_AUDIO_TOGGLE_SPIDERS_DIED);
                    WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_SPIDERS_KILLED,TRUE,TRUE);
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