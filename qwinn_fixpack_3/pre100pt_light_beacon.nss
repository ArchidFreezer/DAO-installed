//==============================================================================
/*

    Prelude
     -> Light Beacon Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Yaron
// Created On: July 21st, 2006
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "pre_objects_h"
#include "cutscenes_h"
#include "party_h"
#include "ai_main_h_2"

#include "plt_prept_generic_actions"
#include "pre100_bridge_attack_h"
#include "plt_pre100pt_light_beacon"
#include "plt_pre100pt_camp_attack"
#include "plt_genpt_alistair_events"
#include "plt_gen00pt_party"
#include "plt_prept_generic_actions"
#include "plt_pre100pt_mabari"
#include "plt_pre100pt_prisoner"
#include "plt_cod_cha_duncan"
#include "plt_cod_cha_cailan"
#include "plt_cod_cha_loghain"
#include "plt_cod_cha_cauthrien"
#include "plt_mnp00pt_ssf_prelude"
#include "plt_mnp000pt_autoss_main"
#include "sys_ambient_h"
#include "pre_functions_h"
#include "pre440_darkspawn_h"
#include "sys_audio_h"

int StartingConditional()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evEvent = GetCurrentEvent();            // Contains input parameters
    int     nType   = GetEventType(evEvent);        // GET or SET call
    string  sPlot   = GetEventString(evEvent, 0);   // Plot GUID
    int     nFlag   = GetEventInteger(evEvent, 1);  // The bit flag # affected
    object  oOwner  = GetEventCreator(evEvent);     // Script plot table owner

    // Grab Player, Set Default return to FALSE
    object  oPC     = GetHero();
    int     bResult = FALSE;

    // Plot Debug / Global Operations
    plot_GlobalPlotHandler(evEvent);

    //--------------------------------------------------------------------------
    // Actions -> normal flags only (SET)
    // IMPORTANT:   The flag value on a SET event is set only AFTER this script
    //              finishes running!
    //--------------------------------------------------------------------------

    if( nType == EVENT_TYPE_SET_PLOT )
    {

        int nOldValue   = GetEventInteger(evEvent, 3);  // Old flag value
        int nNewValue   = GetEventInteger(evEvent, 2);  // New flag value

        // Check for which flag was set
        switch(nFlag)
        {


            case PRE_BEACON_CAILAN_CHARGE_CUTSCENE:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_BEACON_CAILAN_CHARGE_CUTSCENE
                // Play the King and Duncan Charge cutscene. This should
                // set the PRE_BEACON_DUNCAN_LEAVES_FOR_BATTLE flag when
                // the cutscene is done.
                //--------------------------------------------------------------

                object oSound;

                //--------------------------------------------------------------

                oSound = GetObjectByTag(PRE_SD_CHARGE_CUTSCENE);
                WR_SetObjectActive(oSound,TRUE);
                PlaySoundObject(oSound);

                // Deactivate these sounds for cutscene
/*                oSound = GetObjectByTag(PRE_SD_HORN);
                WR_SetObjectActive(oSound,FALSE);
                StopSoundObject(oSound);
                oSound = GetObjectByTag(PRE_SD_THUNDER);
                WR_SetObjectActive(oSound,FALSE);
                StopSoundObject(oSound);
                oSound = GetObjectByTag(PRE_SD_THUNDER_2);
                WR_SetObjectActive(oSound,FALSE);
                StopSoundObject(oSound);
                oSound = GetObjectByTag(PRE_SD_LOWHIT);
                WR_SetObjectActive(oSound,FALSE);
                StopSoundObject(oSound);
                oSound = GetObjectByTag(PRE_SD_WARDOG);
                WR_SetObjectActive(oSound,FALSE);
                StopSoundObject(oSound);
*/
                SetMusicIntensity(0);
                AudioTriggerPlotEvent(6);
                CS_LoadCutscene(CUTSCENE_PRE_CAILAN_CHARGES,PLT_PRE100PT_LIGHT_BEACON,PRE_BEACON_CAILAN_CHARGE_CUTSCENE_END);

                break;

            }

            case PRE_BEACON_CAILAN_CHARGE_CUTSCENE_END:
            {

                //--------------------------------------------------------------
                // PRE_BEACON_CAILAN_CHARGE_CUTSCENE_END
                //--------------------------------------------------------------

                object      oSound;
                object      oAlistair;

                //--------------------------------------------------------------

                oAlistair = UT_GetNearestObjectByTag(oPC,GEN_FL_ALISTAIR);

                //--------------------------------------------------------------

                // Setup the the bridge being attacked (pre100_bridge_attack_h)

                PRE_BridgeAttack_Setup();
                AudioTriggerPlotEvent(7);

                // Stop charge cutscene Ambients
                oSound = GetObjectByTag(PRE_SD_CHARGE_CUTSCENE);
                WR_SetObjectActive(oSound, FALSE);
                StopSoundObject(oSound);

                // Apply Rain to PC & activate rain sounds
                ApplyEffectOnObject( EFFECT_DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_RAIN), oPC );
/*                oSound = GetObjectByTag(PRE_SD_RAIN_HEAVY);
                WR_SetObjectActive(oSound, TRUE);
                PlaySoundObject(oSound);
                oSound = GetObjectByTag(PRE_SD_RAIN_HEAVY_2);
                WR_SetObjectActive(oSound, TRUE);
                PlaySoundObject(oSound);
                oSound = GetObjectByTag(PRE_SD_RAIN1);
                WR_SetObjectActive(oSound, TRUE);
                PlaySoundObject(oSound);
                oSound = GetObjectByTag(PRE_SD_RAIN2);
                WR_SetObjectActive(oSound, TRUE);
                PlaySoundObject(oSound);
                oSound = GetObjectByTag(PRE_SD_RAIN3);
                WR_SetObjectActive(oSound, TRUE);
                PlaySoundObject(oSound);
                oSound = GetObjectByTag(PRE_SD_RAIN4);
                WR_SetObjectActive(oSound, TRUE);
                PlaySoundObject(oSound);

                // More Sounds
                oSound = GetObjectByTag(PRE_SD_HORN);
                WR_SetObjectActive(oSound,TRUE);
                PlaySoundObject(oSound);
                oSound = GetObjectByTag(PRE_SD_THUNDER);
                WR_SetObjectActive(oSound,TRUE);
                PlaySoundObject(oSound);
                oSound = GetObjectByTag(PRE_SD_THUNDER_2);
                WR_SetObjectActive(oSound,TRUE);
                PlaySoundObject(oSound);
                oSound = GetObjectByTag(PRE_SD_LOWHIT);
                WR_SetObjectActive(oSound,TRUE);
                PlaySoundObject(oSound);
                oSound = GetObjectByTag(PRE_SD_WARDOG);
                WR_SetObjectActive(oSound,TRUE);
                PlaySoundObject(oSound);

                // Army Sounds
                oSound = GetObjectByTag(PRE_SD_ARMY1);
                WR_SetObjectActive(oSound, TRUE);
                PlaySoundObject(oSound);
                oSound = GetObjectByTag(PRE_SD_ARMY2);
                WR_SetObjectActive(oSound,TRUE);
                PlaySoundObject(oSound);
*/
                // Spawn sprite army
                WR_SetPlotFlag(PLT_PREPT_GENERIC_ACTIONS, PRE_GA_SPAWN_SPRITE_ARMY, TRUE, TRUE);

//                object oAlistair = UT_GetNearestObjectByTag(oPC,GEN_FL_ALISTAIR);
                object oDog = UT_GetNearestObjectByTag(oPC,GEN_FL_DOG);
                UT_LocalJump(oPC, PRE_WP_AFTER_CHARGE, TRUE, FALSE);
                UT_LocalJump(oAlistair, PRE_WP_AFTER_CHARGE, TRUE, FALSE);

                if(WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY) == TRUE)
                    {
                        UT_LocalJump(oDog, PRE_WP_AFTER_CHARGE, TRUE, FALSE);
                    }

               // DoAutoSave();

                // Setup Alistair's event dialog
                WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_ON, TRUE);
                WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_BATTLE_START, TRUE);
                // Alistair inits dialog after the cutscene
                UT_Talk(oAlistair, oPC);

                //Take an automatic screenshot
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN, AUTOSS_PRE_CHARGE_AT_OSTAGAR, TRUE, TRUE);

                break;

            }


            case PRE_BEACON_DUNCAN_LEAVES_FOR_BATTLE:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_BEACON_DUNCAN_LEAVES_FOR_BATTLE
                // **IMPORTANT**
                // A lot of stuff happens off this plot flag, keep things
                // efficient PLEASE!!!
                //--------------------------------------------------------------

                object      oAlistair;
                object      oDuncan;

                //--------------------------------------------------------------

                oDuncan   = GetObjectByTag(PRE_CR_DUNCAN);
                oAlistair = UT_GetNearestObjectByTag(oPC,GEN_FL_ALISTAIR);

                //--------------------------------------------------------------

                // Deactivate Duncan
                WR_SetObjectActive(oDuncan,FALSE);

                // re-hire Alistair
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_RECRUITED, TRUE, TRUE);
                WR_SetPlotFlag(PLT_PREPT_GENERIC_ACTIONS, PRE_GA_PC_ENTERED_BATTLEFIELD, TRUE, TRUE);

                // too late to give the flower to the vet
                /* Qwinn:  Added a few conditions.
                if(WR_GetPlotFlag(PLT_PRE100PT_MABARI, PRE_MABARI_PC_HAS_FLOWER)
                    || (WR_GetPlotFlag(PLT_PRE100PT_MABARI, PRE_MABARI_VET_ASKED_FOR_FLOWER)
                        && !WR_GetPlotFlag(PLT_PRE100PT_MABARI, PRE_MABARI_DOG_HEALED)))
                {
                    WR_SetPlotFlag(PLT_PRE100PT_MABARI, PRE_MABARI_QUEST_ABANDONED, TRUE, TRUE);
                }
                */
                if((WR_GetPlotFlag(PLT_PRE100PT_MABARI, PRE_MABARI_VET_ASKED_FOR_FLOWER) ||
                    WR_GetPlotFlag(PLT_PRE100PT_MABARI, PRE_MABARI_PC_HAS_FLOWER) ||
                    WR_GetPlotFlag(PLT_PRE100PT_MABARI, PRE_MABARI_PC_HAS_FLOWER_NO_QUEST) ||
                    WR_GetPlotFlag(PLT_PRE100PT_MABARI, PRE_MABARI_PC_HAS_MUZZLE)  ||
                    WR_GetPlotFlag(PLT_PRE100PT_MABARI, PRE_MABARI_PC_WANTS_TO_KILL_DOG)) &&
                    !(WR_GetPlotFlag(PLT_PRE100PT_MABARI, PRE_MABARI_DOG_KILLED) ||
                      WR_GetPlotFlag(PLT_PRE100PT_MABARI, PRE_MABARI_DOG_HEALED) ||
                      WR_GetPlotFlag(PLT_PRE100PT_MABARI, PRE_MABARI_VET_GIVEN_FLOWER_NO_QUEST)))
                {
                    WR_SetPlotFlag(PLT_PRE100PT_MABARI, PRE_MABARI_QUEST_ABANDONED, TRUE, TRUE);
                }


                if (WR_GetPlotFlag(PLT_PRE100PT_PRISONER, PRE_PRISONER_ASKED_FOR_FOOD)
                    && !(WR_GetPlotFlag(PLT_PRE100PT_PRISONER, PRE_PRISONER_KILLED)
                         // Qwinn (v3.0)  Actually, the problem was this should be PRISONER_FED, which is different
                         // || WR_GetPlotFlag(PLT_PRE100PT_PRISONER, PRE_PRISONER_GOT_FOOD)
                         || WR_GetPlotFlag(PLT_PRE100PT_PRISONER, PRE_PRISONER_FED) ))
                         // Qwinn: (v1.0) Added this condition to prevent erroneous closing entry text
                         // || WR_GetPlotFlag(PLT_PRE100PT_PRISONER, PRE_PRISONER_GIVE_KEY)) )
                {
                    WR_SetPlotFlag(PLT_PRE100PT_PRISONER, PRE_PRISONER_ABANDONED, TRUE, TRUE);
                }

                // Qwinn: I had added new closing entry for leaving Ostagar with Prisoner key here, but chest is still accessible
                // Moved it to pre211ar_flemeths_hut_int.nss, where all the lite content from Korkari Wilds gets closed.

                // Qwinn: Need to deactivate the ballista we have blocking path over bridge.
                object oBridgeBlock = UT_GetNearestObjectByTag(oPC, "pre420ip_bridgeblock");
                WR_SetObjectActive(oBridgeBlock, FALSE);

                break;

            }


            case PRE_BEACON_BATTLE_START:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_BEACON_BATTLE_START
                //--------------------------------------------------------------

                int         nIndex;
                int         nArraySize;
                int         nPartySize;
                object      oTowerGuard1;
                object      oTowerGuard2;
                object      oTowerGuard3;
                object      oRoadSoldier;
                object      oGateClosed;
                object      oGateOpen;
                object      oCurrent;
                object []   arDeadCampTeam;

                //--------------------------------------------------------------

                nPartySize      = GetArraySize(GetPartyList(oPC));
                arDeadCampTeam  = UT_GetTeam(PRE_TEAM_CAMP_NIGHT_ATTACK_DEAD);
                oTowerGuard1    = UT_GetNearestObjectByTag(oPC, PRE_CR_TOWER_GUARD);
                oTowerGuard2    = UT_GetNearestObjectByTag(oPC, PRE_CR_HELPER);
                oTowerGuard3    = UT_GetNearestObjectByTag(oPC, PRE_CR_HELPER_MAGE);
                oRoadSoldier    = UT_GetNearestObjectByTag(oPC, PRE_CR_ROAD_SOLDIER);
                oGateClosed     = UT_GetNearestObjectByTag(oPC, PRE_IP_TOWER_GATE_CLOSED);
                oGateOpen       = UT_GetNearestObjectByTag(oPC, PRE_IP_TOWER_GATE_OPEN);

                //--------------------------------------------------------------

                // @joshua: kill all the creatures on team PRE_TEAM_CAMP_NIGHT_ATTACK_DEAD
                //  - set that they spawn dead so their bodies stay
                //  - set gore level so they look good and beat up
                nArraySize = GetArraySize(arDeadCampTeam);
                for ( nIndex = 0; nIndex < nArraySize; nIndex++ )
                {
                    oCurrent = arDeadCampTeam[nIndex];
                    SetLocalInt(oCurrent,CREATURE_SPAWN_DEAD,TRUE);
                    SetCreatureGoreLevel(oCurrent,1.0f);
                    KillCreature(oCurrent);
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_GROUND_BLOODPOOL_S), oCurrent);
                }

                // open gates
                WR_SetObjectActive(oGateOpen, TRUE);
                WR_SetObjectActive(oGateClosed, FALSE);

                // Deactivate the road guard
                WR_SetObjectActive(oRoadSoldier, FALSE);

                // Disable ambient ai for first tower guard.
                Ambient_Stop(oTowerGuard1);
                SetLocalInt(oTowerGuard1,"AMBIENT_SYSTEM_ENABLED",0);

                // Qwinn:  Replacing helm on tower guard as it is too high level for his strength
                object oBadHelm = GetItemInEquipSlot(INVENTORY_SLOT_HEAD, oTowerGuard1);
                RemoveItem(oBadHelm,1);
                object oGoodHelm = UT_AddItemToInventory(R"gen_im_arm_hel_med_hel.uti",1,oTowerGuard1,"gen_im_arm_hel_med_hel");
                SetItemMaterialType(oGoodHelm, 2); // Gray Iron like the rest of his gear
                EquipItem(oTowerGuard1,oGoodHelm,INVENTORY_SLOT_HEAD);
                
                //Jump the guard to prepare for next conversation.


                // if dog is in the party, second guard isn't needed
                if (GetCreatureCoreClass(oPC) == CLASS_WIZARD)
                {
                    UT_LocalJump(oTowerGuard1, PRE_WP_BATTLE_START);
                    UT_LocalJump(oTowerGuard2, PRE_WP_BATTLE_START);
                    WR_SetObjectActive(oTowerGuard3, FALSE);
                }
                if(GetCreatureCoreClass(oPC) != CLASS_WIZARD && GetPlayerBackground(oPC) == 5)
                {
                    UT_LocalJump(oTowerGuard1, PRE_WP_BATTLE_START);
                    UT_LocalJump(oTowerGuard3, PRE_WP_BATTLE_START);
                    WR_SetObjectActive(oTowerGuard2, FALSE);
                }
                if (nPartySize < 3 && GetCreatureCoreClass(oPC) != CLASS_WIZARD && GetPlayerBackground(oPC) != 5)
                {
                    UT_LocalJump(oTowerGuard1, PRE_WP_BATTLE_START);
                    UT_LocalJump(oTowerGuard3, PRE_WP_BATTLE_START);
                    WR_SetObjectActive(oTowerGuard2, FALSE);
                }


                break;

            }


            case PRE_BEACON_GUARD_ARRIVES:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_BEACON_GUARD_ARRIVES
                // PLOT:    One or two tower guards come out running from
                //          the darkspawn in the tower
                //--------------------------------------------------------------

                int         nPartySize;
                object      oTowerGuard1;
                object      oTowerGuard2;
                object      oTowerGuard3;

                //--------------------------------------------------------------

                nPartySize      = GetArraySize(GetPartyList(oPC));
                oTowerGuard1    = UT_GetNearestObjectByTag(oPC, PRE_CR_TOWER_GUARD);
                oTowerGuard2    = UT_GetNearestObjectByTag(oPC, PRE_CR_HELPER);
                oTowerGuard3    = UT_GetNearestObjectByTag(oPC, PRE_CR_HELPER_MAGE);

                //--------------------------------------------------------------

                if (nPartySize < 3 && GetCreatureCoreClass(oPC) == CLASS_WIZARD)
                {
                    UT_Talk(oTowerGuard1, oTowerGuard1);
                    WR_SetObjectActive(oTowerGuard3, FALSE);
                }
                // If dog is not in party, other guard speaks
                if (GetCreatureCoreClass(oPC) != CLASS_WIZARD && GetPlayerBackground(oPC) == 5)
                {
                    UT_Talk(oTowerGuard3, oTowerGuard1);
                    WR_SetObjectActive(oTowerGuard2, FALSE);
                }
                if (nPartySize < 3 && GetCreatureCoreClass(oPC) != CLASS_WIZARD && GetPlayerBackground(oPC) != 5)
                {
                    UT_Talk(oTowerGuard1, oTowerGuard3);
                    WR_SetObjectActive(oTowerGuard2, FALSE);
                }

                break;

            }


            case PRE_BEACON_GUARD_RUNS:
            {

                if (!nNewValue || nOldValue)
                    break;

                //--------------------------------------------------------------
                // PRE_BEACON_GUARD_RUNS
                //--------------------------------------------------------------

                int         nPartySize;
                object      oTowerGuard1;
                object      oTowerGuard2;
                object      oTowerGuard3;

                //--------------------------------------------------------------

                nPartySize      = GetArraySize(GetPartyList(oPC));
                oTowerGuard1    = UT_GetNearestObjectByTag(oPC, PRE_CR_TOWER_GUARD);
                oTowerGuard2    = UT_GetNearestObjectByTag(oPC, PRE_CR_HELPER);
                oTowerGuard3    = UT_GetNearestObjectByTag(oPC, PRE_CR_HELPER_MAGE);

                //--------------------------------------------------------------



                // Have second guard run if party doesn't have dog
                if (GetCreatureCoreClass(oPC) == CLASS_WIZARD)
                {
                    UT_QuickMoveObject(oTowerGuard1,"2",TRUE,TRUE,TRUE,TRUE);
                    UT_QuickMoveObject(oTowerGuard2,"2",TRUE,TRUE,TRUE,TRUE);

                }

                if (GetCreatureCoreClass(oPC) != CLASS_WIZARD && GetPlayerBackground(oPC) == 5)
                {
                    UT_QuickMoveObject(oTowerGuard1,"2",TRUE,TRUE,TRUE,TRUE);
                    UT_QuickMoveObject(oTowerGuard3,"2",TRUE,TRUE,TRUE,TRUE);
                    WR_SetObjectActive(oTowerGuard2, FALSE);

                }

                if (GetCreatureCoreClass(oPC) != CLASS_WIZARD && GetPlayerBackground(oPC) != 5)
                {
                    UT_QuickMoveObject(oTowerGuard1,"2",TRUE,TRUE,TRUE,TRUE);
                    UT_QuickMoveObject(oTowerGuard3,"2",TRUE,TRUE,TRUE,TRUE);
                    WR_SetObjectActive(oTowerGuard2, FALSE);
                }

                break;

            }


            case PRE_BEACON_TOWER_REACHED:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_BEACON_TOWER_REACHED
                //--------------------------------------------------------------

                int         bBeaconTowerDoorClear;
                int         bTowerTalkDone;
                object      oAlistair;

                //--------------------------------------------------------------

                bBeaconTowerDoorClear = WR_GetPlotFlag( sPlot, PRE_BEACON_TOWER_DOOR_CLEAR, TRUE );
                bTowerTalkDone        = WR_GetPlotFlag( sPlot, PRE_BEACON_NIGHT_CAMP_TOWER_TALK_DONE );
                oAlistair             = UT_GetNearestObjectByTag(oPC,GEN_FL_ALISTAIR);

                //--------------------------------------------------------------

                if ( bBeaconTowerDoorClear && !bTowerTalkDone)
                {
                    if (ReadIniEntry("DebugOptions","E3Mode") == "0")
                    {
                        // Setup Alistair's event dialog
                        WR_SetPlotFlag(PLT_PRE100PT_LIGHT_BEACON, PRE_BEACON_NIGHT_CAMP_TOWER_TALK_DONE, TRUE);
                        WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_ON, TRUE);
                        WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_TOWER_BASE, TRUE);
                        UT_Talk(oAlistair, oPC);
                    }
                }

                break;

            }


            case PRE_BEACON_REACHED:
            {



                //--------------------------------------------------------------
                // PRE_BEACON_REACHED
                //--------------------------------------------------------------

                object      oAlistair;

                //--------------------------------------------------------------

                oAlistair = UT_GetNearestObjectByTag(oPC,GEN_FL_ALISTAIR);

                //--------------------------------------------------------------

                if (!GetGameMode() == GM_COMBAT)
                {
                    //if (ReadIniEntry("DebugOptions","E3Mode") == "0")
                    //{
                        // Setup Alistair's event dialog
                        WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_ON, TRUE);
                        WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_BEACON_REACHED, TRUE);
                        UT_Talk(oAlistair, oPC);
                    //}
                }

                break;

            }


            case PRE_BEACON_LIT:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_BEACON_LIT
                //--------------------------------------------------------------

                // clear Alistair's event flag so he stops repeating himself
                WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_ON, FALSE);

                // CUTSCENE: big betrayal cutscene

                if (GetCreatureRacialType(oPC) == 1)
                    {
                        CS_LoadCutscene(CUTSCENE_PRE_BETRAYAL_DWARF, PLT_PRE100PT_LIGHT_BEACON,PRE_BEACON_AFTER_BEACON_CUTSCENE);
                    }

                if (GetCreatureRacialType(oPC) == 2)
                    {
                        CS_LoadCutscene(CUTSCENE_PRE_BETRAYAL_ELF, PLT_PRE100PT_LIGHT_BEACON,PRE_BEACON_AFTER_BEACON_CUTSCENE);
                    }

                if (GetCreatureRacialType(oPC) == 3)
                    {
                        CS_LoadCutscene(CUTSCENE_PRE_BETRAYAL, PLT_PRE100PT_LIGHT_BEACON,PRE_BEACON_AFTER_BEACON_CUTSCENE);
                    }

                WR_SetPlotFlag(PLT_COD_CHA_CAILAN, COD_CHA_CAILAN_DEATH, TRUE);
                //Take automatic screenshots of the betrayal and Cailen's death
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN, AUTOSS_PRE_LOGHAIN_QUITS_THE_FIELD, TRUE, TRUE);
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN, AUTOSS_PRE_KING_CAILENS_DEATH, TRUE, TRUE);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_OSTAGAR_7);

                break;

            }


            case PRE_BEACON_TOWER_OGRE_DEAD:
            {

                //--------------------------------------------------------------
                // PRE_BEACON_REACHED
                //--------------------------------------------------------------

                object      oAlistair;
                object      oDuncan;
                object      oBeaconWP;

                //--------------------------------------------------------------

                oAlistair   = UT_GetNearestObjectByTag(oPC,GEN_FL_ALISTAIR);
                oBeaconWP   = UT_GetNearestObjectByTag(oAlistair, PRE_WP_TOWER_4_LIGHT_BEACON);

                //--------------------------------------------------------------

                SetFollowPartyLeader(oAlistair, FALSE);
                if (GetDistanceBetween(oAlistair, oBeaconWP) < 2.5)
                {
                    // if Alistair is at the signal fire he speaks up
                    WR_SetPlotFlag(PLT_PRE100PT_LIGHT_BEACON, PRE_BEACON_REACHED, TRUE, TRUE);
                    WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_ON, TRUE);
                    WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_BEACON_REACHED, TRUE);
                    UT_Talk(oAlistair, oPC);
                }
                else
                {
                    // Alistair runs over to the signal fire
                    UT_QuickMoveObject(oAlistair, PRE_WP_TOWER_4_LIGHT_BEACON, TRUE, TRUE, FALSE, TRUE);
                    WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_ON, TRUE);
                    WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_BEACON_REACHED, TRUE);
                    UT_Talk(oAlistair, oPC);
                }

                break;

            }


            case PRE_BEACON_AFTER_BEACON_CUTSCENE:
            {

                if (!nNewValue)
                    break;

                if (ReadIniEntry("DebugOptions","E3Mode") == "1" ||
                    GetLocalInt(GetModule(), DEMO_ACTIVE) == TRUE)
                {
                    resource rMovie = R"bwlogo.bik";
                    PlayMovie(rMovie);
                    SetGameMode(GM_PREGAME);
                    break;
                }


                //--------------------------------------------------------------
                // PRE_BEACON_AFTER_BEACON_CUTSCENE
                //--------------------------------------------------------------
                // trigger big fight with Darkspawn
                // When done:
                // CUTSCENE: Flemeth appears - when cutscene is done:
                //      Jump to Flemeth's interior hut
                //      Fire Alistair
                // On-entering Flemeth's hut interior:
                //      activate Morrigan at Flemeth's hut interior
                //      init dialog with Morrigan
                // On-entering Flemeth's hut exterior:
                //      activate Alistair at the hut exterior
                //      init dialog with Flemeth
                //--------------------------------------------------------------
 /*
                object      oArea;
                event       evActivate;

                //--------------------------------------------------------------

                oArea = GetArea(oPC);

                evActivate = Event(EVENT_TYPE_CUSTOM_EVENT_01);
*/
                //--------------------------------------------------------------

                //--------------------------------------------------------------
                // PRE_BEACON_TRIGGER_RESCUE_CUTSCENE
                //--------------------------------------------------------------

                object      oAlistair;
                object      oDog;
                object      oTowerGuard1;
                object      oTowerGuard2;
                object      oTowerGuard3;

                //--------------------------------------------------------------

                oAlistair       = UT_GetNearestObjectByTag(oPC, GEN_FL_ALISTAIR);
                oDog            = UT_GetNearestObjectByTag(oPC, GEN_FL_DOG);
                oTowerGuard1    = UT_GetNearestObjectByTag(oPC, PRE_CR_TOWER_GUARD);
                oTowerGuard2    = UT_GetNearestObjectByTag(oPC, PRE_CR_HELPER);
                oTowerGuard2    = UT_GetNearestObjectByTag(oPC, PRE_CR_HELPER_MAGE);

                //--------------------------------------------------------------

                // Remove the temporary helper NPCs from the party.
                UT_FireFollower(oTowerGuard1, TRUE, FALSE);
                WR_SetObjectActive(oTowerGuard1, FALSE);
                WR_SetPlotFlag(PLT_PREPT_GENERIC_ACTIONS, PRE_GA_TOWER_GUARD_2_LEAVES, TRUE, TRUE);

                // Get rid of Alistair until Flemeth's hut exterior
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_CAMP, TRUE, TRUE);
                WR_SetObjectActive(oAlistair, FALSE);
                //ResurrectCreature(oAlistair);

                if (IsPartyMember(oDog))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_CAMP, TRUE, TRUE);
                    WR_SetObjectActive(oDog, FALSE);
                    //ResurrectCreature(oDog);
                }

                //WR_SetPlotFlag(PLT_PRE100PT_LIGHT_BEACON, PRE_BEACON_TRIGGER_RESCUE_CUTSCENE, TRUE, TRUE);
                WR_SetPlotFlag(PLT_PRE100PT_LIGHT_BEACON, PRE_BEACON_AFTER_RESCUE_CUTSCENE, TRUE);


                UT_DoAreaTransition(PRE_AR_FLEMETH_HUT_INTERIOR, PRE_WP_FLEMETH_HUT_INSIDE);
                //WR_SetPlotFlag(PLT_MNP00PT_SSF_PRELUDE, SSF_PRELUDE_RESCUED, TRUE);

                WR_SetPlotFlag(PLT_COD_CHA_DUNCAN, COD_CHA_DUNCAN_DEATH, TRUE);
                WR_SetPlotFlag(PLT_COD_CHA_LOGHAIN, COD_CHA_LOGHAIN_BETRAYAL, TRUE);
                WR_SetPlotFlag(PLT_COD_CHA_CAUTHRIEN, COD_CHA_CAUTHRIEN_MAIN, TRUE);

                break;

            }


 /*           case PRE_BEACON_TRIGGER_RESCUE_CUTSCENE:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_BEACON_TRIGGER_RESCUE_CUTSCENE
                //--------------------------------------------------------------

                object      oAlistair;
                object      oDog;
                object      oTowerGuard1;
                object      oTowerGuard2;

                //--------------------------------------------------------------

                oAlistair       = UT_GetNearestObjectByTag(oPC, GEN_FL_ALISTAIR);
                oDog            = UT_GetNearestObjectByTag(oPC, GEN_FL_DOG);
                oTowerGuard1    = UT_GetNearestObjectByTag(oPC, PRE_CR_TOWER_GUARD);
                oTowerGuard2    = UT_GetNearestObjectByTag(oPC, PRE_CR_HELPER);

                //--------------------------------------------------------------

                // Remove the temporary helper NPCs from the party.
                UT_FireFollower(oTowerGuard1, TRUE);
                WR_SetObjectActive(oTowerGuard1, FALSE);
                if (IsPartyMember(oTowerGuard2))
                {
                    UT_FireFollower(oTowerGuard2, TRUE);
                    WR_SetObjectActive(oTowerGuard2, FALSE);
                }

                // Get rid of Alistair until Flemeth's hut exterior
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_CAMP, TRUE, TRUE);
                WR_SetObjectActive(oAlistair, FALSE);
                //ResurrectCreature(oAlistair);

                if (IsPartyMember(oDog))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_CAMP, TRUE, TRUE);
                    WR_SetObjectActive(oDog, FALSE);
                    //ResurrectCreature(oDog);
                }

                // Player has gone down in the fight after lighting the beacon.
                // Play "rescue" cutscene.
                CS_LoadCutscene(CUTSCENE_PRE_RESCUE, PLT_PRE100PT_LIGHT_BEACON,PRE_BEACON_AFTER_RESCUE_CUTSCENE);

                break;

            }
*/

            case PRE_BEACON_AFTER_RESCUE_CUTSCENE:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_BEACON_AFTER_RESCUE_CUTSCENE
                // When cutscene is done, jump to Flemeth's interior hut
                //--------------------------------------------------------------

                UT_DoAreaTransition(PRE_AR_FLEMETH_HUT_INTERIOR, PRE_WP_FLEMETH_HUT_INSIDE);

                break;

            }


        }
    }

    //--------------------------------------------------------------------------
    // Conditions -> defined flags only (GET DEFINED)
    //--------------------------------------------------------------------------

    else
    {

        // Check for which flag was checked
        switch(nFlag)
        {


            case PRE_BEACON_TOWER_DOOR_CLEAR:
            {

                //--------------------------------------------------------------
                // COND:    All Camp Attack groups are dead or the PC's party
                //          is not perceiving any hostiles
                //--------------------------------------------------------------

                int         bPerceivingHostiles;
                int         bGroup1Dead;
                int         bGroup2Dead;
                int         bGroup3Dead;

                //--------------------------------------------------------------

                bPerceivingHostiles = (IsPartyPerceivingHostiles(oPC));
                bGroup1Dead         = WR_GetPlotFlag(PLT_PRE100PT_CAMP_ATTACK, PRE_CAMP_ATTACK_1_DEAD);
                bGroup2Dead         = WR_GetPlotFlag(PLT_PRE100PT_CAMP_ATTACK, PRE_CAMP_ATTACK_2_DEAD);
                bGroup3Dead         = WR_GetPlotFlag(PLT_PRE100PT_CAMP_ATTACK, PRE_CAMP_ATTACK_3_DEAD);

                //--------------------------------------------------------------

                if ( (bGroup1Dead&&bGroup2Dead&&bGroup3Dead) || !bPerceivingHostiles)
                    bResult = TRUE;

                break;

            }


        }
    }

    // Plot Debug / Global Operations
    plot_OutputDefinedFlag( evEvent, bResult );

    return bResult;

}