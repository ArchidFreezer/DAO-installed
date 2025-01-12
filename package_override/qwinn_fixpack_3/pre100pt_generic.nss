//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events
*/
//:://////////////////////////////////////////////
//:: Created By: Yaron
//:: Created On: July 21st, 2006
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "pre_objects_h"

#include "plt_orzpt_main"
#include "plt_pre100pt_generic"
#include "pre100_lightning_h"
#include "plt_mnp000pt_main_events"
#include "plt_ntb000pt_main"
#include "plt_cir000pt_main"
#include "plt_gen00pt_party"
#include "plt_pre100pt_light_beacon"
#include "plt_arl000pt_contact_eamon"
#include "plt_gen00pt_backgrounds"
#include "plt_cod_cha_alistair"
#include "plt_cod_cha_flemeth"
#include "plt_cod_cha_morrigan"
#include "sys_audio_h"

#include "campaign_h"

int StartingConditional()
{
    event eParms = GetCurrentEvent();                // Contains all input parameters
    int nType = GetEventType(eParms);               // GET or SET call
    string strPlot = GetEventString(eParms, 0);         // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);          // The bit flag # being affected
    object oParty = GetEventCreator(eParms);      // The owner of the plot table for this script
    int nGetResult = FALSE; // used to return value for DEFINED GET events

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    object oPC = GetHero();

    object oEnchanter = UT_GetNearestCreatureByTag(oPC, PRE_CR_ULDRED);
    object oGrandCleric = UT_GetNearestCreatureByTag(oPC, PRE_CR_GRAND_CLERIC);
    object oDuncan = UT_GetNearestCreatureByTag(oPC, PRE_CR_DUNCAN);
    object oCailan = UT_GetNearestCreatureByTag(oPC, PRE_CR_CAILAN);
    object oLoghain = UT_GetNearestCreatureByTag(oPC, PRE_CR_LOGHAIN);
    object oMap = UT_GetNearestObjectByTag(oPC, PRE_IP_STRATEGY_MAP);
    object oAlistair = UT_GetNearestCreatureByTag(oPC, GEN_FL_ALISTAIR);
    object oMorrigan = UT_GetNearestCreatureByTag(oPC, GEN_FL_MORRIGAN);
    object oToCamp = UT_GetNearestObjectByTag(oPC, PRE_IP_FLEMETH_TO_CAMP);


    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case PRE_GENERIC_STRATEGY_MEETING_END:
            {
                if (nValue == 1)
                {
                    WR_SetObjectActive(oCailan, FALSE);
                    WR_SetObjectActive(oLoghain, FALSE);
                    WR_SetObjectActive(oEnchanter, FALSE);
                    WR_SetObjectActive(oGrandCleric, FALSE);
                    WR_SetObjectActive(oMap, FALSE);

                    if (ReadIniEntry("DebugOptions","E3Mode") == "1" ||
                    GetLocalInt(GetModule(), DEMO_ACTIVE) == TRUE)
                    {
                        object oDaveth = UT_GetNearestCreatureByTag(oPC, PRE_CR_DAVETH);
                        UT_LocalJump(oDaveth, PRE_WP_MEETING_ENCHANTER);
                        WR_SetObjectActive(oDaveth, TRUE);
                        UT_HireFollower(oDaveth);
                        WR_ClearAllCommands(oAlistair);
                        UT_LocalJump(oAlistair, PRE_WP_MEETING_CAILAN);
                        WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY, TRUE, TRUE);
                        WR_SetObjectActive(oDuncan, FALSE);

                        WR_SetPlotFlag(PLT_PRE100PT_LIGHT_BEACON, PRE_BEACON_DUNCAN_LEAVES_FOR_BATTLE, TRUE, TRUE);
                    }
                    else // NOT DEMO!
                    {

                        if (WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_HUMAN_NOBLE, TRUE))
                        {
                            object oDog = Party_GetActiveFollowerByTag(GEN_FL_DOG);
                            UT_LocalJump(oDog, PRE_WP_DUNCANS_FIRE_DOG, TRUE);
                        }

                        UT_LocalJump(oAlistair, PRE_WP_DUNCANS_FIRE_ALISTAIR, TRUE);

                        UT_LocalJump(oDuncan, PRE_WP_DUNCANS_FIRE);

                        UT_LocalJump(oPC, PRE_WP_DUNCANS_FIRE);
                        UT_Talk(oDuncan, oPC);
                    }

                    // Set the stormy atmosphere
                    ATM_Fade(ATM_PRESET_NIGHT, ATM_PRESET_BATTLE, 15.0f, ATM_FADE_TYPE_EASE_IN);

                    //SetFBSettings(ATM_PRESET_FB_BATTLE);

                    // Setup the lightning storm (pre100_lightning_h)
                    PRE_Storm_LightningStart( 30.0f );
                    AudioTriggerPlotEvent(5);

                    // @joshua: removed need for calling GetObjectsInArea
                    // deactivate all the friendlies on team PRE_TEAM_DEACTIVATE_AFTER_CAMP_ATTACK
                    int         nIndex;
                    object      oCurrent;
                    object []   arDeactivateTeam = GetTeam(PRE_TEAM_DEACTIVATE_AFTER_CAMP_ATTACK);
                    int         nArraySize = GetArraySize(arDeactivateTeam);
                    for ( nIndex = 0; nIndex < nArraySize; nIndex++ )
                    {
                        oCurrent = arDeactivateTeam[nIndex];
                        if ((ReadIniEntry("DebugOptions","E3Mode") == "1" || GetLocalInt(GetModule(), DEMO_ACTIVE) == TRUE)
                            && GetTag(oCurrent) == PRE_CR_DAVETH)
                            continue;
                        WR_SetObjectActive(oCurrent, FALSE);
                    }

                    object oQuarterMasterMapNote = GetObjectByTag(PRE_WP_QUARTERMASTER);
                    SetMapPinState(oQuarterMasterMapNote,FALSE);





                }

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_OSTAGAR_6);

                break;
            }
            case PRE_GENERIC_STRATEGY_MEETING_START:
            {
                if (nValue == 1)
                {
                    /* Moved all of this to the end of the ritual*
                    // jump Duncan, the player, Cailan, Loghain, Enchanger and Grand cleric to the meeting,
                    // start strategy meeting dialog with Cailan

                    WR_SetObjectActive(oCailan, TRUE);
                    WR_SetObjectActive(oLoghain, TRUE);
                    WR_SetObjectActive(oEnchanter, TRUE);
                    WR_SetObjectActive(oGrandCleric, TRUE);
                    WR_SetObjectActive(oMap, TRUE);
                    */


                    // Lock away wilds and close camp gate
                    object oWildsGate       = UT_GetNearestObjectByTag(oPC, PRE_IP_WILDS_GATE);
                    object oCampGateOpen    = UT_GetNearestObjectByTag(oPC, PRE_IP_CAMP_GATE_OPEN);
                    object oCampGateClosed  = UT_GetNearestObjectByTag(oPC, PRE_IP_CAMP_GATE_CLOSED);

                    SetPlaceableState(oWildsGate, PLC_STATE_AREA_TRANSITION_LOCKED);

                    WR_SetObjectActive(oCampGateClosed, TRUE);
                    WR_SetObjectActive(oCampGateOpen, FALSE);

                    // Play ambient conversation sound
/*                    object oAmbientConv = GetObjectByTag(PRE_SD_AMBIENT_CONV);
                    WR_SetObjectActive(oAmbientConv,TRUE);
                    PlaySoundObject(oAmbientConv);
*/
                    // Clear Duncan's and Alistair command queue
                    WR_ClearAllCommands(oDuncan, TRUE);
                    WR_ClearAllCommands(oAlistair, TRUE);

                    UT_Talk(oCailan, oPC);
                }

                break;
            }
            case PRE_GENERIC_PRELUDE_DONE:
            {
                if (nValue == 1)
                {
                    // activating primary world map
                    // NOTE: this is actually set on sp_module_start. Was put here just in case
                    object oWideOpenWorldMap = GetObjectByTag(WM_WOW_TAG);
                    WR_SetWorldMapPrimary(oWideOpenWorldMap);

                    // Trigger the wide-open-world main plot
                    WR_SetPlotFlag(PLT_MNP000PT_MAIN_EVENTS, WIDE_OPEN_WORLD_START, TRUE, TRUE);

                    // Set Plot Flags to fill Journal with WOW Plots
                    WR_SetPlotFlag(PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_01_ACCEPTED, TRUE, TRUE);
                    //Nature of the Beast Journal Entry
                    WR_SetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_PLOT_OPEN,TRUE,TRUE);
                    //Broken Circle Journal Entry
                    WR_SetPlotFlag(PLT_CIR000PT_MAIN,BROKEN_CIRCLE_LEAD_IN,TRUE,TRUE);
                    // Arl Eamon
                    WR_SetPlotFlag(PLT_ARL000PT_CONTACT_EAMON, ARL_CONTACT_EAMON_TOLD_TO_CONTACT_EAMON, TRUE);
                       
                    // Qwinn:  The following shouldn't be set until Alistair actually reveals this information
                    // in his dialogue.
                    // WR_SetPlotFlag(PLT_COD_CHA_ALISTAIR, COD_CHA_ALISTAIR_PRELUDE, TRUE);
                    WR_SetPlotFlag(PLT_COD_CHA_MORRIGAN, COD_CHA_MORRIGAN_JOINED, TRUE);
                    WR_SetPlotFlag(PLT_COD_CHA_FLEMETH, COD_CHA_FLEMETH_MAIN, TRUE);

                    //object oCamp = GetObjectByTag(WML_WOW_CAMP);
                    object oLothering = GetObjectByTag(WML_WOW_LOTHERING);

                    //WR_SetWorldMapLocationStatus(oCamp, WM_LOCATION_ACTIVE);
                    WR_SetWorldMapLocationStatus(oLothering, WM_LOCATION_ACTIVE);


                    SetPartyPickerGUIStatus(PP_GUI_STATUS_NO_USE);
                    SetLocalInt(GetModule(), PARTY_PICKER_GUI_ALLOWED_TO_POP_UP, FALSE);

                    //SetLocalInt(GetModule(), PARTY_PICKER_GUI_ALLOWED_TO_POP_UP, TRUE);

                    // Enabling world map GUI button
                    SetWorldMapGuiStatus(WM_GUI_STATUS_USE);

                    // Flag world map as opened
                    SetLocalInt(GetModule(), MODULE_WORLD_MAP_ENABLED, 1);

                    SetLocalInt(GetArea(OBJECT_SELF), AREA_WORLD_MAP_ENABLED, TRUE);

                    // advance blight...
                    Campaign_SetBlight(2);

                    //OpenPrimaryWorldMap();
                }

                break;
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {

        }

    }

    return nGetResult;
}