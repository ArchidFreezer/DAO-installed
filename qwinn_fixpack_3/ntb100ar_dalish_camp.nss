//::///////////////////////////////////////////////
//:: Area Core
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Handles global area events for the Dalish camp
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: Feb 7/07
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"
#include "cutscenes_h"
#include "party_h"

#include "plt_gen00pt_stealing"

#include "ntb_functions_h"
#include "plt_ntb000pt_plot_items"
#include "plt_ntb340pt_lady"
#include "plt_ntb000pt_main"
#include "ntb_constants_h"
#include "plt_ntb200pt_swiftrunner"
#include "plt_ntb200pt_deygan"
#include "plt_ntb000pt_talked_to"
#include "plt_lite_mabari_dom"
#include "plt_gen00pt_party"
#include "plt_ntb100pt_cammen"

// Added by Qwinn
vector QwConvToVector(float x, float y, float z)
{ return Vector(x,y,z);     }


void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    object oLady = UT_GetNearestCreatureByTag(oPC,NTB_CR_LADY);
    object oWitherfang = UT_GetNearestCreatureByTag(oPC,NTB_CR_WHITE_WOLF);
    object oSwiftrunner = UT_GetNearestCreatureByTag(oPC,NTB_CR_SWIFTRUNNER);
    object oMithra = UT_GetNearestCreatureByTag(oPC,NTB_CR_MITHRA);
    object oZathrian = UT_GetNearestCreatureByTag(oPC,NTB_CR_ZATHRIAN);

    switch(nEventType)
    {
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            int nDeyganReturned = WR_GetPlotFlag(PLT_NTB200PT_DEYGAN,NTB_DEYGAN_RETURNED_ALIVE_WITH_PC);
            int nHealed = WR_GetPlotFlag(PLT_NTB200PT_DEYGAN,NTB_DEYGAN_HEALED_BY_PC);
            int nWolves = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_PC_SIDES_WITH_WEREWOLVES_AGAINST_ELVES);
            int nAttack = WR_GetPlotFlag(PLT_NTB340PT_LADY,NTB_LADY_PREPARE_TO_ATTACK_ELVES_WITH_WEREWOLVES);
            int nSacrifice = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ZATHRIAN_SACRIFICES_HIMSELF);
            int nAlliance = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ELVES_PROMISED_ALLIANCE);
            int nCure = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ELVES_CURED);
            int nMessenger = WR_GetPlotFlag(PLT_NTB000PT_TALKED_TO,NTB_TALKED_TO_MESSENGER);
            int nAreaOnce = GetLocalInt(OBJECT_SELF,AREA_DO_ONCE_A);
            int nPromise = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ELVES_PROMISED_ALLIANCE);
            int nZathrianDead = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ZATHRIAN_KILLED_BY_PC);
            int nSwiftrunner = WR_GetPlotFlag(PLT_NTB200PT_SWIFTRUNNER,NTB_SWIFTRUNNER_WEREWOLVES_LEAVE);
            int nDeyganDone = WR_GetPlotFlag(PLT_NTB200PT_DEYGAN, NTB_DEYGAN_LEAVES);

            object oWolf1 = UT_GetNearestCreatureByTag(oPC,NTB_CR_WEREWOLF_01);
            object oWolf2 = UT_GetNearestCreatureByTag(oPC,NTB_CR_WEREWOLF_02);
            object oWolf4 = UT_GetNearestCreatureByTag(oPC,NTB_CR_WEREWOLF_04);

            object oCammen = UT_GetNearestCreatureByTag(oPC,NTB_CR_CAMMEN);
            object oRecovering = UT_GetNearestCreatureByTag(oPC,NTB_CR_RECOVERING);
            object oRefugee = UT_GetNearestCreatureByTag(oPC,NTB_CR_REFUGEE);
            object oReturning = UT_GetNearestCreatureByTag(oPC,NTB_CR_RETURNING);
            object oMessenger = UT_GetNearestCreatureByTag(oPC,NTB_CR_MESSENGER);
            object oDeygan = UT_GetNearestCreatureByTag(oPC,NTB_CR_DEYGAN);
            object oStoreMapNote = UT_GetNearestObjectByTag(oPC, NTB_WP_VARATHORN_STORE);
            object oLanaya = UT_GetNearestCreatureByTag(oPC, NTB_CR_LANAYA);
            object oAthras = UT_GetNearestCreatureByTag(oPC, NTB_CR_ATHRAS);
            object oElora = UT_GetNearestCreatureByTag(oPC, NTB_CR_ELORA);
            object oVarathorn = UT_GetNearestCreatureByTag(oPC, NTB_CR_VARATHORN);
            object oSarel = UT_GetNearestCreatureByTag(oPC, NTB_CR_SAREL);
            object oGheyna = UT_GetNearestCreatureByTag(oPC, NTB_CR_GHEYNA);
            // Qwinn added
            object oElfNurse = UT_GetNearestCreatureByTag(oPC, NTB_CR_ELF_NURSE);

            // activate world map location
            object oLocation = GetObjectByTag("wml_wow_dalish_camp");
            WR_SetWorldMapLocationStatus(oLocation, WM_LOCATION_GRAYED_OUT);

            //if their plot is shutdown, make sure no plotgiver status for cammen or Gheyna
            if (WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_PLOT_SHUTDOWN) == TRUE)
            {
                SetPlotGiver(oCammen, FALSE);
                SetPlotGiver(oGheyna, FALSE);
            }

            // -----------------------------------------------------
            // if the PC has healed deygan and he hasn't been activated yet and hasn't already rewarded the PC
            // deygan is activated and given a new team
            // -----------------------------------------------------
            if((nHealed == TRUE || nDeyganReturned == TRUE) && nDeyganDone == FALSE)
            {
                WR_SetObjectActive(oDeygan,TRUE);
            }
            // -----------------------------------------------------
            // if Zathrian sacrificed himself
            // -----------------------------------------------------
            if(nSacrifice == TRUE)
            {
                // -----------------------------------------------------
                // if Zathrian is still active,
                // deactivate him
                // -----------------------------------------------------
                if(GetObjectActive(oZathrian) == TRUE)
                {
                    WR_SetObjectActive(oZathrian,FALSE);
                }
                // -----------------------------------------------------
                // if the werewolves haven't been removed yet
                // remove them
                // -----------------------------------------------------
                if(nAreaOnce == FALSE)
                {
                    SetLocalInt(OBJECT_SELF,AREA_DO_ONCE_A,TRUE);
                    NTB_RemoveCuredWerewolves(oPC);
                }
                //--------------------------------------------
                //First time back in camp after sacrifice - force conversation with Lanaya
                //   : The Alliance variable is set in Lanaya's dialog
                //--------------------------------------------
                if (nAlliance == FALSE)
                {
                    //Jump the PC and party near Lanaya
                    UT_LocalJump(oPC, NTB_WP_PC_LANAYA, TRUE, TRUE, FALSE, TRUE);
                    //Speak with Lanaya
                    UT_Talk(oLanaya, oPC);
                }

            }
            // -----------------------------------------------------
            // if Zathrian was killed by the pc
            // -----------------------------------------------------
            if(nZathrianDead == TRUE)
            {
                // -----------------------------------------------------
                // and his creature is still active
                // deactivate it
                // -----------------------------------------------------
                if(GetObjectActive(oZathrian) == TRUE)
                {
                    WR_SetObjectActive(oZathrian,FALSE);
                }
                // -----------------------------------------------------
                // if Swiftrunner has left after the sacrifice or the PC killed Zathrian after the lady
                // and the elves haven't promised alliance yet
                // Lanaya initiates
                // -----------------------------------------------------
                if((nSwiftrunner == TRUE || nZathrianDead == TRUE ) && (nPromise == FALSE))
                {
                    UT_Talk(oLanaya,oPC);
                }
            }
            // -----------------------------------------------------
            // if the elves have been cured
            // -----------------------------------------------------
            if((nCure == TRUE))
            {
                // -----------------------------------------------------
                // and cammen is still around
                // deactivate him
                // -----------------------------------------------------
                if(GetObjectActive(oCammen) == TRUE)
                {
                    WR_SetObjectActive(oCammen,FALSE);
                }
                // -----------------------------------------------------
                // and the recovering elf hasn't been activated yet
                // activate him
                // -----------------------------------------------------
                if(GetObjectActive(oRecovering) == FALSE)
                {

                    WR_SetObjectActive(oRecovering,TRUE);
                    // Qwinn:  Move the Recovering elf to the nearby cot, since he's on the ground
                    SetPosition(oRecovering,QwConvToVector(289.309f,230.822f,6.98693f),FALSE);
                    WR_AddCommand(oRecovering,CommandTurn(20.0));
                    // Qwinn added:  Move the nurse to the recovering elf, since
                    // they have ambient lines.
                    SetPosition(oElfNurse,QwConvToVector(289.0090f,229.722f,6.98693f),FALSE);                    
                    WR_AddCommand(oElfNurse,CommandTurn(200.0));
                }


                // -----------------------------------------------------
                // and the messenger hasn't been activated yet or left
                // activate him
                // -----------------------------------------------------
                if((GetObjectActive(oMessenger) == FALSE) && (nMessenger == FALSE))
                {
                    WR_SetObjectActive(oMessenger,TRUE);
                }
                // -----------------------------------------------------
                // and the refugee hasn't been activated yet
                // activate him
                // -----------------------------------------------------
                if(GetObjectActive(oRefugee) == FALSE)
                {
                    WR_SetObjectActive(oRefugee,TRUE);
                }
                // -----------------------------------------------------
                // and the returning elf hasn't been activated yet
                // activate him
                // -----------------------------------------------------
                if(GetObjectActive(oReturning) == FALSE)
                {
                    WR_SetObjectActive(oReturning,TRUE);
                }
            }

            int nAreaFirst = GetLocalInt(OBJECT_SELF,ENTERED_FOR_THE_FIRST_TIME);

            // -----------------------------------------------------
            // if you haven't been here before, force the talk with Mithra
            // -----------------------------------------------------
            if(nAreaFirst == FALSE)
            {
                SetLocalInt(OBJECT_SELF,ENTERED_FOR_THE_FIRST_TIME,TRUE);
                //set some gore on the sick elves
                object oSickElf1 = UT_GetNearestCreatureByTag(oPC, NTB_CR_CAMP_SICK_ELF_1);
                object oSickElf2 = UT_GetNearestCreatureByTag(oPC, NTB_CR_CAMP_SICK_ELF_2);
                object oSickElf3 = UT_GetNearestCreatureByTag(oPC, NTB_CR_CAMP_SICK_ELF_3);
                object oSickElf4 = UT_GetNearestCreatureByTag(oPC, NTB_CR_CAMP_SICK_ELF_4);
                object oSickElf5 = UT_GetNearestCreatureByTag(oPC, NTB_CR_CAMP_SICK_ELF_5);
                object oSickElf6 = UT_GetNearestCreatureByTag(oPC, NTB_CR_CAMP_SICK_ELF_6);
                object oSickElf7 = UT_GetNearestCreatureByTag(oPC, NTB_CR_CAMP_SICK_ELF_7);

                SetCreatureGoreLevel(oSickElf1, 0.5);
                SetCreatureGoreLevel(oSickElf2, 0.5);
                SetCreatureGoreLevel(oSickElf3, 0.5);
                SetCreatureGoreLevel(oSickElf4, 0.5);
                SetCreatureGoreLevel(oSickElf5, 0.5);
                SetCreatureGoreLevel(oSickElf6, 0.5);
                SetCreatureGoreLevel(oSickElf7, 0.5);

                UT_Talk(oMithra,oPC);
            }


            // -----------------------------------------------------
            // if the PC has sided with the wolves against the elves
            // and hasn't yet attacked the village yet
            // set all the wolf team active
            // and get rid of the non-combatants
            // -----------------------------------------------------
            if(nWolves == TRUE && nAttack == FALSE)
            {
                WR_SetObjectActive(oLady,TRUE);
                WR_SetObjectActive(oWolf1,TRUE);
                WR_SetObjectActive(oWolf2,TRUE);
                WR_SetObjectActive(oWolf4,TRUE);
                WR_SetObjectActive(oSwiftrunner,TRUE);
                UT_TeamAppears(NTB_TEAM_CAMP_NON_COMBATANTS,FALSE);
                //turn off plot giver icons on remaining elves
                SetPlotGiver(oCammen, FALSE);
                SetPlotGiver(oDeygan, FALSE);
                SetPlotGiver(oAthras, FALSE);
                SetPlotGiver(oElora, FALSE);
                SetPlotGiver(oVarathorn, FALSE);
                //re-enabel physics for Sarel and Gheyna so they can fight
                SetPhysicsController(oSarel, TRUE);
                SetPhysicsController(oGheyna, TRUE);
                // Qwinn:  Do the same for the two Sarel hunters
                object oSarelHunter = UT_GetNearestCreatureByTag(oPC,"ntb100cr_elf_male_sarel");
                SetPhysicsController(oSarelHunter, TRUE);
                oSarelHunter = UT_GetNearestCreatureByTag(oPC,"ntb100cr_elf_female_sarel");
                SetPhysicsController(oSarelHunter, TRUE);

                //Deactivate the story waypoint
                SetMapPinState(oStoreMapNote, FALSE);

                //set the new music
                SetMusicVolumeStateByTag("save_elves", 2);

                //we should make Lanaya's chest interactive FALSE now
                object oLanayaChest = UT_GetNearestObjectByTag(oPC, NTB_IP_LANAYA_CHEST);
                SetObjectInteractive(oLanayaChest, FALSE);
                //make sure the lady and swiftrunner are active
                WR_SetObjectActive(oLady, TRUE);
                WR_SetObjectActive(oSwiftrunner, TRUE);
                CS_LoadCutscene(CUTSCENE_NTB_ATTACK_ON_DALISH,PLT_NTB340PT_LADY,
                    NTB_LADY_PREPARE_TO_ATTACK_ELVES_WITH_WEREWOLVES, NTB_CR_ZATHRIAN);

            }

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: all game objects in the area have loaded
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {
            Log_Systems("*** AREA FINISHED LOADING", LOG_LEVEL_WARNING);

            int nWolves = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_PC_SIDES_WITH_WEREWOLVES_AGAINST_ELVES);
            int nAttack = WR_GetPlotFlag(PLT_NTB340PT_LADY,NTB_LADY_PREPARE_TO_ATTACK_ELVES_WITH_WEREWOLVES);
            int nSacrifice = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ZATHRIAN_SACRIFICES_HIMSELF);
            int nSwiftrunner = WR_GetPlotFlag(PLT_NTB200PT_SWIFTRUNNER,NTB_SWIFTRUNNER_WEREWOLVES_LEAVE);
            int nCure = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ELVES_CURED);
            int nPromise = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ELVES_PROMISED_ALLIANCE);
            int nZathrianDead = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ZATHRIAN_KILLED_BY_PC);


            object oLanaya = UT_GetNearestCreatureByTag(oPC,NTB_CR_LANAYA);

            // -----------------------------------------------------
            // if the elves are cured
            // -----------------------------------------------------
            if((nCure == TRUE))
            {
                // -----------------------------------------------------
                // and the elves haven't promised their alliance
                // and Zathrian didn't so much sacrifice himself
                // Zathrian should initiate
                // -----------------------------------------------------
                if((nPromise == FALSE) && (nSacrifice == FALSE))
                {
                    UT_Talk(oZathrian,oPC);
                }

            }

            //Check for Mabari Dominance
            if (WR_GetPlotFlag(PLT_LITE_MABARI_DOM, MABARI_DOM_LOTHERING) == TRUE)
            {
                //if dog is in the party -
                int nDog = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY);
                if (nDog == TRUE)
                {
                    object oDog = Party_GetFollowerByTag("gen00fl_dog");
                    //if this flag has been set - activate the bonus and show the message
                    UI_DisplayMessage(oDog, 4010);

                    //Activate Bonus here
                    effect eDog = EffectMabariDominance();
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eDog, oDog, 0.0f, oDog, 200261);
                }

            }

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature exits the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_EXIT:
        {

            //if dog is in the party -
            int nDog = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY);
            if (nDog == TRUE)
            {
                object oDog = Party_GetFollowerByTag("gen00fl_dog");
                //DeActivate Bonus here
                RemoveEffectsByParameters(oDog, EFFECT_TYPE_INVALID, 200261);
            }

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: Scripting
        // When: The last creature of a team dies
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_TEAM_DESTROYED:
        {
            int nTeamID = GetEventInteger(ev, 0); // Team ID

            switch (nTeamID)
            {
                case NTB_TEAM_CAMP_ZATHRIAN:
                {
                    int nTeam = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ELVES_DEFEATED,TRUE);
                    // -----------------------------------------------------
                    // if the wolves haven't reveled in the elves defeat yet
                    // return the party picker status to useable
                    // set witherfang and swiftrunner non-immortal again
                    // set witherfang inactive and the Lady active
                    // set that athras is dead
                    // and have the Lady Initiate
                    // -----------------------------------------------------
                    if(nTeam == FALSE)
                    {
                        SetPartyPickerGUIStatus(PP_GUI_STATUS_USE);

                        SetImmortal(oWitherfang,FALSE);
                        SetImmortal(oSwiftrunner,FALSE);

                        WR_SetObjectActive(oWitherfang,FALSE);
                        WR_SetObjectActive(oLady,TRUE);

                        //Move Werewolves to their posts
                        object oWerewolf3 = UT_GetNearestCreatureByTag(oPC, NTB_CR_WEREWOLF_03);
                        UT_LocalJump(oWerewolf3, NTB_WP_WEREWOLF3_POST);

                        WR_SetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ELVES_DEFEATED,TRUE,TRUE);
                        //- When all elves are dead, Witherfang will turn back into the lady and she will init dialog.
                        UT_Talk(oLady,oPC);
                    }
                    break;
                }
            }
            break;
        }

        //------------------------------------------------------------------
        // EVENT_TYPE_STEALING_SUCCESS:
        // Sent by: Skill Script ( skill_stealing)
        // When: player succeeds stealing skill
        //------------------------------------------------------------------

        case EVENT_TYPE_STEALING_SUCCESS:
        {
            LogTrace(LOG_CHANNEL_SYSTEMS,"ntb100ar_dalish_camp::EVENT_TYPE_STEALING_SUCCESS",OBJECT_SELF);



            break;
        }

        //------------------------------------------------------------------
        // EVENT_TYPE_STEALING_FAILURE:
        // Sent by: Skill Script ( skill_stealing)
        // When: player fails stealing skill
        //------------------------------------------------------------------

        case EVENT_TYPE_STEALING_FAILURE:
        {
            LogTrace(LOG_CHANNEL_SYSTEMS,"ntb100ar_dalish_camp::EVENT_TYPE_STEALING_FAILURE",OBJECT_SELF);

            int nElf = WR_GetPlotFlag(PLT_GEN00PT_STEALING,STEALING_NTB_NEAR_ELF,TRUE);
            object oElfMale = UT_GetNearestCreatureByTag(oPC,NTB_CR_ELF_MALE);

            // -----------------------------------------------------
            // Sets NTB infamy for stealing
            // -----------------------------------------------------
            WR_SetPlotFlag(PLT_GEN00PT_STEALING,STEALING_NTB_INFAMY,TRUE,TRUE);

            // -----------------------------------------------------
            // if you were stealing near an elf,
            // the elf initiates
            // -----------------------------------------------------
            if(nElf == TRUE)
            {
                WR_SetPlotFlag(PLT_GEN00PT_STEALING,STEALING_NTB_FAILED_NEAR_ELF,TRUE,TRUE);
                UT_Talk(oElfMale,oPC);
            }
            break;
        }
    }
    HandleEvent(ev, RESOURCE_SCRIPT_AREA_CORE);
}