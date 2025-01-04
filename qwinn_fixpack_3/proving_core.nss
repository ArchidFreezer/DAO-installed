//==============================================================================
/*

    Paragon of Her Kind
     -> Proving Core Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: February 15, 2007
//==============================================================================

#include "plt_gen00pt_proving"

#include "wrappers_h"
#include "utility_h"
#include "plot_h"
#include "proving_h"
#include "sys_audio_h"



void main()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evCurEvent      = GetCurrentEvent();            // Event parameters
    int     nEventType      = GetEventType(evCurEvent);     // Event type triggered
    object  oEventCreator   = GetEventCreator(evCurEvent);  // Triggering character
    object  oPC             = GetHero();                    // Player

    //--------------------------------------------------------------------------
    // Events
    //--------------------------------------------------------------------------

    switch(nEventType)
    {

        //----------------------------------------------------------------------
        // EVENT_TYPE_PROVING_ENTER
        // Sent By: provings_h (Provings_HandleEvents)
        // When:    PROVING__ENTER is set
        //----------------------------------------------------------------------

        case EVENT_TYPE_PROVING_ENTER:
        {

            //------------------------------------------------------------------
            // This event is sent when the PC enters the Proving Arena. This
            // event should be used to set up what happens when the PC enters.
            //------------------------------------------------------------------

            // Get the current Fight
            int nFightID = Proving_GetCurrentFightId();

            // Heal Player/Party to 100% Hp
            HealPartyMembers(FALSE, TRUE);

            // Store the PC's current party to restore upon exit
            UT_PartyStore();

            // Set up the Proving Fighters
            Proving_SetupFighters(nFightID);

            // Move the PC into the Arena
            WR_ClearAllCommands(oPC);
            UT_LocalJump(oPC, PROVING_WP_PC_ENTER);

            // If there is a valid speaker, have him speak.
            object oSpeaker = Proving_GetDialogCreature(nFightID, EVENT_TYPE_PROVING_ENTER);
            if ( IsObjectValid(oSpeaker) )
            {
                Proving_Log( "EVENT_TYPE_PROVING_ENTER:", "Starting dialog with " + GetTag(oSpeaker)  );
                WR_SetObjectActive(oSpeaker,TRUE);
                UT_Talk(oSpeaker,oPC);
            }

            break;

        }

        //----------------------------------------------------------------------
        // EVENT_TYPE_PROVING_START
        // Sent By: provings_h (Provings_HandleEvents)
        // When:    PROVING__START is set
        //----------------------------------------------------------------------

        case EVENT_TYPE_PROVING_START:
        {

            //------------------------------------------------------------------
            // This event is sent when combat starts for the PC
            //------------------------------------------------------------------

            // Get the current Fight
            int nFightID = Proving_GetCurrentFightId();

            object oSpeaker = Proving_GetDialogCreature(nFightID, EVENT_TYPE_PROVING_START);
            Proving_Log( "EVENT_TYPE_PROVING_START",GetTag(oSpeaker)+" returned");
            if ( IsObjectValid(oSpeaker) )
            {
                WR_SetObjectActive(oSpeaker,TRUE);
                UT_Talk(oSpeaker,oPC);
            }

            //Turn on the crowd sounds
            AudioTriggerPlotEvent(29);


            // Set up the Proving Fighters
            Proving_SetFightersHostile(nFightID);

            break;

        }

        //----------------------------------------------------------------------
        // EVENT_TYPE_PROVING_WIN
        // Sent By: provings_h (Provings_HandleEvents)
        // When:    PROVING__WINis set
        //----------------------------------------------------------------------

        case EVENT_TYPE_PROVING_WIN:
        {

            //------------------------------------------------------------------
            // This event is sent when the PC Wins.
            //------------------------------------------------------------------

            // Get the current Fight
            int nFightID = Proving_GetCurrentFightId();

            //Turn off the crowd sounds
            AudioTriggerPlotEvent(30);

            // If there is a valid speaker, have him speak.
            object oSpeaker = Proving_GetDialogCreature(nFightID, EVENT_TYPE_PROVING_WIN);
            if ( IsObjectValid(oSpeaker) )
            {
                WR_SetObjectActive(oSpeaker,TRUE);
                UT_Talk(oSpeaker,oPC);
            }

            break;

        }

        //----------------------------------------------------------------------
        // EVENT_TYPE_PROVING_LOSE
        // Sent By: provings_h (Provings_HandleEvents)
        // When:    PROVING__LOSE is set
        //----------------------------------------------------------------------

        case EVENT_TYPE_PROVING_LOSE:
        {

            //------------------------------------------------------------------
            // This event is sent when the PC Loses.
            //------------------------------------------------------------------

            // Get the current Fight
            int nFightID = Proving_GetCurrentFightId();

            //Turn off the crowd sounds
            AudioTriggerPlotEvent(30);

            // If there is a valid speaker, have him speak.
            object oSpeaker = Proving_GetDialogCreature(nFightID, EVENT_TYPE_PROVING_LOSE);
            if ( IsObjectValid(oSpeaker) )
            {
                WR_SetObjectActive(oSpeaker,TRUE);
                UT_Talk(oSpeaker,oPC);
            }

            break;

        }

        //----------------------------------------------------------------------
        // EVENT_TYPE_PROVING_EXIT
        // Sent By: provings_h (Provings_HandleEvents)
        // When:    PROVING__EXIT is set
        //----------------------------------------------------------------------

        case EVENT_TYPE_PROVING_EXIT:
        {

            //------------------------------------------------------------------
            // This event is sent when the PC exits the Proving Arena. This
            // event should be used to set up what happens after the PC exits.
            //------------------------------------------------------------------

            // Get the current Fight
            int nFightID = Proving_GetCurrentFightId();

            // Remove all of the fighters for this fight
            Proving_RemoveFighters(nFightID);



            // Remove all gore
            int size, i;
            object [] arParty = GetPartyList(oPC);
            size = GetArraySize(arParty);
            for(i=0;i<size;i++)
                Gore_RemoveAllGore(arParty[i]);

            // Heal Party
            HealPartyMembers(FALSE, TRUE);

            // Move the PC out of the Arena
            WR_ClearAllCommands(oPC);


            //Get player out of combat stance
            if(GetWeaponsUnsheathedStatus(oPC))
                WR_AddCommand(oPC, CommandSheatheWeapons(), TRUE, TRUE);

            // Jump the entire party out of the proving
            UT_LocalJump(oPC, PROVING_WP_PC_EXIT, TRUE, FALSE, FALSE, FALSE);

            // Restore the PC's current party
            UT_PartyRestore();

            // If there is a valid speaker, have him speak.

            object oSpeaker = Proving_GetDialogCreature(nFightID, EVENT_TYPE_PROVING_EXIT);
            // Qwinn - for the Dwarf Noble provings, the event_type_proving_exit entry in
            // the 2DA must be set to the fighter instead of the proving master, because
            // instead of initiating dialogue with the master after each fight, it activates
            // the fighter and you can sometimes see their name float in the arena if you press Tab.
            // Unfortunately, the 2DA for the provings doesn't seem included in the 
            // Source/2DA folder, or I'd edit it there.  So we have to do it here.            
            if ( nFightID == PROVING_FIGHT_004_BDN_BEMOT || 
                 nFightID == PROVING_FIGHT_005_BDN_HELMI ||
                 nFightID == PROVING_FIGHT_006_BDN_BLACKSTONE || 
                 nFightID == PROVING_FIGHT_007_BDN_IVO )
            {
               oSpeaker = Proving_GetDialogCreature(nFightID, EVENT_TYPE_PROVING_START);
            }
            if ( IsObjectValid(oSpeaker) )
            {
                WR_SetObjectActive(oSpeaker,TRUE);
                UT_Talk(oSpeaker,oPC);
            }

            break;

        }

    }
}