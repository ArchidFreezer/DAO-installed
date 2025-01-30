#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "af_constants_h"
#include "af_logging_h"
#include "af_eds_include_h"
#include "af_nohelmet_h"

const int SPELLSHAPING_WARNING_STRREFID = 627214951;

// Utility functions
void testSpellShapingConfig();
void testExtraDogSlotValid();
void extraDogSlotInit();
void extraDogSlotPartyPicker();

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    // We will watch for every event type and if the one we need
    // appears we will handle it as a special case. We will ignore the rest
    // of the events
    switch ( nEventType )  {
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: The module loads from a save game. This event can fire more than
        //       once for a single module or game instance.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_MODULE_LOAD: {
            NoHelmetBookAdd();
            testSpellShapingConfig();
            testExtraDogSlotValid();
            break;
        }
        case EVENT_TYPE_GUI_OPENED: {

            int nGUIID = GetEventInteger(ev, 0); // ID number of the GUI that was opened
            switch (nGUIID) {
                case GUI_INVENTORY: {
                    NoHelmetShowInventory(); // No helmet mod
                    giveDogWhistle();
                    break;
                }
            }
            break;
        }
        case EVENT_TYPE_GAMEMODE_CHANGE: {

            int nNewGameMode = GetEventInteger(ev, 0); // New Game Mode (GM_* constant)
            int nOldGameMode = GetEventInteger(ev, 1); // Old Game Mode (GM_* constant)

            switch(nOldGameMode) {
                case GM_GUI:
                    NoHelmetLeaveGUI(); // No helmet mod
                    break;
                case GM_COMBAT:
                    afLogDebug(GetCurrentScriptName() + " : END OF COMBAT detected");
                    checkDogSlot();
                    break;
                case GM_LOADING:
                    extraDogSlotInit();
                    break;
            }
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: af_eds_include_h : deactivate_DogSlot
        // When: User uses ITEM_DOG_WHISTLE, but dog is already attached
        //       to someone. We end effect and tell dog to run away.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_DOG_RAN_AWAY: {
            afLogDebug("EVENT_DOG_RAN_AWAY receieved", AF_LOGGROUP_EDS);
            if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_DOG_RECRUITED))
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_CAMP, TRUE, TRUE);
            break;
        }
        case EVENT_MAKE_DOG_CLICKABLE: {
            afLogDebug("EVENT_MAKE_DOG_CLICKABLE received", AF_LOGGROUP_EDS);
            object oDog = eds_GetPartyPoolMemberByTag(GEN_FL_DOG);
            WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_CAMP, TRUE, TRUE);
            WR_SetObjectActive(oDog,TRUE);
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine (May have been relayed through af_item_eds_dog_whistle)
        // When: User uses item with ITEM_UNIQUE_POWER activation associated
        //       OR ITEM_DOG_WHISTLE associated.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_UNIQUE_POWER: {
            afLogDebug("EVENT_TYPE_UNIQUE_POWER", AF_LOGGROUP_EDS);
            handle_DogWhistle(ev);
            break;
        }
        case EVENT_TYPE_CREATURE_ENTERS_DIALOGUE: {
            // Remove dog when begin conversation with sloth demon in mage tower.
            object oCreature = GetEventObject(ev, 0);
            // afLogDebug(GetCurrentScriptName() + " : EVENT_TYPE_CREATURE_ENTERS_DIALOGUE [" +  GetTag(oCreature) + "]");
            if ("cir230cr_sloth_demon" == GetTag(oCreature)) removeDog(TRUE);
            break;
        }
        case EVENT_TYPE_POPUP_RESULT: {
            afLogDebug("EVENT_TYPE_POPUP_RESULT");
            int nPopupID  = GetEventInteger(ev, 0);

            // We cycle through the event handlers until we get one that handles the event
            if (2 == nPopupID) {
                if (1 == GetLocalInt(GetModule(), EDS_GET_DOG_NAME)) {
                    SetLocalInt(GetModule(), EDS_GET_DOG_NAME, 0);
                    string dogName = GetEventString(ev,0);
                    if ("" != dogName) {
                        // Find the dog and set its name:
                        object oDog = eds_GetPartyPoolMemberByTag(GEN_FL_DOG);
                        if (IsObjectValid(oDog)) {
                            afLogDebug("Renaming Dog to [" + dogName + "]");
                            SetName(oDog,dogName);
                        }
                    }
                }
            }
            break;
        }

        default:
            break;
    }
}

/**
 *
 * Start of utility functions
 *
 **/

void testSpellShapingConfig() {
    string appStr = GetM2DAString(TABLE_EVENTS, "Script", EVENT_TYPE_APPLY_EFFECT);
    string ablStr = GetM2DAString(TABLE_EVENTS, "Script", EVENT_TYPE_ABILITY_CAST_IMPACT);

    if (ablStr != "af_ablity_cast_impact" && ablStr != "eventmanager")
        ShowPopup(SPELLSHAPING_WARNING_STRREFID, 1, OBJECT_INVALID, FALSE, 0);
}

void testExtraDogSlotValid() {
  afLogDebug("Testing if dog slot valid", AF_LOGGROUP_EDS);

  int nChecked = GetLocalInt(GetModule(), EDS_CHECK_CONFLICT);
  if (0 == nChecked) {
    int bShowedVital = 0;
    int bShowedMinor = 0;

    // ======  VITAL EVENTS ======
    string dieStr  = GetM2DAString(TABLE_EVENTS, "Script", EVENT_TYPE_DYING);
    string firStr  = GetM2DAString(TABLE_EVENTS, "Script", EVENT_TYPE_PARTY_MEMBER_FIRED);

    int bDie = (-1 == FindSubString(dieStr,"eventmanager"));
    int bFir = (-1 == FindSubString(firStr,"eventmanager"));
    int bSum = 0;
    int bCom = 0;

    if (2 == (bDie + bFir)) {
      afLogWarn("MAJOR CONFLICTS DETECTED", AF_LOGGROUP_EDS);
      ShowPopup(E3_EDS_CONFLICT, AF_POPUP_MESSAGE_QUESTION);
    } else if (1 == (bDie + bFir)) {
      if (bDie) {
        afLogWarn("MAJOR CONFLICT DETECTED", AF_LOGGROUP_EDS);
        ShowPopup(E1_EDS_CONFLICT, AF_POPUP_MESSAGE_QUESTION);
      }
      if (bFir) {
        afLogWarn("MAJOR CONFLICT DETECTED", AF_LOGGROUP_EDS);
        ShowPopup(E2_EDS_CONFLICT, AF_POPUP_MESSAGE_QUESTION);
      }
    } else {

      // ======  MINOR EVENTS ======

      string sumStr  = GetM2DAString(TABLE_EVENTS, "Script", EVENT_TYPE_SUMMON_DIED);
      string penStr  = GetM2DAString(TABLE_EVENTS, "Script", EVENT_TYPE_COMMAND_PENDING);
      string comStr  = GetM2DAString(TABLE_EVENTS, "Script", EVENT_TYPE_COMMAND_COMPLETE);

      bSum = (-1 == FindSubString(sumStr,"eventmanager"));
      bCom = (-1 == FindSubString(comStr,"eventmanager") || -1 == FindSubString(penStr,"eventmanager"));

      if (2 == (bSum + bCom)) {
        afLogWarn("MINOR CONFLICTS DETECTED", AF_LOGGROUP_EDS);
        ShowPopup(W3_EDS_CONFLICT, AF_POPUP_MESSAGE_QUESTION);
      } else {
        if (bSum) {
          afLogWarn("MINOR CONFLICT DETECTED", AF_LOGGROUP_EDS);
          ShowPopup(W1_EDS_CONFLICT, AF_POPUP_MESSAGE_QUESTION);
        }
        if (bCom) {
          afLogWarn("MINOR CONFLICT DETECTED", AF_LOGGROUP_EDS);
          ShowPopup(W2_EDS_CONFLICT, AF_POPUP_MESSAGE_QUESTION);
        }
      }
    }

    if (0 < (bDie + bFir + bSum + bCom))
      SetLocalInt(GetModule(), EDS_CHECK_CONFLICT, 2);
    else
      SetLocalInt(GetModule(), EDS_CHECK_CONFLICT, 1);

  }
}

void extraDogSlotInit() {
  string sArea = GetTag(GetArea(GetMainControlled()));
  afLogDebug("Entering Area [" + sArea + "]", AF_LOGGROUP_EDS);

  if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_DOG_RECRUITED)) {

    eds_DogSnapShot();

    if ("arl300ar_fade" == sArea || "cir350ar_fade_weisshaupt" == sArea ||
        "pre211ar_flemeths_hut_int" == sArea || "cam100ar_camp_plains" == sArea || "den211ar_arl_eamon_estate_1" == sArea) {
      removeDog();
      if ("cam100ar_camp_plains" == sArea || "den211ar_arl_eamon_estate_1" == sArea) {
        object oDog = eds_GetPartyPoolMemberByTag(GEN_FL_DOG);
        if (!IsObjectValid(oDog)) {
          // Fix the dog
          oDog = fixBrokenDog();
          if (IsObjectValid(oDog)) {
            WR_SetObjectActive(oDog,TRUE);
            WR_SetFollowerState(oDog, FOLLOWER_STATE_ACTIVE, TRUE);

            // if name is "gen00fl_dog" or "dog", request new name.
            string s_oldname = StringLowerCase(GetName(oDog));
            if ("dog" == s_oldname || "gen00fl_dog" == s_oldname) {
              SetLocalInt(GetModule(), EDS_GET_DOG_NAME, 1);

              // Result of event will go to the OBJECT field (module)
              // as an EVENT_TYPE_POPUP_RESULT. The input string will
              // be reflected as string event parameter 0.
              ShowPopup(362390,2,GetModule(),TRUE);
            }
          }
        }
        afLogDebug("Sending EVENT_MAKE_DOG_CLICKABLE in 1.5 Sec", AF_LOGGROUP_EDS);
        event eMakeClickable = Event(EVENT_MAKE_DOG_CLICKABLE);
        DelayEvent(1.5, GetModule(), eMakeClickable);
      }
    }
    else
    {
      // If they are human noble, add dog when they
      // enter the wilds.
      if ("pre200ar_korcari_wilds" == sArea) {
        int noDogSlot = GetLocalInt(GetModule(),NODOGSLOT);
        if (!noDogSlot) {
          activate_DogSlot(GetHero());
        }
      }
      checkDogSlot();
    }
  }
}

void extraDogSlotPartyPicker() {
  afLogDebug("EVENT_TYPE_PARTYPICKER_CLOSED", AF_LOGGROUP_EDS);
  // Should I care?
  int noDogSlot = GetLocalInt(GetModule(),NODOGSLOT);
  if (!noDogSlot) {
    afLogDebug("NO DOG SLOT is false", AF_LOGGROUP_EDS);
    // Only need to attach if dog is not in party
    if (!isDogInParty()) {
      object oOwner = OBJECT_INVALID;
      string sOwner = getStoredDogOwner();
      if ("" != sOwner) oOwner = eds_GetPartyPoolMemberByTag(sOwner);
      if (IsObjectValid(oOwner)) unAttachDogFromPartyMember(oOwner);
      // This will set NODOGSLOT to FALSE, but it is already false (hense why we got here)...
      // so it doesn't matter.
      activate_DogSlot(GetHero());
    }
  } else {
    afLogDebug("NODOGSLOT is true. Ignoring change of party", AF_LOGGROUP_EDS);
  }
}

