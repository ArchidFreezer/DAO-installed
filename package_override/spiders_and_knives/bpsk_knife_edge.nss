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
#include "plt_lotpt_actions"
#include "plt_bp_spiders_knives"

const int EVENT_TYPE_DS_FRONT_WAVE      = 22057;
const int EVENT_TYPE_DS_BACK_WAVE       = 22056;
const int EVENT_TYPE_CLEANUP_STRAGGLERS = 22055;

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
            // Check if Lothering has already been destroyed - if so give refuge to Templars.
            if (WR_GetPlotFlag(PLT_LOTPT_ACTIONS, ACTION_LOTHERING_DESTROYED))
            {
//                DisplayFloatyMessage(oPC,"Lothering gone - Knife Edge.",FLOATY_MESSAGE,0xff0000,10.0);
                object oBryant = GetObjectByTag("bpsk_bryant");
                WR_SetObjectActive(oBryant,TRUE);
                SetGroupId(oBryant,GROUP_FRIENDLY);
                SetObjectInteractive(oBryant,FALSE);
                object oVaral = GetObjectByTag("bpsk_varal");
                WR_SetObjectActive(oVaral,TRUE);
                SetGroupId(oVaral,GROUP_FRIENDLY);
                SetObjectInteractive(oVaral,FALSE);
                object oMatron = GetObjectByTag("bpsk_matron_guard");
                WR_SetObjectActive(oMatron,TRUE);
                SetGroupId(oMatron,GROUP_FRIENDLY);
                SetObjectInteractive(oMatron,FALSE);
                object oTemplar = GetObjectByTag("bpsk_templar");
                WR_SetObjectActive(oTemplar,TRUE);
                SetGroupId(oTemplar,GROUP_FRIENDLY);
                SetObjectInteractive(oTemplar,FALSE);

                // If this is the second visit, prepare for darkspawn attack.
                if (WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_QUEST_COMPLETE) &&
                   !WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_MANOR_DEFENDED))
                {
//                    DisplayFloatyMessage(oPC,"Second visit.",FLOATY_MESSAGE,0xff0000,10.0);
                    WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_MANOR_ATTACK,TRUE,TRUE);
                    DelayEvent(20.0,OBJECT_SELF,Event(EVENT_TYPE_DS_FRONT_WAVE));
                }
            }
            WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_BACK_TO_MANOR,TRUE,TRUE);
            UT_Talk(oKnives, oPC);

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

        case EVENT_TYPE_TEAM_DESTROYED:
        {
            int nTeamID = GetEventInteger(ev, 0); // Team ID
//            DisplayFloatyMessage(oPC,"Team destroyed.",FLOATY_MESSAGE,0xff0000,10.0);
            switch (nTeamID)
            {
                case 5:         // Darkspawn attackers
                {
                    WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_MANOR_DEFENDED,TRUE,TRUE);

                    object oBryant = GetObjectByTag("bpsk_bryant");
                    location lBody = GetLocation(oBryant);
                    if (IsDead(oBryant))
                    {
                        //Destroy the old Ser Bryant and make a new one. Resurrection is prone to errors.
                        SetTag(oBryant, "bpsk_bryant_dead");
                        DestroyObject(oBryant);
                        oBryant = CreateObject(OBJECT_TYPE_CREATURE, R"bpsk_bryant.utc", lBody);
                        Gore_ModifyGoreLevel(oBryant, 0.4);
                        SetGroupId(oBryant,GROUP_FRIENDLY);
                        SetObjectInteractive(oBryant,FALSE);
                    }

                    object oVaral = GetObjectByTag("bpsk_varal");
                    if (IsDead(oVaral))
                    {
                        //Destroy the old Ser Varal and make a new one. Resurrection is prone to errors.
                        SetTag(oVaral, "bpsk_varal_dead");
                        lBody = GetLocation(oVaral);
                        DestroyObject(oVaral);
                        oVaral = CreateObject(OBJECT_TYPE_CREATURE, R"bpsk_varal.utc", lBody);
                        Gore_ModifyGoreLevel(oVaral, 0.4);
                        SetGroupId(oVaral,GROUP_FRIENDLY);
                        SetObjectInteractive(oVaral,FALSE);
                    }

                    RemoveNonPartyFollower(oKnives);
                    object oHome = GetObjectByTag("wp_knives");
                    Rubber_SetHome(oKnives,oHome);

                    if (IsDead(oKnives))
                    {
                        //Destroy the old Knives and make a new one. Resurrection is prone to errors.
                        SetTag(oKnives, "bpsk_knives_dead");
                        DestroyObject(oKnives);
                        lBody = GetLocation(oHome);
                        oKnives = CreateObject(OBJECT_TYPE_CREATURE, R"bpsk_knives.utc", lBody);
                        Gore_ModifyGoreLevel(oKnives, 0.4);
                        if (WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_BLADES_RETURNED))
                        {
                            object oCrane = CreateItemOnObject(R"bpsk_crane_low.uti",oKnives);
                            object oCrow = CreateItemOnObject(R"bpsk_crow_low.uti",oKnives);
                            EquipItem(oKnives,oCrane,INVENTORY_SLOT_MAIN);
                            EquipItem(oKnives,oCrow,INVENTORY_SLOT_OFFHAND);
                        }
                    }
                    // Prepare for cutscene
                    ResurrectPartyMembers();
                    UT_LocalJump(oPC, "wp_templars", TRUE, FALSE);
                    lBody = GetSafeLocation(GetLocation(GetObjectByTag("wp_templars")));
                    WR_AddCommand(oKnives,CommandJumpToLocation(lBody),TRUE,TRUE);

                    // Give the reward here as Add-Item fails in/after the cutscene (copies code in bpsk_give_reward)
                    AddCreatureMoney(60000, oPC, TRUE);                                //6 gold.

                    if (WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_BLADES_RETURNED))
                    {
                        object oTest = UT_AddItemToInventory(R"bpsk_amulet_hi.uti",1);   // Recovered amulet
                        if (oTest == OBJECT_INVALID)
                        {
                            DisplayFloatyMessage(oPC,"Amulet NOT received.",FLOATY_MESSAGE,0xff0000,10.0);
                        }
                        // Upgrade previously given weapon, if used
                        int iCount = UT_CountItemInInventory(R"bpsk_knotwood_staff_low.uti");
                        if (iCount > 0)
                        {
                            UT_RemoveItemFromInventory(R"bpsk_knotwood_staff_low.uti");
                            UT_AddItemToInventory(R"bpsk_knotwood_staff_hi.uti");
                        }
                        iCount = UT_CountItemInInventory(R"bpsk_ashyera_dagger.uti");
                        if (iCount > 0)
                        {
                            UT_RemoveItemFromInventory(R"bpsk_ashyera_dagger.uti");
                            UT_AddItemToInventory(R"bpsk_ashyera_dagger_hi.uti",1);
                        }
                        iCount = UT_CountItemInInventory(R"bpsk_hjorrmikill_low.uti");
                        if (iCount > 0)
                        {
                            UT_RemoveItemFromInventory(R"bpsk_hjorrmikill_low.uti");
                            UT_AddItemToInventory(R"bpsk_hjorrmikill_hi.uti");
                        }
                        iCount = UT_CountItemInInventory(R"bpsk_thunderer.uti");
                        if (iCount > 0)
                        {
                            UT_RemoveItemFromInventory(R"bpsk_thunderer.uti");
                            UT_AddItemToInventory(R"bpsk_thunderer_hi.uti");
                        }
                     }
                    WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_DEF_REWARD_GIVEN,TRUE,TRUE);

                    // Start after-battle cutscene
                    CS_LoadCutscene(R"bpsk_knives_final.cut");
                 }
            }

            nEventHandled = TRUE;
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature exits the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_EXIT:
        {

            break;
        }

        ////////////////////////////////////////////////////////////////////////
        // Timed event to create waves of attackingdarkspawn
        // Initially queued by PostLoadExit, then it requeues itself for four waves
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_DS_FRONT_WAVE:
        {
            location lSpawn = GetLocation(GetObjectByTag("start"));
            location lSpawn2 = GetLocation(GetObjectByTag("start2"));
            location lSpawn3 = GetLocation(GetObjectByTag("start3"));
            float fBaseDelay = 10.0;
            if (GetLevel(oPC) < 15)
                fBaseDelay += 5.0;
            float fShortDelay = fBaseDelay / 2.0;
            float fLongDelay = fBaseDelay * 1.5;
            if (!WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_FIRST_WAVE))
            {
//                DisplayFloatyMessage(oPC,"Front wave 1 triggered.",FLOATY_MESSAGE,0xff0000,10.0);
                object oDarkspawn = CreateObject(OBJECT_TYPE_CREATURE,R"hurlock_axe_shield.utc",lSpawn);
                SetTeamId(oDarkspawn,5);
                oDarkspawn = CreateObject(OBJECT_TYPE_CREATURE,R"hurlock_axe_shield.utc",lSpawn2);
                SetTeamId(oDarkspawn,5);
                oDarkspawn = CreateObject(OBJECT_TYPE_CREATURE,R"bpsk_shriek.utc",lSpawn3);
                SetTeamId(oDarkspawn,5);
                WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_FIRST_WAVE,TRUE,FALSE);
                DelayEvent(fShortDelay,OBJECT_SELF,Event(EVENT_TYPE_DS_BACK_WAVE));
                DelayEvent(fBaseDelay,OBJECT_SELF,Event(EVENT_TYPE_DS_FRONT_WAVE));

            }else if (!WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_SECOND_WAVE))
            {
//                DisplayFloatyMessage(oPC,"Front wave 2 triggered.",FLOATY_MESSAGE,0xff0000,10.0);
                object oDarkspawn = CreateObject(OBJECT_TYPE_CREATURE,R"hurlock_lsword_shield.utc",lSpawn);
                SetTeamId(oDarkspawn,5);
                oDarkspawn = CreateObject(OBJECT_TYPE_CREATURE,R"hurlock_lsword_shield.utc",lSpawn2);
                SetTeamId(oDarkspawn,5);
                WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_SECOND_WAVE,TRUE,FALSE);
                DelayEvent(fBaseDelay,OBJECT_SELF,Event(EVENT_TYPE_DS_BACK_WAVE));
                DelayEvent(fLongDelay,OBJECT_SELF,Event(EVENT_TYPE_DS_FRONT_WAVE));

            }else if (!WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_THIRD_WAVE))
            {
//                DisplayFloatyMessage(oPC,"Front wave 3 triggered.",FLOATY_MESSAGE,0xff0000,10.0);
                object oDarkspawn = CreateObject(OBJECT_TYPE_CREATURE,R"hurlock_axe_shield.utc",lSpawn2);
                SetTeamId(oDarkspawn,5);
                oDarkspawn = CreateObject(OBJECT_TYPE_CREATURE,R"hurlock_lsword_shield.utc",lSpawn3);
                SetTeamId(oDarkspawn,5);
                WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_THIRD_WAVE,TRUE,FALSE);
                DelayEvent(fBaseDelay,OBJECT_SELF,Event(EVENT_TYPE_DS_BACK_WAVE));
                DelayEvent(fLongDelay,OBJECT_SELF,Event(EVENT_TYPE_DS_FRONT_WAVE));

            }else if (!WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_FINAL_WAVE))
            {
//                DisplayFloatyMessage(oPC,"Final wave triggered.",FLOATY_MESSAGE,0xff0000,10.0);
                UT_TeamAppears(5,TRUE,OBJECT_TYPE_CREATURE);
                WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_FINAL_WAVE,TRUE,TRUE);
                DelayEvent(70.0,OBJECT_SELF,Event(EVENT_TYPE_CLEANUP_STRAGGLERS));
            }

            UT_TeamGoesHostile(5);
            nEventHandled = TRUE;
            break;
        }

        ////////////////////////////////////////////////////////////////////////
        // Timed event to create waves of attackingdarkspawn
        // Queued by DS_Front_Wave, in three waves
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_DS_BACK_WAVE:
        {
            // Enemy AI doesn't work if the player's currently controlled character is too far away
            // So we have to change the spawn point, depending on where the character is
            object   oDarkspawn_wp = GetObjectByTag("wp_darkspawn");
            location lSpawn = GetLocation(oDarkspawn_wp);
            location lSpawn2 = GetLocation(GetObjectByTag("wp_darkspawn2"));
            location lSpawn3 = GetLocation(GetObjectByTag("wp_darkspawn3"));
            location lTarget = GetLocation(GetObjectByTag("wp_templars"));

            int    bCanSeeBack = FALSE;                     // Assume player cannot see back rooms
            object oControlled = GetMainControlled();       // The player's currect viewpoint
            vector vCurrPos = GetPosition(oControlled);

            if (vCurrPos.x < -18.0)                           // Are we in the back rooms
            {
                bCanSeeBack = TRUE;
            }
            if (vCurrPos.x < 0.0 && vCurrPos.y > 6.0)       // In difficult quadrant of main room - check distance
            {
                if (GetDistanceBetween(oControlled, oDarkspawn_wp) < 12.0)
                {
                    bCanSeeBack = TRUE;
                }
            }

            if (bCanSeeBack)
            {
//                DisplayFloatyMessage(oPC,"Can see back",FLOATY_MESSAGE,0xff0000,10.0);
                lSpawn = GetLocation(GetObjectByTag("backway"));
                lSpawn2 = GetLocation(GetObjectByTag("backway2"));
                lSpawn3 = GetLocation(GetObjectByTag("backway3"));
                lTarget = GetLocation(oDarkspawn_wp);
            } else {
//                DisplayFloatyMessage(oPC,"Cannot see back",FLOATY_MESSAGE,0xff0000,10.0);
            }

            // Now we can spawn the darkspawn at the appropriate point and, if necessary, send them into the action
            if (WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_FIRST_WAVE) &&
               !WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_SECOND_WAVE))
            {
//                DisplayFloatyMessage(oPC,"First back wave.",FLOATY_MESSAGE,0xff0000,10.0);
                object oDarkspawn = CreateObject(OBJECT_TYPE_CREATURE,R"bpsk_hurlock_lbow.utc",lSpawn);
                SetTeamId(oDarkspawn,5);
                WR_TriggerPerception(oDarkspawn, oControlled);
                if (IsPerceivingHostiles(oDarkspawn))
                {
//                    DisplayFloatyMessage(oPC,"Darkspawn can see us",FLOATY_MESSAGE,0xff0000,10.0);
                } else {
//                    DisplayFloatyMessage(oPC,"Darkspawn cannot see us",FLOATY_MESSAGE,0xff0000,10.0);
                    WR_AddCommand(oDarkspawn,CommandMoveToLocation(lTarget,TRUE),TRUE);
                }

                oDarkspawn = CreateObject(OBJECT_TYPE_CREATURE,R"bpsk_hurlock_lbow.utc",lSpawn2);
                SetTeamId(oDarkspawn,5);
                WR_TriggerPerception(oDarkspawn, oControlled);
                if (!IsPerceivingHostiles(oDarkspawn))
                {
                    WR_AddCommand(oDarkspawn,CommandMoveToLocation(lTarget,TRUE),TRUE);
                }

                oDarkspawn = CreateObject(OBJECT_TYPE_CREATURE,R"bpsk_hurlock_emissary.utc",lSpawn3);
                SetTeamId(oDarkspawn,5);
                WR_TriggerPerception(oDarkspawn, oControlled);
                if (!IsPerceivingHostiles(oDarkspawn))
                {
                    WR_AddCommand(oDarkspawn,CommandMoveToLocation(lTarget,TRUE),TRUE);
                }

            }else if (WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_SECOND_WAVE) &&
                     !WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_THIRD_WAVE))
            {
//                DisplayFloatyMessage(oPC,"Second back wave.",FLOATY_MESSAGE,0xff0000,10.0);
                object oDarkspawn = CreateObject(OBJECT_TYPE_CREATURE,R"bpsk_genlock_sbow.utc",lSpawn);
                SetTeamId(oDarkspawn,5);
                WR_TriggerPerception(oDarkspawn, oControlled);
                if (!IsPerceivingHostiles(oDarkspawn))
                {
                    WR_AddCommand(oDarkspawn,CommandMoveToLocation(lTarget,TRUE),TRUE);
                }

                oDarkspawn = CreateObject(OBJECT_TYPE_CREATURE,R"bpsk_genlock_sbow.utc",lSpawn2);
                SetTeamId(oDarkspawn,5);
                WR_TriggerPerception(oDarkspawn, oControlled);
                if (!IsPerceivingHostiles(oDarkspawn))
                {
                    WR_AddCommand(oDarkspawn,CommandMoveToLocation(lTarget,TRUE),TRUE);
                }

            }else{
//                DisplayFloatyMessage(oPC,"Final back wave (assumed).",FLOATY_MESSAGE,0xff0000,10.0);
                object oDarkspawn = CreateObject(OBJECT_TYPE_CREATURE,R"bpsk_hurlock_lbow.utc",lSpawn3);
                SetTeamId(oDarkspawn,5);
                WR_TriggerPerception(oDarkspawn, oControlled);
                if (!IsPerceivingHostiles(oDarkspawn))
                {
                    WR_AddCommand(oDarkspawn,CommandMoveToLocation(lTarget,TRUE),TRUE);
                }

                oDarkspawn = CreateObject(OBJECT_TYPE_CREATURE,R"bpsk_genlock_sbow.utc",lSpawn);
                SetTeamId(oDarkspawn,5);
                WR_TriggerPerception(oDarkspawn, oControlled);
                if (!IsPerceivingHostiles(oDarkspawn))
                {
                    WR_AddCommand(oDarkspawn,CommandMoveToLocation(lTarget,TRUE),TRUE);
                }

                oDarkspawn = CreateObject(OBJECT_TYPE_CREATURE,R"bpsk_shriek.utc",lSpawn2);
                SetTeamId(oDarkspawn,5);
                WR_TriggerPerception(oDarkspawn, oControlled);
                if (!IsPerceivingHostiles(oDarkspawn))
                {
                    WR_AddCommand(oDarkspawn,CommandMoveToLocation(lTarget,TRUE),TRUE);
                }

            }

            UT_TeamGoesHostile(5);              // Just to make sure
            nEventHandled = TRUE;
            break;
        }

        ////////////////////////////////////////////////////////////////////////
        // Timed event to trigger final cutscene with Knives.
        // Queued by TeamDestroyed once all darkspawn are dead.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_CLEANUP_STRAGGLERS:
        {
            // Required because of problem of team 5 death not always triggering as expected because Shriek goes into hiding
            object[] oTeam5 = UT_GetTeam(5);
            if (GetArraySize(oTeam5) == 0) {
//                DisplayFloatyMessage(oPC,"No more enemies.",FLOATY_MESSAGE,0xff0000,10.0);
            } else {
                object oEnemy = oTeam5[0];
                int nEnemyCount = GetArraySize(oTeam5);
                string sName = GetName(oEnemy);
                if ((nEnemyCount > 1)&&(sName != "Shriek")) {
                    int cnt;
                    for (cnt=1; cnt<nEnemyCount; cnt++) {
                        oEnemy = oTeam5[cnt];
                        sName = GetName(oEnemy);
                        if (sName == "Shriek")
                            break;
                    }
                }
                DisplayFloatyMessage(oPC,"Beware: enemy still present: "+sName,FLOATY_MESSAGE,0xff0000,10.0);
                AddCommand(oEnemy, CommandAttack(GetMainControlled()), TRUE);
            }

            nEventHandled = TRUE;
            break;
        }

    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_AREA_CORE);
    }
}