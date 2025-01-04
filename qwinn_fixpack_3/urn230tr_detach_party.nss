//------------------------------------------------------------------------------
// urn230tr_detach_party
// Copyright (c) 2003 Bioware Corp.
//------------------------------------------------------------------------------
//
// Detaches the player's party in preparation for the leap of faith puzzle on
// the entrance side (first time crossed). Re-attachs the party and solves puts
// the puzzle in a solved state on the exit side (second time crossed).
//
//------------------------------------------------------------------------------
// Created By: Grant Mackay
// Created On: May 16, 2008
//------------------------------------------------------------------------------

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "sys_audio_h"

#include "urn_constants_h"
#include "plt_urn230pt_bridge"

#include "achievement_core_h"

void main()
{

    object oThis = OBJECT_SELF;

    event ev = GetCurrentEvent();

    int nEventType = GetEventType(ev);
    int bHandled   = FALSE;

    switch(nEventType)
    {

        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature enters the trigger
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_ENTER:
        {

            int bDoOnce = GetLocalInt(oThis, TRIGGER_DO_ONCE_A);

            if (bDoOnce) break;

            SetLocalInt(oThis, TRIGGER_DO_ONCE_A, TRUE);

            object  oCreature  = GetEventCreator(ev);
            object  oArea      = GetArea(oThis);

            // Attachment or detachment is stored on the first trigger counter.
            int bAttach = GetLocalInt(oThis, TRIGGER_COUNTER_1);

            // Clear the Area variables.
            SetLocalInt(oArea, AREA_COUNTER_1, 0);
            SetLocalInt(oArea, AREA_COUNTER_2, 0);
            SetLocalInt(oArea, AREA_COUNTER_3, 0);

            // Re-attach or detach the player's party
            object [] arParty = GetPartyList(oCreature);
            object oPartyMember;

            int nSize = GetArraySize(arParty);
            int i,j;

            // If the party size is less than 4 the player is entering without a full party.
            for(j = nSize; j < 4; ++j)
            {

                // Collect the next nearest wraith.
                oPartyMember = GetObjectByTag(URN_CR_PUZZLE_WRAITH, (j - nSize));

                // Qwinn - I added this for UR3021.  It used to be below the add to the party,
                // which up to v3.5 made the entire player's inventory non removable.  Oops.
                object[] arInventory = GetItemsInInventory(oPartyMember);
                int nInventorySize = GetArraySize(arInventory);
                int nIndex = 0;
                for (nIndex = 0; nIndex < nInventorySize; nIndex++)
                {
                   object oItem = arInventory[nIndex];
                   SetItemDroppable(oItem,FALSE);
                   SetItemIrremovable(oItem,TRUE);
                }

                // Make the friendly.
                SetGroupId(oPartyMember, GROUP_FRIENDLY);

                // Activate them.
                WR_SetObjectActive(oPartyMember, TRUE);

                // Put them in the player's party.
                UT_HireFollower(oPartyMember);

                // Make sure they don't follow the player.
                SetFollowPartyLeader(oPartyMember, bAttach);

            }

            object oWaypoint;

            for (i = 0; i < nSize; ++i)
            {

                oPartyMember = arParty[i];
                SetFollowPartyLeader(oPartyMember, bAttach);

                if (!bAttach)
                {
                    UT_LocalJump(oPartyMember, URN_WP_BRIDGE_PUZZLE, TRUE );
                    oWaypoint = GetObjectByTag("urn230wp_bridge_party_" + IntToString(i));
                    AddCommand(oPartyMember, CommandMoveToObject(oWaypoint, FALSE), FALSE);
                }

                // Remove any wraiths from the party.
                if (GetTag(oPartyMember) == URN_CR_PUZZLE_WRAITH)
                {
                    UT_FireFollower(oPartyMember, TRUE, FALSE);
                    WR_SetObjectActive(oPartyMember, FALSE);
                }

            }

            // The first time this trigger is crossed as an attach trigger the puzzle is solved.
            if (bAttach)
            {
                object oSection, oBlocker;
                int i;

                for(i = 1; i < 5; ++i)
                {

                    // The bridge section and the invisible object blocking it.
                    oSection = GetObjectByTag(BRIDGE_SECTION_PREFIX + IntToString(i));
                    oBlocker = GetObjectByTag(BRIDGE_BLOCKER_PREFIX + IntToString(i));

                    // Make sure there are no transparencies left on the section.
                    effect [] arEffects = GetEffects(oSection);
                    RemoveEffectArray(oSection, arEffects);

                    // Activate the section and disable the block.
                    SetObjectActive(oSection, TRUE);
                    SetObjectActive(oBlocker, FALSE);

                }

                object oPC = GetHero();

                AudioTriggerPlotEvent( 68 );
                WR_SetPlotFlag(PLT_URN230PT_BRIDGE, URN_BRIDGE_COMPLETED, TRUE);
                UT_Talk(oPC, oPC, URN_DG_PARTY_BRIDGE_HELP);
            }
            // Otherwise the player should get some information about what's going on.
            else
            {

                object    oPC    = GetHero();
                resource  rConv  = R"urn230ip_bridge_puzzle.dlg";

                UT_Talk(oPC, oPC, rConv);

            }

            break;
        }

    }

    if (!bHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_TRIGGER_CORE);
    }
}