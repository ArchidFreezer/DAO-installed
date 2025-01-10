//==============================================================================
/*
    den300pt_some_wicked.nss
*/
//==============================================================================
//  Created By: Ferret
//  Created On: May 27th, 2008
//==============================================================================
//  Modified By: Kaelin
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "sys_audio_h"

#include "den_constants_h"
#include "sys_ambient_h"
#include "sys_traps_h"

#include "plt_cir000pt_main"
#include "plt_gen00pt_class_race_gend"
#include "plt_den300pt_some_wicked"

//------------------------------------------------------------------------------

int LC_JournalClueCheck()
{
    int nCounter;
    if ( WR_GetPlotFlag(PLT_DEN300PT_SOME_WICKED, WICKED_CLUE_BEGGAR) ) nCounter++;
    if ( WR_GetPlotFlag(PLT_DEN300PT_SOME_WICKED, WICKED_CLUE_DEAD_DOG) ) nCounter++;
    if ( WR_GetPlotFlag(PLT_DEN300PT_SOME_WICKED, WICKED_CLUE_FERAL_DOG) ) nCounter++;
    if ( WR_GetPlotFlag(PLT_DEN300PT_SOME_WICKED, WICKED_CLUE_FRESH_BLOOD) ) nCounter++;

    if ( nCounter == 3 )
        WR_SetPlotFlag(PLT_DEN300PT_SOME_WICKED, WICKED_JOURNAL_ALL_CLUES_FOUND, TRUE, TRUE);
    else if ( nCounter > 0 )
        WR_SetPlotFlag(PLT_DEN300PT_SOME_WICKED, WICKED_JOURNAL_MULTIPLE_CLUES_FOUND, TRUE, TRUE);

    return nCounter;
}

int StartingConditional()
{
    event   eParms              =   GetCurrentEvent();              // Contains all input parameters

    int     nType               =   GetEventType(eParms);           // GET or SET call
    int     nFlag               =   GetEventInteger(eParms, 1);     // The bit flag # being affected
    int     nResult             =   FALSE;                          // used to return value for DEFINED GET events

    string  strPlot             =   GetEventString(eParms, 0);      // Plot GUID

    object  oParty              =   GetEventCreator(eParms);        // The owner of the plot table for this script
    object  oConversationOwner  =   GetEventObject(eParms, 0);      // Owner on the conversation, if any
    object  oPC                 =   GetHero();

    object  oGhostChild         =   UT_GetNearestObjectByTag(oPC, DEN_CR_GHOST_CHILD);
    object  oOtto               =   UT_GetNearestObjectByTag(oPC, DEN_CR_LC_OTTO);
    object  oDoor1              =   GetObjectByTag(DEN_IP_DEMON1_DOOR);
    object  oDoor2              =   GetObjectByTag(DEN_IP_DEMON1_DOOR, 1);
    object  oLastDemon          =   UT_GetNearestObjectByTag(oPC, DEN_CR_LC_DEMON_ROW_HOUSE);
    object  oLastDemonBoss      =   UT_GetNearestObjectByTag(oPC, DEN_CR_LC_DEMON_ROW_HOUSEx2);

    effect  eAOE                =   EffectAreaOfEffect( AOE_PLOT_CIR_FADE_FIRE_LARGE, R"cir000ip_fade_fire_base.ncs" );

    object  oTarg;

    plot_GlobalPlotHandler(eParms);                                 // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue      =   GetEventInteger(eParms, 2);             // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue   =   GetEventInteger(eParms, 3);             // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {

            case WICKED_QUEST_ACTIVE:               // DEN300_OTTO
                                                    // You get the quest from Ser Otto
            {

                object  oBloodPool  =   GetObjectByTag(DEN_IP_WICKED_BLOOD_POOL);
                object  oDeadDog    =   GetObjectByTag(DEN_IP_WICKED_DEAD_DOG);

                // He has no more quests
                SetPlotGiver(oOtto, FALSE);

                // Make the Blood Pool and Dead Dog interactive
                SetObjectInteractive(oBloodPool, TRUE);

                SetObjectInteractive(oDeadDog, TRUE);

                break;

            }

            case WICKED_CLUE_BEGGAR:
            {
                // Qwinn:  Check against repeatedly hitting the same clue triggering updates.
                if (nOldValue == 0)
                {
                   // Check to see which journal message to display
                   if ( LC_JournalClueCheck() == 0 )
                   {
                      WR_SetPlotFlag(PLT_DEN300PT_SOME_WICKED, WICKED_JOURNAL_CLUE_BEGGAR, TRUE, TRUE);
                   }
                }
                break;                
            }

            case WICKED_CLUE_DEAD_DOG:
            {
                // Qwinn:  Check against repeatedly hitting the same clue triggering updates.
                if (nOldValue == 0)
                {
                    // Check to see which journal message to display
                    if ( LC_JournalClueCheck() == 0 )
                    {
                        WR_SetPlotFlag(PLT_DEN300PT_SOME_WICKED, WICKED_JOURNAL_CLUE_DEAD_DOG, TRUE, TRUE);
                    }
                }
                break;
                
            }

            case WICKED_CLUE_FERAL_DOG:
            {
                // Qwinn:  Check against repeatedly hitting the same clue triggering updates.
                if (nOldValue == 0)
                {
                    // Check to see which journal message to display
                    if ( LC_JournalClueCheck() == 0 )
                    {
                        WR_SetPlotFlag(PLT_DEN300PT_SOME_WICKED, WICKED_JOURNAL_CLUE_FERAL_DOG, TRUE, TRUE);
                    }
                }
                break;                
            }

            case WICKED_CLUE_FRESH_BLOOD:
            {
                // Qwinn:  Check against repeatedly hitting the same clue triggering updates.
                if (nOldValue == 0)
                {
                    // Check to see which journal message to display
                    if ( LC_JournalClueCheck() == 0 )
                    {
                        WR_SetPlotFlag(PLT_DEN300PT_SOME_WICKED, WICKED_JOURNAL_CLUE_FRESH_BLOOD, TRUE, TRUE);
                    }
                }
                break;                
            }

            case OTTO_GOES_TO_ORPHANAGE:                // Otto runs to the Orphanage door
            {

                object  oDoor   =   UT_GetNearestObjectByTag(oPC, DEN_IP_LC_DOOR_TO_ORPHANAGE);
                object  oWP     =   UT_GetNearestObjectByTag(oPC, DEN_WP_LC_TO_ORPHANAGE);

                // Make the door active now
                SetObjectInteractive(oDoor, TRUE);

                // Make the waypoint appear
                SetMapPinState(oWP, TRUE);

                // Otto heads to the orphanage
                UT_ExitDestroy(oOtto, TRUE, DEN_WP_LC_TO_ORPHANAGE);

                object  oBloodPool  =   GetObjectByTag(DEN_IP_WICKED_BLOOD_POOL);
                object  oDeadDog    =   GetObjectByTag(DEN_IP_WICKED_DEAD_DOG);
                object  oFeralDog   =   GetObjectByTag("den300cr_otto_feral_dog");

                SetObjectInteractive(oBloodPool, FALSE);
                SetObjectInteractive(oDeadDog, FALSE);
                SetObjectInteractive(oFeralDog, FALSE);

                break;

            }

            case OTTO_FOLLOWS_PC:                       // DEN300_OTTO
                                                        // Otto is now following the PC
            {

                object  oArea   =   GetArea(oPC);

                int     bDoOnce =   GetLocalInt(oArea, AREA_DO_ONCE_B);

                // Follow the PC and make him friendly
                AddNonPartyFollower(oOtto);

                SetGroupId(oOtto, GROUP_FRIENDLY);

                if(!bDoOnce)
                {

                    SetLocalInt(oArea, AREA_DO_ONCE_B, TRUE);

                    DoAutoSave();

                }

                // Logic for Otto not leaving the Orphanage, and if the PC leaves and comes back
                // he rejoins.
                // NOTE: This logic is handled with the area script for the orphanage, as well
                // as the transition script outta there.

                break;

            }

            case CHILD_RUNS_FIRST_TIME:                 // The child runs off
            {

                UT_QuickMove(DEN_CR_GHOST_CHILD, "0", TRUE);

                break;

            }

            case CHILD_JUMPS_TO_SECOND_SPOT:            // The child teleports away
            {

                WR_ClearAllCommands(oGhostChild, TRUE);

                UT_LocalJump(oGhostChild, "", TRUE);

                break;

            }

            case CHILD_RUNS_SECOND_TIME:                // The child runs off
            {

                UT_QuickMove(DEN_CR_GHOST_CHILD, "1", TRUE);

                break;

            }

            case CHILD_JUMPS_TO_THIRD_SPOT:             // The child teleports away
            {

                WR_ClearAllCommands(oGhostChild, TRUE);

                UT_LocalJump(oGhostChild, "1", TRUE);

                break;

            }

            case CHILD_RUNS_THIRD_TIME:                 // The child runs off
            {

                UT_QuickMove(DEN_CR_GHOST_CHILD, "2", TRUE);

                break;

            }

            case DEMON_DOORS_EXPLODE:                   // The doors explode, revealing a trap
            {

                object  oDemonDoor1 =   GetObjectByTag(DEN_IP_DEMON_DOOR_AMBUSH, 1);
                object  oDemonDoor2 =   GetObjectByTag(DEN_IP_DEMON_DOOR_AMBUSH);

                //string  sTag        =   UT_GetNearestObjectByTag(DEN_WP_ORPHANAGE_WARDOG_MP);

                // Kill the doors
                SetPlaceableState(oDemonDoor1, PLC_STATE_DOOR_DEAD);

                SetPlaceableState(oDemonDoor2, PLC_STATE_DOOR_DEAD);

                UT_TeamMove(DEN_TEAM_RABID_WARDOG_AMBUSH, DEN_WP_ORPHANAGE_WARDOG_MP, TRUE);

                break;

            }

            case WICKED_ORPHANAGE_DEMON_APPEARS:        // The first demon appears then attacks
            {

                // The demon appears and attacks
                oTarg = UT_GetNearestObjectByTag(oPC, DEN_CR_LC_DEMON_ORPHAN);
                UT_CombatStart(oPC, oTarg);

                // Lock the doors so the PC can't get out of the area
                SetPlaceableState(oDoor1, PLC_STATE_DOOR_LOCKED);
                SetPlaceableState(oDoor2, PLC_STATE_DOOR_LOCKED);

                RemoveNonPartyFollower(oOtto);
                SetImmortal(oOtto, TRUE);

                break;

            }

            case DEMON_ORPHANAGE_SUMMONS_HELP:          // As the Orphanage Demon gets hurt he summons baddies
            {

                /*object oDemon = UT_GetNearestObjectByTag(oPC, DEN_CR_LC_DEMON_ORPHAN);
                object [] oSummonCreatures = UT_GetTeam(DEN_TEAM_ORPHANAGE_DEMON);
                int nSummonCount = GetLocalInt(oArea, AREA_COUNTER_1);
                int nTotalSummon = GetArraySize(oSummonCreatures);
                int nDemonCurrentHP = GetHealth(oDemon);
                int nDemonMaxHP = FloatToInt(GetMaxHealth(oDemon));

                // As the demon takes damage at certain percentage breakpoints more enemies are summoned
                if ( (nDemonCurrentHP/nDemonMaxHP) < ((nTotalSummon-nSummonCount)/nTotalSummon) )
                {
                    // Summoning code
                    if ( oDemon == oSummonCreatures[nSummonCount] ) nSummonCount++;
                    WR_SetObjectActive(oSummonCreatures[nSummonCount], TRUE);

                    nSummonCount++;
                    SetLocalInt(oArea, AREA_COUNTER_1, nSummonCount);
                } */

                break;

            }

            case DEMON_ORPHANAGE_SUMMON_REMAINING_DEMONS:
            {

                // This is meant to summon any remaining demons that slip through the DEMON_ORPHANAGE_SUMMONS_HELP
                // logic.

                //UT_TeamAppears(DEN_TEAM_ORPHANAGE_DEMON);

                break;

            }

            case WICKED_DEMON_KILLED_ONE:               // The first demon is killed
            {

                // Unlock the doors
                SetPlaceableState(oDoor1, PLC_STATE_DOOR_UNLOCKED);
                SetPlaceableState(oDoor2, PLC_STATE_DOOR_UNLOCKED);

                WR_ClearAllCommands(oOtto, TRUE);

                // Otto will initiate conversation.
                UT_Talk(oOtto, oPC);

                break;

            }

            case OTTO_DYING_AT_ORPHANAGE:
            {

                break;

            }

            case OTTO_DEAD_AT_ORPHANAGE:                // Otto dies at the end of his dying speech
            {

                // Kill Ser Otto
                SetImmortal(oOtto, FALSE);

                KillCreature(oOtto);

                break;

            }

            case OTTO_GOES_TO_SLUM_HOUSE:
            {

                // Otto is added to the party again, and is set to be mortal.
                WR_ClearAllCommands(oOtto, TRUE);

                SetImmortal(oOtto, FALSE);

                AddNonPartyFollower(oOtto);

                break;

            }

            case WICKED_DEMON_CONFRONTATION_ONE:        // Otto starts talking with the first demon
            {

                // Reveal the demon boss's map note
                object oTarg = GetObjectByTag(DEN_WP_ORPHAN_DEMON_BOSS);
                SetMapPinState(oTarg, TRUE);

                // Have to activate the end boss, otherwise the cutscene doesn't play well
                WR_SetObjectActive(oLastDemon, TRUE);

                break;

            }

            case WICKED_SLUM_HOUSE_FIRST_FIGHT:         // The demon materializes and fights
            {

                UT_CombatStart(oPC, oLastDemon);

                break;

            }

            case WICKED_SLUM_HOUSE_CONFRONTATION:       // Otto starts talking with the disembodied demon
            {

                // Close the door
                oTarg = GetObjectByTag(DEN_IP_DEMON2_DOOR);
                SetPlaceableState(oTarg, PLC_STATE_DOOR_LOCKED);

                break;

            }

            case WICKED_SLUM_HOUSE_FALSE_ENDING:        // Everything seems good - initialize conversation
            {

                WR_SetObjectActive(oLastDemonBoss, TRUE);

                UT_Talk(oOtto, oPC);

                break;

            }

            case WICKED_SLUM_HOUSE_FINAL_FIGHT:         // Otto is killed (ideally in a surprising and graphic manner
                                                        // Then the PC fights the final demon
            {

                event   evFight =   Event(EVENT_TYPE_CUSTOM_EVENT_08);

                // Activate the traps.
                UT_TeamAppears(DEN_TEAM_ORPHANAGE_LAST_BOSS_TRAPS, TRUE, OBJECT_TYPE_PLACEABLE);

                object  oOwner      =   UT_GetNearestObjectByTag(oPC, DEN_CR_LC_DEMON_ROW_HOUSEx2);

                object  oArea       =   GetArea(oPC);
                object [] arTraps   =   GetTeam(DEN_TEAM_ORPHANAGE_LAST_BOSS_TRAPS, OBJECT_TYPE_PLACEABLE);
                int     nTeamSize   =   GetArraySize(arTraps);
                int     nIndex;

                // Arm the traps in the area.
                for(nIndex = 0; nIndex < nTeamSize; nIndex++)
                {

                    Trap_ArmTrap(arTraps[nIndex], oOwner, 0.0f);//, FALSE);  CMG 1/29/09 - Commented out to stop build breakage.

                }

                UT_CombatStart(oLastDemonBoss, oPC);

                KillCreature(oOtto);

                object [] arFire   = UT_GetAllObjectsInAreaByTag(DEN_IP_ORPHANAGE_FIRE_BASE, OBJECT_TYPE_PLACEABLE);
                int nFire   = GetArraySize(arFire);
                int nLoop;

                // Block off the doors.
                // Fire base and AOE was stolen from Josh. I am sneaky.
                for(nLoop = 0; nLoop < nFire; nLoop++)
                {

                    ApplyEffectOnObject( EFFECT_DURATION_TYPE_PERMANENT, eAOE, arFire[nLoop], 0.0f, arFire[nLoop] );
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, EffectVisualEffect(4005), arFire[nLoop], 0.0f, arFire[nLoop] );

                }


                // The quest closes when the demon's team is killed (handled in the area scripts)
                break;

            }

            case WICKED_QUEST_DONE:                     // After the demon is dead this flag is fired
            {

                // Unlock the door
                oTarg = GetObjectByTag(DEN_IP_DEMON2_DOOR);
                SetPlaceableState(oTarg, PLC_STATE_DOOR_UNLOCKED);


                object [] arFire   = UT_GetAllObjectsInAreaByTag(DEN_IP_ORPHANAGE_FIRE_BASE, OBJECT_TYPE_PLACEABLE);
                int nFire   = GetArraySize(arFire);
                int nLoop;

                for(nLoop = 0; nLoop < nFire; nLoop++)
                {

                    RemoveVisualEffect(arFire[nLoop], 4005);
                    RemoveEffectsByCreator(arFire[nLoop]);

                }

                // De-activate all the traps.
                UT_TeamAppears(DEN_TEAM_ORPHANAGE_LAST_BOSS_TRAPS, FALSE, OBJECT_TYPE_PLACEABLE);

                AudioTriggerPlotEvent(DEN_AUDIO_ORPHANAGE);

                //percentage complete plot tracking
//                ACH_TrackPercentageComplete(ACH_FAKE_BLIGHT_7);

                break;

            }

            case WICKED_BEGGAR_GIVEN_AMULET:            // DEN300_OTTO_BEGGAR
                                                        // The beggar is given her amulet
            {

                // So remove the amulet from the PC's inventory

                UT_RemoveItemFromInventory(DEN_IM_BEGGAR_AMULET);

                break;

            }

        }

     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case PC_DOESNT_KA_MALEFICAR:                // DEN300_OTTO
                                                        // Check to see if the PC would reasonably not know about
                                                        // the maleficar.
            {

                int bCondition1 = WR_GetPlotFlag( PLT_CIR000PT_MAIN, BROKEN_CIRCLE_PLOT_DONE );
                int bCondition2 = WR_GetPlotFlag( PLT_GEN00PT_CLASS_RACE_GEND, GEN_CLASS_MAGE );

                nResult = !bCondition1 && !bCondition2;

                break;

            }

            case WICKED_DONE_EITHER_OUTCOME:
            {

                int bCondition1 = WR_GetPlotFlag( PLT_DEN300PT_SOME_WICKED, WICKED_QUEST_DONE);
                int bCondition2 = WR_GetPlotFlag( PLT_DEN300PT_SOME_WICKED, OTTO_DEAD_AT_ORPHANAGE);

                nResult = bCondition1 || bCondition2;

                break;

            }

        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}