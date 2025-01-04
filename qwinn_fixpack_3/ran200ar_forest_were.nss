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
#include "events_h"
#include "2da_constants_h"
#include "ran_constants_h"
#include "cutscenes_h"
#include "ran_repeat_h"
#include "plt_ntb000pt_main"


void main()
{
    event       ev              = GetCurrentEvent();
    int         nEventType      = GetEventType(ev);
    string      sDebug;
    object      oPC             = GetHero();
    object      oParty          = GetParty(oPC);
    int         nEventHandled   = FALSE;

    switch(nEventType)
    {

        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {

            resource [] rMonster;
            string   [] sMonster;
            string   [] sWPMonster;

            rMonster[0]     = R"ran200cr_werewolf_leader.utc";
            sMonster[0]     = "werewolf_alpha";
            sWPMonster[0]   = "wp_werewolf_leader";

            rMonster[1]     = R"ran200cr_werewolf_a.utc";
            sMonster[1]     = "werewolf_a";
            sWPMonster[1]   = "wp_werewolf_a";

            rMonster[2]     = R"ran200cr_werewolf_b.utc";
            sMonster[2]     = "werewolf_b";
            sWPMonster[2]   = "wp_werewolf_b";

            rMonster[3]     = R"ran200cr_werewolf_c.utc";
            sMonster[3]     = "werewolf_c";
            sWPMonster[3]   = "wp_werewolf_c";

            rMonster[4]     = R"ran200cr_werewolf_d.utc";
            sMonster[4]     = "werewolf_d";
            sWPMonster[4]   = "wp_werewolf_d";

            rMonster[5]     = R"ran200cr_werewolf_e.utc";
            sMonster[5]     = "werewolf_e";
            sWPMonster[5]   = "wp_werewolf_e";

            rMonster[6]     = R"ran200cr_werewolf_f.utc";
            sMonster[6]     = "werewolf_f";
            sWPMonster[6]   = "wp_werewolf_f";

            rMonster[7]     = R"ran200cr_werewolf_g.utc";
            sMonster[7]     = "werewolf_g";
            sWPMonster[7]   = "wp_werewolf_g";

            RAN_RestartRandomArea(sMonster, rMonster, sWPMonster);

            break;
        }

        case EVENT_TYPE_ENTER:
        {
            object oCreature = GetEventCreator(ev);

            float fTime = 4.8;
            int i;
            location [] aLoc;
            aLoc[0] = GetLocation(GetObjectByTag("wpmvwalpha_1"));
            aLoc[1] = GetLocation(GetObjectByTag("wpmvwalpha_2"));
                                                  
            // Qwinn added
            object oCampfire = UT_GetNearestObjectByTag(oPC,"genip_campfire");
            SetObjectInteractive(oCampfire,FALSE);



            // Wait for the character


            AddCommand(GetObjectByTag("werewolf_alpha"), CommandMoveToMultiLocations(aLoc, TRUE), TRUE, TRUE);
            AddCommand(GetObjectByTag("werewolf_alpha"), CommandTurn(250.0), FALSE, TRUE);
            AddCommand(GetObjectByTag("werewolf_alpha"), CommandPlayAnimation(101,3), FALSE, TRUE);
            AddCommand(GetObjectByTag("werewolf_a"), CommandWait(fTime), TRUE, TRUE);
            AddCommand(GetObjectByTag("werewolf_b"), CommandWait(fTime), TRUE, TRUE);
            AddCommand(GetObjectByTag("werewolf_c"), CommandWait(fTime), TRUE, TRUE);
            AddCommand(GetObjectByTag("werewolf_d"), CommandWait(fTime), TRUE, TRUE);
            AddCommand(GetObjectByTag("werewolf_e"), CommandWait(fTime), TRUE, TRUE);
            AddCommand(GetObjectByTag("werewolf_f"), CommandWait(fTime), TRUE, TRUE);
            AddCommand(GetObjectByTag("werewolf_g"), CommandWait(fTime), TRUE, TRUE);



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
        HandleEvent(ev, RESOURCE_SCRIPT_AREA_CORE);
    }
}