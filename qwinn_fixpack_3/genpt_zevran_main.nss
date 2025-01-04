//::///////////////////////////////////////////////
//:: Plot Events
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Main Plot events for Zevran
*/
//:://////////////////////////////////////////////
//:: Created By: Yaron
//:: Created On: July 21st, 2006
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "cutscenes_h"
#include "ran_constants_h"
#include "den_functions_h"
#include "effects_h"
#include "approval_h"

#include "plt_genpt_zevran_main"
#include "plt_genpt_app_zevran"
#include "plt_gen00pt_class_race_gend"
#include "plt_mnp000pt_generic"
#include "plt_gen00pt_party"
#include "plt_cod_cha_zevran"

#include "plt_cod_cha_zevran"
#include "plt_mnp000pt_autoss_main2"

void RAN_EquipWeapons(object oNPC);

// Plays CS and makes individuals hostile (except survivor)
void RAN_SpringAmbush();

// Plot var to make survivor attack
void RAN_SurvivorAttack();
void RAN_SurvivorRunToAmbush();

int StartingConditional()
{
    event       eParms              = GetCurrentEvent();            // Contains all input parameters
    int         nType               = GetEventType(eParms);         // GET or SET call
    string      strPlot             = GetEventString(eParms, 0);    // Plot GUID
    int         nFlag               = GetEventInteger(eParms, 1);   // The bit flag # being affected
    object      oParty              = GetEventCreator(eParms);      // The owner of the plot table for this script
    object      oConversationOwner  = GetEventObject(eParms, 0);    // Owner on the conversation, if any
    int         nResult             = FALSE;                        // used to return value for DEFINED GET events
    object      oPC                 = GetHero();
    object      oZevran             = Party_GetFollowerByTag(GEN_FL_ZEVRAN);
    object      oSurvivor           = UT_GetNearestCreatureByTag(oPC, RAN_CR_SURVIVOR);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            //------------------------------------------------------------------
            // Meeting Zevran for first time Encounter vars
            //------------------------------------------------------------------

            // Survivor leads player to encounter
            case ZEVRAN_MAIN_PLAYER_AGREED_TO_HELP_WOMAN:
            {
                RAN_SurvivorRunToAmbush();
                break;
            }
            case ZEVRAN_MAIN_AMBUSH_START:
            {
                object oTreeUp = UT_GetNearestObjectByTag(oPC,RANIP_TREE_DEAD);
//                object oTreeDown = UT_GetNearestObjectByTag(oPC,RANIP_TREE_DEAD_DOWN);

                WR_SetObjectActive(oTreeUp,FALSE);
                UT_TeamAppears(RAN_TEAM_RAN401_INVISIBLE,TRUE,OBJECT_TYPE_PLACEABLE);
//                WR_SetObjectActive(oTreeDown,TRUE);

                UT_SetTeamInteractive(RAN_TEAM_RAN401_ASSASSINS,TRUE);
                UT_SetTeamInteractive(RAN_TEAM_RAN401_TRAPS,TRUE,OBJECT_TYPE_PLACEABLE);

                RAN_SurvivorAttack();

                object [] arAssassins = GetTeam(RAN_TEAM_RAN401_ASSASSINS);
                int i;
                int nSize           = GetArraySize(arAssassins);

                object oCurrent;
                object oPC          = GetHero();

                for(i = 0; i < nSize; i++)
                {
                    oCurrent = arAssassins[i];
                    WR_SetObjectActive(oCurrent, TRUE);
                    // Make sure to set this flag back to 0 to avoid problems with savegames.
//                    SetLocalInt(oCurrent, CREATURE_SPAWN_DEAD, -1);
                    // Set everyone save the "Survivor" agressive
                    UT_CombatStart(oCurrent, oPC);
                }
                UT_LocalJump(oPC,RAN_WP_AFTER_TREE_PC);

                int nIndex;
                object [] arParty = GetPartyList(oPC);
                nSize = GetArraySize(arParty);

                for(nIndex = 0; nIndex < nSize; nIndex++)
                {
                    oCurrent = arParty[nIndex];

                //NOT sure why this check was in place;
                //it meant the PC wasn't being jumped with the party
                //    if(IsHero(oCurrent) == FALSE)
//                    {
                        Log_Trace(LOG_CHANNEL_PLOT,"genpt_zevran_main.nss","Party Member Moved: " + IntToString(nIndex));
                        UT_LocalJump(oCurrent, "ran401wp_after_tree_" + IntToString(nIndex));
//                    }
                }

                // Qwinn added:
                object oZevran = UT_GetNearestCreatureByTag(oPC,"ran401cr_zevran");
                SetLocalInt(oZevran,"TS_TREASURE_GENERATED",-1);
                break;
            }

            // Ran401 Zevran Encounter 1
            // Player oblivious to ambush (Steps on trigger)
            // Or triggered after the detected ambush code
            case ZEVRAN_MAIN_TRIGGER_AMBUSH_FIGHT:
            {
                // If Ambush hasn't been detected, spring ambush
                //if (!WR_GetPlotFlag(PLT_GENPT_ZEVRAN_MAIN, ZEVRAN_MAIN_TRIGGER_AMBUSH))
                //{
                    // Assassin stand up (includes Zevran)
                    RAN_SpringAmbush();
                //}

                // Survivor Attacks
//                RAN_SurvivorAttack();


                break;
            }

            // Ran401 Zevran Encounter 1
            // Player notices the ambush
            case ZEVRAN_MAIN_TRIGGER_AMBUSH:
            {
                RAN_SurvivorRunToAmbush();

                // Prepare assassins to stand up after cutscene(includes Zevran)
                //object [] arAssassins   = GetTeam(RAN_TEAM_RAN401_ASSASSINS);
                //int     i;
                //int     nSize           = GetArraySize(arAssassins);
                //RAN_SurvivorRunToAmbush();

//                RAN_SpringAmbush();



                break;
            }
            case ZEVRAN_MAIN_KILLED_BY_PLAYER:
            {
                // kill Zevran
               // resource rKill = R"107055_kill_zevran.cut";
               // CS_LoadCutscene(rKill);
                WR_SetPlotFlag(PLT_COD_CHA_ZEVRAN, COD_CHA_ZEVRAN_KILLED_NOT_HIRED, TRUE, TRUE);//signed
                //KillCreature(oZevran,oPC);
                //setting him inactive rather than killing him to avoid a second death rattle
                WR_SetObjectActive(oZevran,FALSE);
                break;
            }
            case ZEVRAN_MAIN_KILLED_BEFORE_INTRODUCTION:
            {
                // kill Zevran
               // resource rKill = R"107028_kill_zevran.cut";
//                CS_LoadCutscene(rKill);
                WR_SetPlotFlag(PLT_GENPT_ZEVRAN_MAIN,ZEVRAN_MAIN_KILLED_BY_PLAYER,TRUE);
                WR_SetPlotFlag(PLT_COD_CHA_ZEVRAN, COD_CHA_ZEVRAN_KILLED_NOT_HIRED, TRUE, TRUE);//signed
                //KillCreature(oZevran,oPC);
                //setting him inactive rather than killing him to avoid a second death rattle
                WR_SetObjectActive(oZevran,FALSE);
                break;
            }

            //------------------------------------------------------------------
            //------------------------------------------------------------------
            case ZEVRAN_MAIN_LEAVES_FOR_GOOD:
            {
                // leave nicely
                UT_ExitDestroy(oZevran,TRUE,"wp_exit");
                break;
            }
            case ZEVRAN_MAIN_START_AMBUSH_FIGHT_ZEVRAN_ALLY:
            {
                //ACTION: combat begins, Zevran fights beside the player
                //Note: Zevran may be in the party in which case battle starts as normal, or he may not
                //be in the party in which case he fights alongside the party.
                //When the fight is over, set ZEVRAN_EVENT_AMBUSH_OVER_ZEVRAN_ALLY and run Zevran's convesation.
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_PARTY) == FALSE)
                {
                    Party_LockFollower(oZevran,GEN_ZEVRAN_IN_PARTY,GEN_ZEVRAN_IN_CAMP);
                    //beneath this there will be a function that:
                    //clears the party
                    //sets Zevran in the party (locked)
                    //opens the party picker for the PC to choose the other 2 slots
                    //WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_PARTY, TRUE,TRUE);
                }
                UT_TeamAppears(DEN_TEAM_CROWS);
//                UT_TeamAppears(DEN_TEAM_CROW_TRAPS,TRUE,OBJECT_TYPE_PLACEABLE);
                UT_TeamGoesHostile(DEN_TEAM_CROWS);
                DEN_TeamHelp(DEN_TEAM_CROWS, TRUE);

                break;
            }
            case ZEVRAN_MAIN_START_AMBUSH_FIGHT_ZEVRAN_FLEE:
            {
                //The fight begins.
                UT_TeamAppears(DEN_TEAM_CROWS);
//                UT_TeamAppears(DEN_TEAM_CROW_TRAPS,TRUE,OBJECT_TYPE_PLACEABLE);
                UT_TeamGoesHostile(DEN_TEAM_CROWS);
                DEN_TeamHelp(DEN_TEAM_CROWS, TRUE);

                //half of the assassins also run  off.
                object [] arBow = UT_GetAllObjectsInAreaByTag(DEN_CR_CROW_BOW,OBJECT_TYPE_CREATURE);
                int i;
                int nSize = GetArraySize(arBow);
                object oCurrent;
                for(i = 0; i < nSize; i++)
                {
                    oCurrent = arBow[i];
                    WR_DestroyObject(oCurrent);
                }
                //ACTION: Zevran leaves,
                //Note: Zevran may be in the party when he leaves, or he may not.
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_PARTY) == FALSE)
                {
                    WR_SetObjectActive(oZevran,FALSE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_CAMP, TRUE,TRUE);
                }
                break;
            }
            case ZEVRAN_MAIN_START_AMBUSH_FIGHT_ZEVRAN_ENEMY:
            {
                //ACTION: Zevran joins the Crows, fight begins
                //Note: Zevran may be in the party when he switches, or he may not.

                WR_SetPlotFlag(PLT_GENPT_ZEVRAN_MAIN, ZEVRAN_MAIN_LEAVES_FOR_GOOD, TRUE);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_RECRUITED, FALSE, TRUE);

                object oMain = GetItemInEquipSlot(INVENTORY_SLOT_MAIN,oZevran);
                object oOffhand = GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND,oZevran);

                if(!IsObjectValid(oMain))
                {
                    Log_Trace(LOG_CHANNEL_PLOT,"genpt_zevran_main.nss","Main Hand empty");
                    resource rMain = R"gen_im_wep_mel_lsw_lsw.uti";
                    object oNewMain = CreateItemOnObject(rMain,oZevran);
                    if(IsObjectValid(oNewMain))
                    {
                        EquipItem(oZevran,oNewMain,INVENTORY_SLOT_MAIN);
    //                    command cMainhand = CommandEquipItem(oNewMain,INVENTORY_SLOT_MAIN);
//                        AddCommand(oZevran,cMainhand,TRUE,TRUE);
                    }
                    else
                    {
                        Log_Trace(LOG_CHANNEL_PLOT,"genpt_zevran_main.nss","Main Hand still empty");
                    }
                    if(!IsObjectValid(oOffhand))
                    {
                        Log_Trace(LOG_CHANNEL_PLOT,"genpt_zevran_main.nss","Off Hand empty");
                        resource rOffhand = R"gen_im_wep_mel_dag_crw.uti";
                        object oNewOffhand = CreateItemOnObject(rOffhand,oZevran);
                        if(IsObjectValid(oNewOffhand))
                        {
                            EquipItem(oZevran,oNewOffhand,INVENTORY_SLOT_MAIN);
        //                    command cOffhand = CommandEquipItem(oNewOffhand,INVENTORY_SLOT_OFFHAND);
          //                  AddCommand(oZevran,cOffhand,TRUE,TRUE);
                        }
                        else
                        {
                            Log_Trace(LOG_CHANNEL_PLOT,"genpt_zevran_main.nss","Off Hand still empty");
                        }
                    }
                    else
                    {
                        string sOffhand = GetTag(oOffhand);
                        Log_Trace(LOG_CHANNEL_PLOT,"genpt_zevran_main.nss","Off Hand: " + sOffhand );
                    }
                }
                else
                {
                    string sMain = GetTag(oMain);
                    Log_Trace(LOG_CHANNEL_PLOT,"genpt_zevran_main.nss","Main Hand: " + sMain);
                }

                UT_TeamAppears(DEN_TEAM_CROWS);
//                UT_TeamAppears(DEN_TEAM_CROW_TRAPS,TRUE,OBJECT_TYPE_PLACEABLE);
                UT_TeamGoesHostile(DEN_TEAM_CROWS);
                DEN_TeamHelp(DEN_TEAM_CROWS, TRUE);
                SetTeamId(oZevran,DEN_TEAM_CROWS);

                SetGroupId(UT_GetNearestCreatureByTag(oPC,GEN_FL_ZEVRAN), GROUP_ZEVRAN_HOSTILE);

                object[] oEquip = GetItemsInInventory(oZevran, GET_ITEMS_OPTION_EQUIPPED);
                int nSize = GetArraySize(oEquip);
                int i;
                for(i = 0; i < nSize; i++)
                {
                    SetItemDroppable(oEquip[i], TRUE);
                }
                SetImmortal(oZevran,FALSE);
                WR_SetObjectActive(oZevran, TRUE);
                UT_CombatStart(UT_GetNearestCreatureByTag(oPC,GEN_FL_ZEVRAN), oPC);
                break;
            }
            case ZEVRAN_MAIN_START_AMBUSH_FIGHT_ZEVRAN_GONE:
            {
                //ACTION: fight begins
                UT_TeamAppears(DEN_TEAM_CROWS);
//                UT_TeamAppears(DEN_TEAM_CROW_TRAPS,TRUE,OBJECT_TYPE_PLACEABLE);
                UT_TeamGoesHostile(DEN_TEAM_CROWS);
                DEN_TeamHelp(DEN_TEAM_CROWS, TRUE);
                break;
            }
            case ZEVRAN_MAIN_BOOTS_EQUIPPED:
            {
                resource rBoots = R"gen_im_arm_bot_lgt_ant.uti";
                //ACTION: puts on the Calabrian leather boots
                object oBoots = CreateItemOnObject(rBoots,oPC);
                EquipItem(oZevran,oBoots,INVENTORY_SLOT_BOOTS);
                break;
            }

            case ZEVRAN_MAIN_GLOVES_EQUIPPED:
            {
                resource rGloves = R"gen_im_arm_glv_lgt_dal.uti";
                //ACTION: wears the Green Dalish gloves
                object oGloves = CreateItemOnObject(rGloves,oPC);
                EquipItem(oZevran,oGloves,INVENTORY_SLOT_GLOVES);
                break;
            }

            case ZEVRAN_MAIN_SET_FRIENDLY_LOVE_ELIGIBLE:
            {
                //SET: APP_ZEVRAN_LOVE_ELIGIBLE
                //SET_APP_ZEVRAN_FRIENDLY_ELIGIBLE
                WR_SetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_LOVE_ELIGIBLE, TRUE, TRUE);
                WR_SetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_FRIENDLY_ELIGIBLE, TRUE, TRUE);
                break;
            }

            case ZEVRAN_MAIN_GOES_HOSTILE:
            {
                //Take an automatic screenshot
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN2, AUTOSS_ZEV_KILLED_IN_PARTY, TRUE, TRUE);

                //ACTION: Zevran goes hostile
                //This is used for any time Zevran leaves the party on bad terms
                //and attacks.
                //This could happen at camp or any number of places including camp.
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_RECRUITED, FALSE);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_CAMP, FALSE);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_PARTY, FALSE);
                int nFollower = Approval_GetFollowerIndex(oZevran);
                Approval_SetRomanceActive(nFollower, FALSE);

                WR_SetFollowerState(oZevran, FOLLOWER_STATE_INVALID, TRUE);
                SetGroupId(oZevran, 46);
                // SetZevran Hostile
                SetImmortal(oZevran,FALSE);   
                
                // Qwinn added all but the UT_CombatStart
                object[] arInventory = GetItemsInInventory(oZevran);
                int nInventorySize = GetArraySize(arInventory);
                int nIndex = 0;
                for (nIndex = 0; nIndex < nInventorySize; nIndex++)
                   SetItemDroppable(arInventory[nIndex],TRUE);
                UT_CombatStart(oZevran, oPC);
                WR_SetPlotFlag(PLT_GENPT_ZEVRAN_MAIN, ZEVRAN_MAIN_KILLED_BY_PLAYER,TRUE,FALSE);
                WR_SetPlotFlag(PLT_COD_CHA_ZEVRAN,COD_CHA_ZEVRAN_NEUTRAL_20, FALSE, TRUE);
                WR_SetPlotFlag(PLT_COD_CHA_ZEVRAN,COD_CHA_ZEVRAN_KILLED_AFTER_HIRING,TRUE,TRUE);

                break;
            }
            case ZEVRAN_MAIN_APPEARS_TO_TALIESIN:
            {
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_PARTY) == FALSE)
                {
                    SetObjectActive(oZevran, TRUE);
                }
                break;
            }
            case ZEVRAN_MAIN_FIRST_HIRED:
            {
                WR_SetPlotFlag(PLT_COD_CHA_ZEVRAN,COD_CHA_ZEVRAN_HIRED,TRUE,TRUE);
                UT_TeamAppears(RAN_TEAM_RAN401_TRAPS,FALSE,OBJECT_TYPE_PLACEABLE);
                UT_SetTeamInteractive(RAN_TEAM_RAN401_TRAPS,FALSE,OBJECT_TYPE_PLACEABLE);
                // Qwinn added
                WR_SetPlotFlag(PLT_GENPT_APP_ZEVRAN,APP_ZEVRAN_NO_APPROVAL_NOTIFICATION,FALSE);
                WR_SetPlotFlag(PLT_GENPT_APP_ZEVRAN,APP_ZEVRAN_NOTIFY_APPROVAL_FROM_ZERO,TRUE);
                WR_SetPlotFlag(PLT_GENPT_ZEVRAN_MAIN, ZEVRAN_MAIN_RECRUITED, TRUE, TRUE);
                break;
            }
            case ZEVRAN_MAIN_AGREED_TO_TEACH_ASSASSIN:
            {
                RW_UnlockSpecializationTrainer(SPEC_ROGUE_ASSASSIN);
                break;
            }
            case ZEVRAN_MAIN_KISSES_FAREWELL:
            {
                //set codex entry for Zevran leaving
                WR_SetPlotFlag(PLT_COD_CHA_ZEVRAN,COD_CHA_ZEVRAN_FIRED,TRUE);
                break;
            }
            case ZEVRAN_MAIN_LEAVES_AFTER_KISSING_FAREWELL:
            {
                WR_SetPlotFlag(PLT_GEN00PT_PARTY,GEN_ZEVRAN_RECRUITED,FALSE,TRUE);
                WR_SetObjectActive(oZevran,FALSE);
                break;
            }
            case ZEVRAN_MAIN_LEAVES_PARTY_AND_GOES:
            {
                WR_SetPlotFlag(PLT_GEN00PT_PARTY,GEN_ZEVRAN_RECRUITED,FALSE,TRUE);
                WR_SetObjectActive(oZevran,FALSE);
                // Qwinn added
                WR_SetPlotFlag(PLT_GENPT_ZEVRAN_MAIN, ZEVRAN_MAIN_LEAVES_FOR_GOOD,TRUE,FALSE);
                break;
            }
            case ZEVRAN_MAIN_RECRUITED:
            {
                WR_SetPlotFlag(PLT_GEN00PT_PARTY,GEN_ZEVRAN_RECRUITED,TRUE,TRUE);
                //re-equip Zevran
                object oSword = GetItemPossessedBy(oPC,"gen_im_wep_mel_lsw_lsw");
                object oDagger = GetItemPossessedBy(oPC,"gen_im_wep_mel_dag_crw");
                object oMain = GetItemInEquipSlot(INVENTORY_SLOT_MAIN,oZevran);
                object oOff = GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND,oZevran);
                if((IsObjectValid(oMain) == FALSE) && (IsObjectValid(oSword) == TRUE))
                {
                    EquipItem(oZevran,oSword,INVENTORY_SLOT_MAIN);
                }
                if((IsObjectValid(oOff) == FALSE) && (IsObjectValid(oDagger) == TRUE))
                {
                    EquipItem(oZevran,oDagger,INVENTORY_SLOT_OFFHAND);
                }
                break;
            }

            // Qwinn added
            case ZEVRAN_MAIN_PLAYER_REFUSED_EARRING:
            {
               if (nValue == 0)
                  WR_SetPlotFlag(PLT_GENPT_ZEVRAN_MAIN,ZEVRAN_MAIN_GIVES_PC_EARRING,TRUE,TRUE);
               break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case ZEVRAN_MAIN_CAN_START_MAKE_LOVE:
            {
                //IF: APP_ZEVRAN_IS_ADORE
                //and IF (NOT): APP_ZEVRAN_MAKE_LOVE
                //and IF: party is in camp
                int bAdore = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_IS_ADORE, TRUE);
                int bMakeLove =  WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_MAKE_LOVE, TRUE);
                int bAtCamp = WR_GetPlotFlag(PLT_MNP000PT_GENERIC, MAIN_PLOT_GENERIC_PARTY_AT_CAMP, TRUE);
                nResult = bAdore && (!bMakeLove) && bAtCamp;
            }
            break;

            case ZEVRAN_MAIN_FRIENDLY_AT_CAMP:
            {
                //IF: APP_ZEVRAN_IS_FRIENDLY
                //and IF: the party is in camp

                // Qwinn:  Added condition Romance Not Active.
                int bRomanceActive = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_ROMANCE_ACTIVE);
                int bFriendly = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_IS_FRIENDLY);
                int bAtCamp = WR_GetPlotFlag(PLT_MNP000PT_GENERIC, MAIN_PLOT_GENERIC_PARTY_AT_CAMP);

                nResult = bFriendly && bAtCamp && !bRomanceActive;
            }
            break;

            case ZEVRAN_MAIN_TALKED_ABOUT_CROWS_4_NOT_5:
            {
                //IF: ZEVRAN_TALKED_ABOUT_CROWS4
                //and IF (NOT): ZEVRAN_TALKED_ABOUT_CROWS5
                int bCrows4 = WR_GetPlotFlag(PLT_GENPT_ZEVRAN_MAIN, ZEVRAN_TALKED_ABOUT_CROWS4);
                int bCrows5 = WR_GetPlotFlag(PLT_GENPT_ZEVRAN_MAIN, ZEVRAN_TALKED_ABOUT_CROWS5);
                nResult = bCrows4 && (!bCrows5);
            }
            break;
            case ZEVRAN_MAIN_TALKED_ABOUT_CROWS_4_NOT_5_NOR_6:
            {
                //IF: ZEVRAN_TALKED_ABOUT_CROWS4
                //and IF (NOT): ZEVRAN_TALKED_ABOUT_CROWS5
                int nCrows4 = WR_GetPlotFlag(PLT_GENPT_ZEVRAN_MAIN, ZEVRAN_TALKED_ABOUT_CROWS4);
                int nCrows5 = WR_GetPlotFlag(PLT_GENPT_ZEVRAN_MAIN, ZEVRAN_TALKED_ABOUT_CROWS5);
                int nCrows6 = WR_GetPlotFlag(PLT_GENPT_ZEVRAN_MAIN, ZEVRAN_TALKED_ABOUT_CROWS6);
                if((nCrows4 == TRUE) && (nCrows5 == FALSE) && (nCrows6 == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }

            case ZEVRAN_MAIN_ROMANCE_NOT_ACTIVE_NOT_CUT_OFF:
            {
                //IF (NOT): APP_ZEVRAN_ROMANCE_ACTIVE
                //and IF (NOT): APP_ZEVRAN_ROMANCE_CUT_OFF
                int bActive = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_ROMANCE_ACTIVE, TRUE);
                int bCutOff = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_ROMANCE_CUT_OFF, TRUE);
                nResult = (!bActive) && (!bCutOff);
            }
            break;

            case ZEVRAN_MAIN_CAN_ASK_TO_MAKE_LOVE:
            {
                //IF: APP_ZEVRAN_ROMANCE_ACTIVE
                //and IF: APP_ZEVRAN_IS_CARE
                //and IF: party is in camp
                int bActive = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_ROMANCE_ACTIVE, TRUE);
                int bCare = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_IS_INTERESTED, TRUE);
                int bAtCamp = WR_GetPlotFlag(PLT_MNP000PT_GENERIC, MAIN_PLOT_GENERIC_PARTY_AT_CAMP, TRUE);
                nResult = bActive && bCare && bAtCamp;
            }
            break;

            case ZEVRAN_MAIN_CAN_ASK_ABOUT_LOVE_HISTORY_FEMALE:
            {
                //IF: APP_ZEVRAN_IS_CARE
                //and IF (NOT): APP_ZEVRAN_REFUSES_TO_MAKE_LOVE
                //and IF: PC is female
                int bCare = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_IS_INTERESTED, TRUE);
                int bRefuses = WR_GetPlotFlag(PLT_GENPT_ZEVRAN_MAIN, ZEVRAN_MAIN_REFUSES_TO_MAKE_LOVE, TRUE);
                int bFemale = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_FEMALE);
                nResult = bCare && (!bRefuses) && bFemale;
            }
            break;

            case ZEVRAN_MAIN_CAN_ASK_ABOUT_LOVE_HISTORY_MALE:
            {
                //IF: APP_ZEVRAN_IS_CARE
                //and IF (NOT): APP_ZEVRAN_REFUSES_TO_MAKE_LOVE
                //and IF: PC is male
                int bCare = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_IS_INTERESTED, TRUE);
                int bRefuses = WR_GetPlotFlag(PLT_GENPT_ZEVRAN_MAIN, ZEVRAN_MAIN_REFUSES_TO_MAKE_LOVE, TRUE);
                int bMale = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_MALE);
                nResult = bCare && (!bRefuses) && bMale;
            }
            break;

            case ZEVRAN_MAIN_PC_FEMALE_ROMANCE_NOT_CUT_OFF:
            {
                //IF: PC is female
                //and IF (NOT): APP_ZEVRAN_ROMANCE_CUT_OFF
                int bFemale = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_FEMALE);
                int bCutOff = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_ROMANCE_CUT_OFF, TRUE);
                nResult = bFemale && (!bCutOff);
            }
            break;
        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}

void RAN_SpringAmbush()
{
    // Play Cutscene
    CS_LoadCutscene(CUTSCENE_ZEVRAN_AMBUSH,PLT_GENPT_ZEVRAN_MAIN,ZEVRAN_MAIN_AMBUSH_START);
}

void RAN_SurvivorRunToAmbush()
{
    object      oWP         = GetObjectByTag(RAN_WP_ZEVRAN_AMBUSH);
    command     cMove       = CommandMoveToObject(oWP);
    object      oPC         = GetHero();
    object      oSurvivor   = UT_GetNearestCreatureByTag(oPC, RAN_CR_SURVIVOR);

    //so the PC can't mess with the mage before she gets to Zevran
    SetObjectInteractive(oSurvivor,FALSE);
    UT_SetTeamInteractive(RAN_TEAM_RAN401_ASSASSINS,FALSE);
    WR_AddCommand(oSurvivor, cMove);
}

void RAN_SurvivorAttack()
{
    object      oPC         = GetHero();
    object      oSurvivor           = UT_GetNearestCreatureByTag(oPC, RAN_CR_SURVIVOR);

    RAN_EquipWeapons(oSurvivor);
}

void RAN_EquipWeapons(object oNPC)
{

    object oStaff = GetItemPossessedBy(oNPC, RAN_ZEVRAN_BAIT_WOMAN_WEAPON);
    EquipItem(oNPC, oStaff, INVENTORY_SLOT_MAIN);
}