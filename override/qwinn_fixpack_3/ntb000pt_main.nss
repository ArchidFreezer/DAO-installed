//::///////////////////////////////////////////////
//:: Plot Events
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for the Nature of the Beast
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: Jan 19/2007
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "cutscenes_h"
#include "sys_achievements_h"

#include "plt_ntb000pt_main"
#include "ntb_constants_h"
#include "ntb_functions_h"
#include "plt_ntb000pt_generic"
#include "plt_gen00pt_party"

#include "plt_gen00pt_backgrounds"
#include "plt_gen00pt_random"
#include "plt_ntb100pt_zathrian"
#include "plt_cod_cha_zathrian"
#include "plt_ntb000pt_plot_items"
#include "plt_ntb220pt_danyla"
#include "plt_ntb340pt_lady"
#include "plt_mnp000pt_main_events"
#include "plt_ntb100pt_cammen"
#include "plt_ntb100pt_varathorn"
#include "plt_ntb200pt_deygan"
#include "plt_ntb000pt_clan"
#include "plt_cod_crt_witherfang"
#include "plt_ranpt_generic_actions"
#include "plt_genpt_app_wynne"
#include "plt_genpt_app_alistair"

#include "achievement_core_h"

int StartingConditional()
{
    event eParms = GetCurrentEvent();                // Contains all input parameters
    int nType = GetEventType(eParms);               // GET or SET call
    string strPlot = GetEventString(eParms, 0);         // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);          // The bit flag # being affected
    object oParty = GetEventCreator(eParms);      // The owner of the plot table for this script
    object oConversationOwner = GetEventObject(eParms, 0); // Owner on the conversation, if any
    int nResult = FALSE; // used to return value for DEFINED GET events
    object oPC = GetHero();
    object oLady = UT_GetNearestCreatureByTag(oPC,NTB_CR_LADY);
    object oMithra = UT_GetNearestCreatureByTag(oPC,NTB_CR_MITHRA);
    object oSwiftrunner = UT_GetNearestCreatureByTag(oPC,NTB_CR_SWIFTRUNNER);
    object oZathrian = UT_GetNearestCreatureByTag(oPC,NTB_CR_ZATHRIAN);
    object oWitherfang = UT_GetNearestCreatureByTag(oPC,NTB_CR_WHITE_WOLF);
    object oDoorLady = UT_GetNearestObjectByTag(oPC,NTB_IP_DOOR_LADY);
    object oDoorShortcut = UT_GetNearestObjectByTag(oPC,NTB_IP_DOOR_SHORTCUT);
    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info


    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case NTB_MAIN_MITHRA_BRINGS_PARTY_TO_ZATHRIAN:
            {
                //----------------------------------------------------------------------
                //MITHRA BRINGS THE PARTY TO ZATHRIAN IN THE CAMP
                //----------------------------------------------------------------------
                UT_LocalJump(oPC,NTB_WP_ZATHRIAN_INTERVIEW);
                UT_LocalJump(oMithra,NTB_WP_ZATHRIAN_INTERVIEW);
                UT_Talk(oZathrian,oPC);
                break;
            }
            case NTB_MAIN_MITHRA_REFUSES_CAMP_ENTRY:
            {
                //----------------------------------------------------------------------
                //RETURNS TO WORLD MAP: this will depend on where the PC came from,
                //so needs to be scripted
                //----------------------------------------------------------------------
                LogTrace(LOG_CHANNEL_TEMP, "TRYING TO OPEN WORLD MAP");
                //jump the party away from Mithra
                UT_LocalJump(oPC,NTB_WP_START, TRUE, TRUE, FALSE, TRUE);
                //open the world map
                OpenPrimaryWorldMap();
                break;
            }
            case NTB_MAIN_PC_MET_SWIFTRUNNER:
            {
                break;
            }

            case NTB_MAIN_PC_SIDES_WITH_WEREWOLVES_AGAINST_ELVES:
            {
                //----------------------------------------------------------------------
                //CUTSCENE: Lady, Swiftrunner, werewolves and party stand
                //just outside the elven camp, watching over it.
                //The lady inits dialog "elf05d_lady".
                //CUTSCENE: ntb100cs_attack_on_dalish?
                //----------------------------------------------------------------------
                UT_DoAreaTransition(NTB_AR_DALISH_CAMP,NTB_WP_FROM_FOREST);
                break;
            }
            case NTB_MAIN_WEREWOLVES_PROMISED_ALLIANCE:
            {
                // Grant achievement for siding with werewolves
                WR_UnlockAchievement(ACH_DECISIVE_SLAYER);

                //----------------------------------------------------------------------
                // FAB 7/2: Adding achievement for NotB
                //----------------------------------------------------------------------
                int nCounter;
                if ( WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_COUPLE_IN_LOVE) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB100PT_VARATHORN, NTB_VARATHORN_IRONBARK_PLOT_DONE) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB200PT_DEYGAN, NTB_DEYGAN_PC_RETURNED_BODY) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB200PT_DEYGAN, NTB_DEYGAN_HEALED_BY_PC) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB200PT_DEYGAN, NTB_DEYGAN_RETURNED_ALIVE_WITH_PC) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB220PT_DANYLA, NTB_DANYLA_PC_TOLD_ATHRAS) ) nCounter++;

                if ( nCounter >= 2 ) Acv_Grant(30);
                //----------------------------------------------------------------------
                // End achievement code
                //----------------------------------------------------------------------

                object oTransforming = UT_GetNearestCreatureByTag(oPC,NTB_CR_TRANSFORMING);
                // Qwinn  - changing oWerewolf3 to oWerewolfNurse
                object oWerewolf3 = UT_GetNearestCreatureByTag(oPC,NTB_CR_WEREWOLF_03);
                object oWerewolfNurse = UT_GetNearestCreatureByTag(oPC,"ntb100cr_amb_werenurse");
                //----------------------------------------------------------------------
                //ACTION: fade, and have werewolves take over the camp
                //set that the PC has finished a major plot
                //spawn in werewolves
                //----------------------------------------------------------------------
                if(nOldValue == 0)
                    WR_SetPlotFlag(PLT_MNP000PT_MAIN_EVENTS,PLAYER_FINISHED_A_MAJOR_PLOT,TRUE,TRUE);
                // Qwinn changed to werenurse
                WR_SetObjectActive(oWerewolf3,TRUE);
                SetObjectInteractive(oWerewolf3,FALSE);                
                WR_SetObjectActive(oWerewolfNurse,TRUE);
                SetObjectInteractive(oWerewolfNurse,TRUE);
                WR_SetObjectActive(oTransforming,TRUE);

                //final codex entry for Zathrian
                WR_SetPlotFlag(PLT_COD_CHA_ZATHRIAN, COD_CHA_ZATHRIAN_NATURE_OVER, TRUE);
                WR_SetPlotFlag(PLT_COD_CHA_ZATHRIAN, COD_CHA_ZATHRIAN_WEREWOLF_ENDING, TRUE);

                //activate ambient werewolves
                UT_TeamAppears(NTB_TEAM_CAMP_AMBIENT_WEREWOLF, TRUE);

                //set random encounter dialog variable
                WR_SetPlotFlag(PLT_RANPT_GENERIC_ACTIONS, RAN_ACTIONS_ARMY_WEREWOLVES, TRUE);

                //if cammens' plot started and not finished - shut it down
                if ((WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_TOLD_PC_ABOUT_PELT) == TRUE || WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_PC_AGREED_TO_TALK_TO_GHEYNA) == TRUE) &&
                    WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_RUNS_AWAY) == FALSE &&
                    WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_LEAVES_AFTER_SEPARATED) == FALSE &&
                    WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_COUPLE_SEPARATED) == FALSE &&
                    WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_COUPLE_IN_LOVE) == FALSE &&
                    WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_ANGRY_SHUTDOWN_PLOT) == FALSE)
                {
                    WR_SetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_PLOT_SHUTDOWN, TRUE, TRUE);
                }

                //try an autosave
                DoAutoSave();

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BLIGHT_3b);

                break;
            }
            case NTB_MAIN_ELVES_PROMISED_ALLIANCE:
            {
                // Grant achievement for siding with elves
                WR_UnlockAchievement(ACH_DECISIVE_POACHER);

                //----------------------------------------------------------------------
                // FAB 7/2: Adding achievement for NotB
                //----------------------------------------------------------------------
                int nCounter;
                if ( WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_COUPLE_IN_LOVE) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB100PT_VARATHORN, NTB_VARATHORN_IRONBARK_PLOT_DONE) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB200PT_DEYGAN, NTB_DEYGAN_PC_RETURNED_BODY) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB200PT_DEYGAN, NTB_DEYGAN_HEALED_BY_PC) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB200PT_DEYGAN, NTB_DEYGAN_RETURNED_ALIVE_WITH_PC) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB220PT_DANYLA, NTB_DANYLA_PC_TOLD_ATHRAS) ) nCounter++;

                if ( nCounter >= 2 ) Acv_Grant(30);
                //----------------------------------------------------------------------
                // End achievement code
                //----------------------------------------------------------------------

                //----------------------------------------------------------------------
                //set that the PC has finished a major plot
                //----------------------------------------------------------------------
                if(nOldValue == 0)
                WR_SetPlotFlag(PLT_MNP000PT_MAIN_EVENTS,PLAYER_FINISHED_A_MAJOR_PLOT,TRUE,TRUE);

                //final codex entry for Zathrian
                WR_SetPlotFlag(PLT_COD_CHA_ZATHRIAN, COD_CHA_ZATHRIAN_NATURE_OVER, TRUE);
                if (WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_ZATHRIAN_SACRIFICES_HIMSELF) == TRUE)
                {
                    WR_SetPlotFlag(PLT_COD_CHA_ZATHRIAN, COD_CHA_ZATHRIAN_GOOD_ENDING, TRUE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_COD_CHA_ZATHRIAN, COD_CHA_ZATHRIAN_ELF_ENDING, TRUE);
                }

                //set random encounter dialog variable
                WR_SetPlotFlag(PLT_RANPT_GENERIC_ACTIONS, RAN_ACTIONS_ARMY_ELVES, TRUE);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BLIGHT_3a);

                //if cammens' plot started and not finished - shut it down
                if ((WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_TOLD_PC_ABOUT_PELT) == TRUE || WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_PC_AGREED_TO_TALK_TO_GHEYNA) == TRUE) &&
                    WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_RUNS_AWAY) == FALSE &&
                    WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_LEAVES_AFTER_SEPARATED) == FALSE &&
                    WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_COUPLE_SEPARATED) == FALSE &&
                    WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_COUPLE_IN_LOVE) == FALSE &&
                    WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_ANGRY_SHUTDOWN_PLOT) == FALSE)
                {
                    WR_SetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_PLOT_SHUTDOWN, TRUE, TRUE);
                }

                //try an autosave
                DoAutoSave();

                break;
            }
            case NTB_MAIN_HUMANS_ESCAPE:
            {
                //----------------------------------------------------------------------
                //swiftrunner: ACTION: werewolves/humans turn hostile and escape.
                //Player can cut them down while they try.
                //----------------------------------------------------------------------
                UT_TeamGoesHostile(NTB_TEAM_WEREWOLF_LAIR_HUMAN);
                SetPlaceableState(oDoorShortcut,PLC_STATE_DOOR_OPEN);
                UT_TeamExit(NTB_TEAM_WEREWOLF_LAIR_HUMAN, TRUE, NTB_WP_FROM_TOP_SHORTCUT);
                break;
            }
            case NTB_MAIN_ZATHRIAN_PLANS_TO_ATTACK_WEREWOLVES:
            {
                //----------------------------------------------------------------------
                //ACTION: Jump party and Zathrian to lady. Zathrian inits dialog.
                //ZATHRIAN_AND_PC_JUMP_TO_LADY
                //----------------------------------------------------------------------
                WR_SetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ZATHRIAN_AND_PC_JUMP_TO_LADY,TRUE,TRUE);
                break;
            }
            case NTB_MAIN_ZATHRIAN_PLANS_TO_TALK_TO_WEREWOLVES:
            {
                //----------------------------------------------------------------------
                //ACTION: Jump party and Zathrian to lady. Zathrian inits dialog.
                //ZATHRIAN_AND_PC_JUMP_TO_LADY
                //----------------------------------------------------------------------
                WR_SetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ZATHRIAN_AND_PC_JUMP_TO_LADY,TRUE,TRUE);
                break;
            }
            case NTB_MAIN_ATTACK_LADY_OF_FOREST:
            {
                //----------------------------------------------------------------------
                //CUTSCENE: Lady changes into Witherfang and all werewolves attack.
                //ACTION:
                //-Set Zathrian to init dialog when the lady dies (flag EVENT_ZATHRIAN_HELPED_KILLING_WITHERFANG)
                //- Witherfang and werewolves turn hostile and attack
                //doors around lock
                //- Zathrian helps fight the werewolves
                //- Zathrian can not die in this fight.
                //If he is defeated he falls unconcious like a normal party member,
                //and stands up again when the fight is over.
                //----------------------------------------------------------------------

                object oLadyPin = UT_GetNearestObjectByTag(oPC, NTB_WP_LADY_MAPNOTE);
                //Add codex entry
                WR_SetPlotFlag(PLT_COD_CRT_WITHERFANG, COD_CRT_WITHERFANG_LADY, TRUE, TRUE);

                SetPlaceableState(oDoorLady,PLC_STATE_DOOR_LOCKED);
                SetPlaceableState(oDoorShortcut,PLC_STATE_DOOR_LOCKED);

                WR_SetObjectActive(oLady,FALSE);
                WR_SetObjectActive(oWitherfang,TRUE);

                //Make sure the escort guards are no longer hanging out back in the last room

                UT_TeamAppears(NTB_TEAM_GATEKEEPER_GUARDS, TRUE);
                // Qwinn:  The following line was commented out, which made it that if you killed
                // Witherfang and then Zathrian, Gatekeeper would attack but these would just stand there
                UT_TeamGoesHostile(NTB_TEAM_GATEKEEPER_GUARDS, TRUE);

                //Set Zathrian as friendly
                SetGroupHostility(GetGroupId(oZathrian), GetGroupId(oWitherfang), TRUE);

                //Zathrian can't die
                SetImmortal(oZathrian,TRUE);

                //Swiftrunner can die
                SetImmortal(oSwiftrunner, FALSE);

                UT_TeamAppears(NTB_TEAM_WEREWOLF_LAIR_LADY,TRUE,OBJECT_TYPE_PLACEABLE);

                //get the werewolves back in the wings active
                UT_TeamAppears(NTB_TEAM_WEREWOLF_LAIR_GATEKEEPER, TRUE);
                UT_TeamGoesHostile(NTB_TEAM_WEREWOLF_LAIR_GATEKEEPER, TRUE);

                //Start the fight
                UT_TeamGoesHostile(NTB_TEAM_WEREWOLF_LAIR_LADY);

                SetMapPinState(oLadyPin,FALSE);

                //Wynne disapproves
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_PARTY) == TRUE)
                {
                    WR_SetPlotFlag(PLT_GENPT_APP_WYNNE, APP_WYNNE_DEC_HIGH, TRUE);

                }
                //Alistair disapproves
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY) == TRUE)
                {
                    WR_SetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_DEC_HIGH, TRUE);

                }
                //try adding an autosave here
                DoAutoSave();

                break;
            }
            case NTB_MAIN_ATTACK_ZATHRIAN_AT_ALTAR:
            {
                //----------------------------------------------------------------------
                //- Zathrian turns hostile
                //Zathrian summons shades to help his fight
                // Zathrain will paralyze the werewolves
                //- The Lady help party fight Zathrian.
                //- Zathrian get ents in the room to help him in the fight
                //- Set Zathrian to init surrender dialog when defeated (EVENT_ZATHRIAN_SURRENDER).
                //Note that Zathrian should not init his surrender dialog when fought outside.
                //lock all the doors around the room
                //the Lady turns to witherfang
                //Witherfang and swiftrunner can't be killed
                //----------------------------------------------------------------------
                object oLadyPin = UT_GetNearestObjectByTag(oPC, NTB_WP_LADY_MAPNOTE);

                //Add codex entry
                WR_SetPlotFlag(PLT_COD_CRT_WITHERFANG, COD_CRT_WITHERFANG_LADY, TRUE);

                SetPlaceableState(oDoorLady,PLC_STATE_DOOR_LOCKED);
                SetPlaceableState(oDoorShortcut,PLC_STATE_DOOR_LOCKED);

                WR_SetObjectActive(oLady,FALSE);
                WR_SetObjectActive(oWitherfang,TRUE);

                SetImmortal(oWitherfang,TRUE);
                SetImmortal(oSwiftrunner,TRUE);

                UT_SetSurrenderFlag(oZathrian,TRUE,PLT_NTB000PT_MAIN,NTB_MAIN_ZATHRIAN_SURRENDERS);
                UT_CombatStart(oZathrian,oPC);
                UT_CombatStart(oZathrian,oWitherfang);
                UT_CombatStart(oZathrian,oSwiftrunner);

                UT_SetTeamInteractive(NTB_TEAM_WEREWOLF_LAIR_GOLEM,TRUE);
                UT_TeamGoesHostile(NTB_TEAM_WEREWOLF_LAIR_GOLEM);

                UT_TeamAppears(NTB_TEAM_WEREWOLF_LAIR_SHADES);

                //paralyze the werewolves
                object [] arTeam = UT_GetTeam(NTB_TEAM_WEREWOLF_LAIR_LADY);
                effect eEffect = EffectParalyze(Ability_GetImpactObjectVfxId(ABILITY_SPELL_PARALYZE));
                int nIndex = 0;
                while (IsObjectValid(arTeam[nIndex]) == TRUE)
                {

                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, arTeam[nIndex], 0.0, oZathrian, ABILITY_SPELL_PARALYZE);
                    nIndex = nIndex + 1;

                }

                SetMapPinState(oLadyPin,FALSE);

                //try adding an autosave here
                DoAutoSave();

                break;
            }
            case NTB_MAIN_PC_ATTACKS_ZATHRIAN_AT_ALTAR_AFTER_WITHERFANG:
            {
                //----------------------------------------------------------------------
                //- Zathrian goes hostile
                //Zathrian summons shades to help his fight
                //the ents in the room join Zathrian's side
                //----------------------------------------------------------------------
                if(IsImmortal(oZathrian))
                {
                    SetImmortal(oZathrian,FALSE);
                }
                UT_SetTeamInteractive(NTB_TEAM_WEREWOLF_LAIR_GOLEM,TRUE);
                UT_TeamGoesHostile(NTB_TEAM_WEREWOLF_LAIR_GOLEM);
                UT_TeamAppears(NTB_TEAM_WEREWOLF_LAIR_SHADES);

                UT_CombatStart(oZathrian,oPC);

                //try adding an autosave here
                DoAutoSave();

                break;
            }
            case NTB_MAIN_ZATHRIAN_SACRIFICES_HIMSELF:
            {
                object oSwiftrunnerHuman = UT_GetNearestCreatureByTag(oPC,NTB_CR_SWIFTRUNNER_HUMAN);
                //----------------------------------------------------------------------
                //CUTSCENE: Zathrian sacrifices himself, lady dies as well
                //BLANK CUTSCENE: ntb340cs_lady_plea
                //and werewolves are all transformed back into humans or disappear.
                //ACTION: human swiftrunner will init dialog.
                //----------------------------------------------------------------------
                //Fire the cutscene
                WR_SetObjectActive(oSwiftrunnerHuman, TRUE);
                CS_LoadCutscene(CUTSCENE_NTB_LADY_PLEA, PLT_NTB000PT_GENERIC, NTB_GENERIC_ZATHRIAN_SACRIFICE, NTB_CR_SWIFTRUNNER_HUMAN);

                SetImmortal(oWitherfang,FALSE);
                SetImmortal(oSwiftrunner,FALSE);

                //outer guards should go away
                UT_TeamAppears(NTB_TEAM_GATEKEEPER_GUARDS, FALSE);
                UT_TeamAppears(NTB_TEAM_WEREWOLF_LAIR_GATEKEEPER, FALSE);


                UT_TeamAppears(NTB_TEAM_WEREWOLF_LAIR_HUMAN,TRUE);

                Log_Trace(LOG_CHANNEL_PLOT,"ntb000pt_main.nss","Swiftrunner should init here");
                //UT_Talk(oSwiftrunnerHuman,oPC);
                break;
            }
            case NTB_MAIN_PC_ATTACKS_ELVES_AT_VILLAGE_WITH_WEREWOLVES:
            {
                object oAthras = UT_GetNearestCreatureByTag(oPC,NTB_CR_ATHRAS);
                object oCammen = UT_GetNearestCreatureByTag(oPC,NTB_CR_CAMMEN);
                object oDeygan = UT_GetNearestCreatureByTag(oPC,NTB_CR_DEYGAN);
                object oGheyna = UT_GetNearestCreatureByTag(oPC,NTB_CR_GHEYNA);
                object oVarathorn = UT_GetNearestCreatureByTag(oPC,NTB_CR_VARATHORN);
                object oApprentice = UT_GetNearestCreatureByTag(oPC,NTB_CR_APPRENTICE);
                object oElora = UT_GetNearestCreatureByTag(oPC,NTB_CR_ELORA);
                object oSarel = UT_GetNearestCreatureByTag(oPC,NTB_CR_SAREL);
                //----------------------------------------------------------------------
                //CUTSCENE: Lady turns into Witherfang
                //- Witherfang and werewolves attack the elves
                //- Zathrian and the elves turn hostile
                //set it so you can't choose your party during the fight
                //checks to see if particular combatants have already been deactivated
                //and destroy them
                //sets noncombatants inactive
                //sets combatants to move towards the middle of the camp
                //----------------------------------------------------------------------

                //Add codex entry
                WR_SetPlotFlag(PLT_COD_CRT_WITHERFANG, COD_CRT_WITHERFANG_LADY, TRUE);

                SetPartyPickerGUIStatus(PP_GUI_STATUS_NO_USE);

                NTB_CheckElfCombatants(oAthras);
                NTB_CheckElfCombatants(oCammen);
                NTB_CheckElfCombatants(oDeygan);
                NTB_CheckElfCombatants(oGheyna);
                NTB_CheckElfCombatants(oMithra);

                NTB_CheckElfCombatants(oVarathorn);
                NTB_CheckElfCombatants(oApprentice);
                NTB_CheckElfCombatants(oElora);
                NTB_CheckElfCombatants(oSarel);

                WR_SetObjectActive(oLady,FALSE);
                WR_SetObjectActive(oWitherfang,TRUE);

                SetImmortal(oWitherfang,TRUE);
                SetImmortal(oSwiftrunner,TRUE);

                UT_TeamGoesHostile(NTB_TEAM_CAMP_ZATHRIAN, TRUE);
                SetGroupHostility( NTB_GROUP_ZATHRAIN,  NTB_GROUP_SWIFTRUNNER, TRUE);
                SetGroupHostility( NTB_GROUP_HOSTILE,  NTB_GROUP_SWIFTRUNNER, TRUE);
                SetGroupHostility( NTB_GROUP_HOSTILE,  NTB_GROUP_WITHERFANG, TRUE);
                UT_CombatStart(oWitherfang,oZathrian);
                //UT_CombatStart(oSwiftrunner,oZathrian);

                UT_TeamMove(NTB_TEAM_CAMP_ZATHRIAN,NTB_WP_ELF_RALLY,TRUE);

                //try adding an autosave here
                DoAutoSave();

                break;
            }
            case NTB_MAIN_ZATHRIAN_AND_PC_JUMP_TO_LADY:
            {
                //----------------------------------------------------------------------
                //transitions Zathrian and PC to lady
                //----------------------------------------------------------------------
                WR_SetObjectActive(oZathrian,FALSE);
                WR_SetPlotFlag(PLT_NTB340PT_LADY,NTB_LADY_PC_BRINGS_ZATHRIAN,TRUE,TRUE);
                UT_DoAreaTransition(NTB_AR_LAIR_OF_WEREWOLVES,NTB_WP_PC_ALTAR);
                break;
            }
            case NTB_MAIN_ELVES_CURED:
            {
                object oHeart = GetItemPossessedBy(oPC,NTB_IM_WITHERFANG_HEART);
                //----------------------------------------------------------------------
                //if the PC has witherfang's heart in their inventory
                //destroy it
                //----------------------------------------------------------------------
                if(IsObjectValid(oHeart))
                {
                    WR_DestroyObject(oHeart);
                }
                break;
            }
            case NTB_MAIN_ZATHRIAN_SURRENDERS:
            {
                //unparalyze werewolves
                object [] arTeam = UT_GetTeam(NTB_TEAM_WEREWOLF_LAIR_LADY);
                effect eEffect;
                int nIndex = 0;
                while (IsObjectValid(arTeam[nIndex]) == TRUE)
                {
                    RemoveEffectsByParameters(arTeam[nIndex]);
                    nIndex = nIndex + 1;
                }

                break;
            }
            case NTB_MAIN_PC_TOLD_TO_FIND_HEART:
            {
                // Qwinn changed for Lanaya Chest
                // UT_QuickMoveObject(oZathrian, NTB_WP_ZATHRIAN_POST);
                UT_QuickMoveObject(oZathrian, NTB_WP_WOUNDED_TENTS);
                break;
            }

            // Qwinn added to destroy werewolf plot item if Hermit didn't use it
            case NTB_MAIN_PC_PASSED_INTO_HEART_OF_FOREST:
            {
                object oPelt = GetItemPossessedBy(oPC,"gen_im_pelt_ww_plot");
                if(IsObjectValid(oPelt))
                {
                    WR_DestroyObject(oPelt);
                    UT_AddItemToInventory(R"gen_im_pelt_werewolf.uti",1,OBJECT_INVALID,"gen_im_pelt_werewolf",TRUE);
                }
                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        switch(nFlag)
        {
            case NTB_MAIN_PC_TOLD_TO_FIND_HEART_AND_NOT_DALISH:
            {
                int nDalish = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS,GEN_BACK_ELF_DALISH,TRUE);
                int nHeart = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_PC_TOLD_TO_FIND_HEART,TRUE);
                //----------------------------------------------------------------------
                //if the PC is not dalish
                //and asked to get Witherfang's heart
                //----------------------------------------------------------------------
                if((nDalish == FALSE) && (nHeart == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_MAIN_PC_TOLD_TO_FIND_HEART_AND_DALISH:
            {
                int nDalish = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS,GEN_BACK_ELF_DALISH,TRUE);
                int nHeart = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_PC_TOLD_TO_FIND_HEART,TRUE);
                //----------------------------------------------------------------------
                //if the PC is dalish
                //and asked to get Witherfang's heart
                //----------------------------------------------------------------------
                if((nDalish == TRUE) && (nHeart == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_MAIN_PC_DEMANDED_REWARD_OR_OATH:
            {
                int nReward = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_PC_DEMANDED_REWARD);
                int nOath = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_PC_DEMANDED_OATH);
                //----------------------------------------------------------------------
                //APPEARS WHEN: EVENT_PC_DEMANDED_REWARD (Main) *or*
                //APPEARS WHEN: EVENT_PC_DEMANDED_OATH (Main)
                //----------------------------------------------------------------------
                if((nReward == TRUE) || (nOath == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_MAIN_PC_EXPLORED_FOREST_BUT_NOT_RUINS:
            {
                int nForest = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_PC_EXPLORED_FOREST);
                int nRuins = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_PC_EXPLORED_RUINS);

                //----------------------------------------------------------------------
                //if the PC has explored the forest but not the ruins
                //----------------------------------------------------------------------
                if((nForest == TRUE) && (nRuins == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_MAIN_ELVES_PROMISED_ALLIANCE_ZATHRIAN_SACRIFICED_RANDOM:
            {
               int nAlliance = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ELVES_PROMISED_ALLIANCE,TRUE);
               int nSacrificed = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ZATHRIAN_SACRIFICES_HIMSELF,TRUE);
               int nRandom = WR_GetPlotFlag(PLT_GEN00PT_RANDOM,GEN_R50,TRUE);
               //----------------------------------------------------------------------
               //EVENT_ELVES_PROMISED_ALLIANCE (Main) *AND*
               //EVENT_ZATHRIAN_SACRIFICE_HIMSELF (Main)
               //*AND* 50%
               //----------------------------------------------------------------------
               if((nAlliance == TRUE) && (nSacrificed == TRUE) && (nRandom == TRUE))
               {
                    nResult = TRUE;
               }
               break;
            }
            case NTB_MAIN_ELVES_PROMISED_ALLIANCE_AND_RANDOM:
            {
               int nAlliance = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ELVES_PROMISED_ALLIANCE,TRUE);
               int nRandom = WR_GetPlotFlag(PLT_GEN00PT_RANDOM,GEN_R50,TRUE);
                //----------------------------------------------------------------------
                //APPEARS WHEN: EVENT_ELVES_PROMISED_ALLIANCE (Main) and 50%
                //----------------------------------------------------------------------
               if((nAlliance == TRUE) && (nRandom == TRUE))
               {
                    nResult = TRUE;
               }
               break;
            }
            case NTB_MAIN_ZATHRIAN_SACRIFICED_HIMSELF_OR_KILLED_BY_PC:
            {
               int nKilled = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ZATHRIAN_KILLED_BY_PC,TRUE);
               int nSacrificed = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ZATHRIAN_SACRIFICES_HIMSELF,TRUE);
                //----------------------------------------------------------------------
                //if the PC killed Zathrian
                //or Zathrian sacrificed himself
                //----------------------------------------------------------------------
               if((nKilled == TRUE) || (nSacrificed == TRUE))
               {
                    nResult = TRUE;
               }
                break;
            }
            case NTB_MAIN_PLOT_COMPLETED:
            {
                int nCure = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ELVES_CURED,TRUE);
                int nDefeat = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ELVES_DEFEATED,TRUE);
                //----------------------------------------------------------------------
                //if the elves' cure was enacted
                //or the elves were defeated
                //----------------------------------------------------------------------
                if((nCure == TRUE)
                    || (nDefeat == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_MAIN_CLAN_ATTITUDE_HIGH_AND_REWARD_NOT_GIVEN:
            {
               int nAttitude = WR_GetPlotFlag(PLT_NTB000PT_CLAN,NTB_CLAN_ATTITUDE_HIGH,TRUE);
               int nReward = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ZATHRIAN_GIVES_PROMISED_REWARD,TRUE);
                //----------------------------------------------------------------------
                //if clan attitude is high towards the PC
                // and Zathrian hasn't given them a reward
                //----------------------------------------------------------------------
               if((nAttitude == TRUE) && (nReward == FALSE))
               {
                    nResult = TRUE;
               }
               break;
            }
            case NTB_MAIN_PC_DEMANDED_REWARD_AND_NOT_GIVEN:
            {
               int nDemand = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_PC_DEMANDED_REWARD,TRUE);
               int nReward = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ZATHRIAN_GIVES_PROMISED_REWARD,TRUE);
                //----------------------------------------------------------------------
                //if the PC demanded a reward
                //and hasn't been given it yet
                //----------------------------------------------------------------------
               if((nDemand == TRUE) && (nReward == FALSE))
               {
                    nResult = TRUE;
               }
               break;
            }
            case NTB_MAIN_COMPLETE_AND_ALLIANCE_PROMISED:
            {
               int nElfAlliance = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ELVES_PROMISED_ALLIANCE,TRUE);
               int nWerewolfAlliance = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_WEREWOLVES_PROMISED_ALLIANCE,TRUE);
               if((nElfAlliance == TRUE) || (nWerewolfAlliance == TRUE))
               {
                   nResult = TRUE;
               }
               break;

            }
            case NTB_MAIN_RANDOM_ENCOUNTER_CAN_OCCUR:
            {
                int bElvesCured         =   WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_ELVES_CURED);
                int bWerewolfAlliance   =   WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_WEREWOLVES_PROMISED_ALLIANCE);
                int bNTBComplete        =   WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_PLOT_COMPLETED);
                //--------------------------------------------------------------
                //IF the elves were cured
                //OR the player made an alliance with the werewolves
                //AND the NTB plot is complete.
                //--------------------------------------------------------------
                if( !(bElvesCured || bWerewolfAlliance) && bNTBComplete )
                {
                    nResult = TRUE;
                }

                break;
            }
        }
    }

    return nResult;
}