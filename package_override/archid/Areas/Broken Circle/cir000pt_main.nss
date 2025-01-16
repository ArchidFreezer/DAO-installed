//==============================================================================
/*
    This handles the main generic plots.
*/
//==============================================================================
//  Created By: Ferret
//  Created On: December 8th, 2006
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "cutscenes_h"

#include "cir_constants_h"

#include "plt_cir_area_jumps"
#include "plt_gen00pt_party"
#include "plt_gen00pt_class_race_gend"
#include "plt_cir000pt_litany"
#include "plt_cir000pt_main"
#include "plt_mnp000pt_main_events"
#include "plt_mnp000pt_autoss_main"
#include "plt_cir300pt_fade"

#include "plt_arl200pt_remove_demon"

#include "plt_cod_cha_greagoir"
#include "plt_cod_cha_irving"
#include "plt_cod_cha_wynne"

#include "plt_gen00pt_skills"

#include "sys_audio_h"

#include "achievement_core_h"

#include "sys_ambient_h"

// Qwinn added
#include "plt_genpt_morrigan_main"
// Merchant Scaling
#include "scalestorefix_h"
//------------------------------------------------------------------------------

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

    object  oTarg;

    plot_GlobalPlotHandler(eParms);                         // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT)                        // actions -> normal flags only
    {
        int nValue      =   GetEventInteger(eParms, 2);             // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue   =   GetEventInteger(eParms, 3);             // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            //This happens when the player is ready to go into the tower
            case ARGUMENT_AGREED_WITH_TEMPLARS:
            {
                object oDoor = GetObjectByTag(CIR_IP_GREAGOIR_DOOR);
                //Unlock the door
                SetPlaceableState(oDoor, PLC_STATE_DOOR_UNLOCKED);
                //take an auto screenshot for the story so far
                WR_SetPlotFlag( PLT_MNP000PT_AUTOSS_MAIN, AUTOSS_CIR_CIRCLE_OVERRUN, TRUE, TRUE );

                break;
            }

            case RUMOUR_MER_OPEN_STORE:
            {
                object oStore;

                //Open a different store based on where the player is in the plots.
                if(WR_GetPlotFlag(PLT_CIR000PT_MAIN, MAGES_IN_ARMY, FALSE) == TRUE)
                {
                    //Open mages ending store
                    oStore = GetObjectByTag(CIR_RUMOUR_MAGES);
                }

                else if(WR_GetPlotFlag(PLT_CIR000PT_MAIN, TEMPLARS_IN_ARMY, FALSE) == TRUE)
                {
                    //Open templar ending store
                    oStore = GetObjectByTag(CIR_RUMOUR_TEMPLAR);
                }

                else
                {
                    //Open regular store
                    oStore = GetObjectByTag(CIR_RUMOUR_DEFAULT);
                }

                ScaleStoreEdited(oStore); // Merchant Scaling

                OpenStore(oStore); //Open the store

                break;
            }

            case BROKEN_CIRCLE_PLOT_DONE:

            {
                // Increase the main plot counter
                if(nOldValue == 0)
                    WR_SetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, PLAYER_FINISHED_A_MAJOR_PLOT, TRUE, TRUE);

                // Remove plot items we've finished with.
                UT_RemoveItemFromInventory(CIR_IM_LITANY);

                break;
            }


            case TEMPLARS_IN_ARMY:
            {
                // Grant achievement for siding with templars
                WR_UnlockAchievement(ACH_DECISIVE_ANNULMENT_INVOKER);

                //Set the broken circle plot as done
                WR_SetPlotFlag( PLT_CIR000PT_MAIN, BROKEN_CIRCLE_PLOT_DONE, TRUE, TRUE);

                //Set irving codex update
                // Qwinn:  This was getting set even if Irving surrendered to the Templars.
                if(WR_GetPlotFlag(PLT_CIR000PT_MAIN, IRVING_SURRENDERS, TRUE) == TRUE)
                {
                   WR_SetPlotFlag(PLT_COD_CHA_IRVING, COD_CHA_IRVING_SURVIVES , TRUE, TRUE);
                }
                else
                {
                   WR_SetPlotFlag(PLT_COD_CHA_IRVING, COD_CHA_IRVING_DIES, TRUE, TRUE);
                }


                //Set greigor codex update
                WR_SetPlotFlag(PLT_COD_CHA_GREAGOIR, COD_CHA_GREAGOIR_MAGES_KILLED, TRUE, TRUE);

                //Save the game.
                DoAutoSave();

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BLIGHT_2b);

                break;
            }

            case MAGES_IN_ARMY:
            {
                // Grant achievement for siding with mages
                WR_UnlockAchievement(ACH_DECISIVE_MAGIC_SYMPATHIZER);

                //Set the broken circle plot as done.
                WR_SetPlotFlag( PLT_CIR000PT_MAIN, BROKEN_CIRCLE_PLOT_DONE, TRUE, TRUE);

                //Set irving codex update
                WR_SetPlotFlag(PLT_COD_CHA_IRVING, COD_CHA_IRVING_QUOTE_ALL_OTHERS, TRUE, TRUE); //I've given this to mages too as it seems appropate
                WR_SetPlotFlag(PLT_COD_CHA_IRVING, COD_CHA_IRVING_SURVIVES, TRUE, TRUE);

                //Save the game
                DoAutoSave();

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BLIGHT_2a);

                break;
            }

            case TO_TOWER:                      // CIR100_CARROLL
                                                //Plays Into Tower cutscene
            {
                CS_LoadCutscene(CUTSCENE_CIR_INTO_TOWER, PLT_CIR000PT_MAIN, ENTERED_TOWER);

                break;
            }


            case ENTERED_TOWER:                 // Set after "Into the Tower" cutscene plays
                                                // The PC is transported to the tower now.
            {
                // Teleport the PC
                UT_DoAreaTransition( CIR_AR_TOWER_FIRST_FLOOR,CIR_WP_TOWER_START);

                break;
            }

            case GREAGOIR_CLOSES_DOOR:
            {
                CS_LoadCutscene(R"cir200_door_closes.cut", PLT_CIR000PT_MAIN, GREAGOIR_CLOSES_DOOR_CS_END);
                object oDoor = GetObjectByTag(CIR_IP_GREAGOIR_DOOR);
                SetPlaceableState(oDoor,PLC_STATE_DOOR_LOCKED);
                //Jump party for after cutscene as it was causing an issue if they didn't move
                UT_LocalJump(oPC, CIR_WP_DOOR_CLOSES, TRUE, FALSE, TRUE, TRUE);
                break;
            }

            case GREAGOIR_CLOSES_DOOR_CS_END:
            {
               DoAutoSave();

               break;
            }
            case WYNNE_INTRO_COMPLETE:
            {
                CS_LoadCutscene(CUTSCENE_CIR_WYNNES_INTRO, "", -1, GEN_FL_WYNNE);

                break;
            }

            case WYNNE_HELPED:                  // H_WYNNE
                                                // Wynne has been helped. She joins the party.
            {
                // Wynne joins the party
                WR_SetPlotFlag( PLT_GEN00PT_PARTY, GEN_WYNNE_RECRUITED, TRUE, TRUE);

                break;
            }


            case WYNNE_ATTACKS:                  // H_WYNNE
                                                // Wynne goes hostile
            {

                object [] arKids = UT_GetTeam(CIR_TEAM_MAGE_KIDS);
                int iKid;

                for(iKid = 0; iKid < GetArraySize(arKids); iKid++)
                {
                    //Make the kids run for their lives
                    UT_ExitDestroy(arKids[iKid], TRUE, CIR_WP_KIDS_ESCAPE);
                }
                object oMainKid = GetObjectByTag(CIR_CR_KID);

                //Make the kid talk
                UT_Talk(oMainKid, oMainKid);

                object oWynne = GetObjectByTag(GEN_FL_WYNNE);

                //Put Wynne in her hostile group
                SetTeamId(oWynne, CIR_TEAM_WYNNE_HOSTILE);

                //And make her and her lackies go hostile
                UT_TeamGoesHostile(CIR_TEAM_WYNNE_HOSTILE,TRUE);

                break;
            }


            case WYNNE_KILLED:                  // H_WYNNE
                                                // Wynne goes hostile and attacks the PC
            {
                WR_SetObjectActive( GetObjectByTag(CIR_IP_WYNNE_BARRIER),FALSE);

                // destroy floor trigger too
                WR_SetObjectActive( GetObjectByTag(CIR_TR_WYNNE_BARRIER),FALSE);

                //Set her plot flag
                WR_SetPlotFlag(PLT_COD_CHA_WYNNE, COD_CHA_WYNNE_KILLED, TRUE, TRUE);

                break;
            }


            case WYNNE_BARRIER_REMOVED:         // H_WYNNE
                                                // Wynne removes the barrier she set up
            {
                //Wynne removes the barrier she set up
                object oBarrier = GetObjectByTag(CIR_IP_WYNNE_BARRIER);
                DelayEvent(0.5, oBarrier, Event(EVENT_TYPE_CUSTOM_EVENT_01)); //Get the barrier to disable itself

                break;
            }

            case FALLBACK_REMOVE_WYNNE_BARRIER:
            {
                //Fallback if the delay event fails
                object oBarrier = GetObjectByTag(CIR_IP_WYNNE_BARRIER);
                SignalEvent(oBarrier, Event(EVENT_TYPE_CUSTOM_EVENT_02)); //Get the barrier to disable itself
                break;
            }


            case WYNNE_DOESNT_JOIN:             // CIR200_GREAGOIR
                                                // Wynne doesn't join yet
            {
                // Wynne goes into the corner, doesn't join the PC.
                oTarg = GetObjectByTag(GEN_FL_WYNNE);

                //Remove her from the team
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_RECRUITED, FALSE, TRUE);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_CAMP, FALSE);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_PARTY, FALSE);

                WR_SetObjectActive(oTarg, TRUE);

                WR_SetFollowerState(oTarg, FOLLOWER_STATE_INVALID);

                UT_QuickMoveObject(oTarg, CIR_WP_WYNNE_TO_CORNER);

                // Clear the Recruited flag - because she hasn't been successfully recruited yet
                WR_SetPlotFlag( PLT_GEN00PT_PARTY, GEN_WYNNE_RECRUITED, FALSE);

                break;
            }

            case BLOOD_MAGES_1_ATTACK:          // CIR210_BLOOD_MAGE01
                                                // The Blood mages attack the player
            {
                UT_TeamGoesHostile(CIR_TEAM_BLOOD_MAGES_L2, TRUE);

                break;
            }

            case BLOOD_MAGE_1_GOES_TO_PC_CAMP:  // CIR210_BLOOD_MAGE02
                                                // The Blood Mage is recruited and goes to camp
            {
                // The blood mage goes to the PC camp
                oTarg = GetObjectByTag(CIR_CR_BLOOD_MAGE_1_2);

                WR_DestroyObject(oTarg);

                break;
            }


            case BLOOD_MAGE_1_SPARED:           // CIR210_BLOOD_MAGE02
                                                // The Blood Mage is spared and she goes away
            {
                // The blood mage runs off
                oTarg = GetObjectByTag(CIR_CR_BLOOD_MAGE_1_2);

                WR_DestroyObject(oTarg);

                break;
            }


            case BLOOD_MAGE_1_KILLED:           // CIR210_BLOOD_MAGE02
                                                // The Blood Mage is killed
            {
                oTarg = GetObjectByTag(CIR_CR_BLOOD_MAGE_1_2);

                //She goes hostile
                 UT_CombatStart(oTarg, oPC);

                 break;
            }


            case ALL_MAGES_DEAD:                // CIR240_ULDRED
                                                // All of the mages are dead (including Irving)
            {
                WR_SetPlotFlag(PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_CIRCLE_MAGES_JUST_KILLED, TRUE, TRUE);
                break;
            }


            case ULDRED_SITUATION_RESOLVED:     // Various
                                                // The player and other people are teleported over to Greagoir
                                                // to talk with him.
            {
                oTarg = GetObjectByTag(CIR_CR_GREAGOIR);
                UT_Talk(oTarg, oPC);
                break;
            }


            case ULDRED_ATTACKS:                // CIR240_ULDRED
                                                // Uldred and minions attack
            {
                object oUldredHuman = GetObjectByTag(CIR_CR_ULDRED_HUMAN);
                ApplyEffectVisualEffect(oUldredHuman, oUldredHuman, SHAPESHIFT_TRANSFORM_EFFECT_OUT, EFFECT_DURATION_TYPE_TEMPORARY, 1.0);
                DelayEvent(1.0, oUldredHuman, Event(EVENT_TYPE_CUSTOM_EVENT_02)); //Fire event for transform

                //Make the barriers appear
                UT_TeamAppears(CIR_TEAM_ULDRED_BARRIER, TRUE, OBJECT_TYPE_PLACEABLE);

                //Set area transision to non interactive
                object oTrans = UT_GetNearestObjectByTag(oPC, CIR_IP_FOURTH_FLOOR_TRANS);
                WR_SetObjectActive(oTrans, TRUE);
                SetObjectInteractive(oTrans, FALSE);

                //Set teams hostile.
                UT_TeamGoesHostile(CIR_TEAM_ULDRED);
                UT_TeamGoesHostile(CIR_TEAM_ULDRED_MAGES);

                int i;

                if(GetGameDifficulty() < GAME_DIFFICULTY_HARD)
                {
                    //Remove explosive from starting Abominations if the game difficuly is normal or easy
                    object [] arUldredTeam = UT_GetTeam(CIR_TEAM_ULDRED);
                    int iNumDemons = GetArraySize(arUldredTeam);
                    object oCurrent;
                    for(i = 0; i < iNumDemons; i++)
                    {
                        oCurrent = arUldredTeam[i];
                        if(HasAbility(oCurrent, ABILITY_TRAIT_EXPLOSIVE))
                        {
                            RemoveAbility(oCurrent, ABILITY_TRAIT_EXPLOSIVE);
                        }
                    }
                }

                //Set mages to immortal
                object [] arMages = UT_GetTeam(CIR_TEAM_ULDRED_SACRIFICE);
                int iNumMages = GetArraySize(arMages);

                for(i = 0; i < iNumMages; i++)
                {
                    SetImmortal(arMages[i], TRUE);
                }

                //Disabled this line as it seems to be causing issues #136203
                DoAutoSave(); //Save before the fight, shouldn't be in conversation or combat mode.
                break;

            }

            case PC_STAYS_IN_HARROWING_ROOM:
            {
                object oIrving = UT_GetNearestObjectByTag(oPC, CIR_CR_IRVING_FOURTH_FLOOR);

                // If Irving is alive, he talks. Otherwise Cullen appears and talks
                if ( !IsInvalidDeadOrDying(oIrving) && GetObjectActive(oIrving) == TRUE )
                {
                    Ambient_Stop(oIrving);
                }

                break;
            }


            case ULDRED_DEAD:                // CIR240_ULDRED
                                                // Uldred defeated
            {
                UT_TeamGoesHostile(CIR_TEAM_ULDRED_MAGES,FALSE);

                WR_SetPlotFlag(PLT_CIR000PT_LITANY, PC_HAS_FINISHED_LITANY, TRUE, TRUE);

                WR_SetPlotFlag(PLT_CIR300PT_FADE, REMOVE_LOST_IN_DREAMS_MAP_NOTE, TRUE, TRUE);

                //Open area transision
                object oTrans = UT_GetNearestObjectByTag(oPC, CIR_IP_FOURTH_FLOOR_TRANS);
                SetObjectInteractive(oTrans, TRUE);
                UT_TeamAppears(CIR_TEAM_ULDRED_BARRIER, FALSE, OBJECT_TYPE_PLACEABLE);


                object oWynne = GetObjectByTag(GEN_FL_WYNNE);

                if(IsPartyMember(oWynne))
                {
                    //Unlock Wynne if she is in party
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_PARTY, TRUE, TRUE);
                }

                //All the other mages expire

                object oCurrentMage = GetObjectByTag(CIR_CR_MAGE1);
                SetImmortal(oCurrentMage, FALSE);
                KillCreature(oCurrentMage);

                oCurrentMage = GetObjectByTag(CIR_CR_MAGE2);
                SetImmortal(oCurrentMage, FALSE);
                KillCreature(oCurrentMage);

                oCurrentMage = GetObjectByTag(CIR_CR_MAGE3);
                SetImmortal(oCurrentMage, FALSE);
                KillCreature(oCurrentMage);

                oCurrentMage = GetObjectByTag(CIR_CR_MAGE4);
                SetImmortal(oCurrentMage, FALSE);
                KillCreature(oCurrentMage);

                object oIrving = UT_GetNearestObjectByTag(oPC, CIR_CR_IRVING_FOURTH_FLOOR);

                // If Irving is alive, he talks. Otherwise Cullen appears and talks
                if ( !IsInvalidDeadOrDying(oIrving) && GetObjectActive(oIrving) == TRUE )
                {
                    //Ambient_Stop(oIrving);
                    SetPlotGiver(oIrving, TRUE);

                    //Ambient_OverrideBehaviour(oIrving, /*Wounded*/ 17, -1.0, -1);
                    //UT_Talk(oIrving, oPC);
                }
                else
                {
                    //All the mages should be dead so set ALL_MAGES_DEAD to true
                    WR_SetPlotFlag(PLT_CIR000PT_MAIN, ALL_MAGES_DEAD, TRUE, TRUE);

                    oTarg = UT_GetNearestCreatureByTag(oPC, CIR_CR_CULLEN);

                    WR_SetObjectActive(oTarg, TRUE);

                    UT_Talk(oTarg, oPC);
                }

                //Audio triggers for the effects
                AudioTriggerPlotEvent(CIR_AUDIO_TOGGLE_ULDRED_DIES_TOWER); //Hit this as soon as he has died

                break;

            }


            case CULLEN_APPEARS_AT_HARROWING:   // CIR240_IRVING
                                                // Cullen appears
            {
                // Cullen appears in the post-battle scene
                oTarg = UT_GetNearestObjectByTag(oPC, CIR_CR_CULLEN);

                WR_SetObjectActive(oTarg, TRUE);

                break;
            }


            case BROKEN_CIRCLE_BREAKS_BY_PC_BLOOD_MAGE:
                                                // CIR200_GREAGOIR
                                                // The PC is accused of being a blood mage.
                                                // Everyone in the room attacks, including Wynne.
            {


                // Clear the Recruited flag
                //Remove her from the team
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_RECRUITED, FALSE, TRUE);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_CAMP, FALSE);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_PARTY, FALSE);

                // Wynne leaves the party
                oTarg = GetObjectByTag(GEN_FL_WYNNE);
                SetTeamId(oTarg,CIR_TEAM_WYNNE_HOSTILE);
                WR_SetFollowerState(oTarg, FOLLOWER_STATE_INVALID);
                SetImmortal(oTarg, FALSE);
                WR_SetObjectActive(oTarg, TRUE);

                //Cullen setup
                oTarg = GetObjectByTag(CIR_CR_CULLEN);
                SetImmortal(oTarg, FALSE);
                SetTeamId(oTarg,CIR_TEAM_WYNNE_HOSTILE);

                oTarg = GetObjectByTag(CIR_CR_GREAGOIR);
                SetImmortal(oTarg, FALSE);
                SetTeamId(oTarg,CIR_TEAM_WYNNE_HOSTILE);

                oTarg = GetObjectByTag(CIR_CR_QUARTERMASTER);
                SetImmortal(oTarg, FALSE);
                SetTeamId(oTarg,CIR_TEAM_WYNNE_HOSTILE);

                oTarg = GetObjectByTag(CIR_CR_TEMPLAR, 1);
                SetImmortal(oTarg, FALSE);
                SetTeamId(oTarg,CIR_TEAM_WYNNE_HOSTILE);

                oTarg = GetObjectByTag(CIR_CR_TEMPLAR);
                SetTeamId(oTarg,CIR_TEAM_WYNNE_HOSTILE);

                oTarg = GetObjectByTag(CIR_CR_IRVING);
                SetImmortal(oTarg, FALSE);
                SetTeamId(oTarg,CIR_TEAM_WYNNE_HOSTILE);

                UT_TeamGoesHostile(CIR_TEAM_WYNNE_HOSTILE,TRUE);

                //Make Greagoir go hostile.
                UT_TeamGoesHostile(CIR_TEAM_GREAGOIR, TRUE);

                //Make templars go hostile
                UT_TeamGoesHostile(CIR_TEAM_OTHER_TEMPLARS, TRUE);

                //Player can no longer seek the circle's help in Arl Eamon
                WR_SetPlotFlag(PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_CIRCLE_MAGES_JUST_KILLED, TRUE, TRUE);

                //Ambient mages aren't there
                WR_SetObjectActive(GetObjectByTag(CIR_CR_THANKFUL_MAGE), FALSE);
                WR_SetObjectActive(GetObjectByTag(CIR_CR_THANKFUL_MAGE_2), FALSE);

                //Templars aren't there either
                UT_TeamAppears(CIR_TEAM_POST_TEMPLAR, FALSE);

                //Children aren't there
                UT_TeamAppears(CIR_TEAM_MAGE_KIDS, FALSE);

                //Wounded mage shouldn't appear
                WR_SetObjectActive(GetObjectByTag(CIR_CR_WOUNDED_MAGE), FALSE);
                WR_SetObjectActive(GetObjectByTag(CIR_TR_WOUNDED_AMBIENT_2), FALSE);

                break;
            }


            case GREAGOIR_BOWS_OUT:             // CIR200_GREAGOIR
                                                // Greagoir takes a backseat to Irving.
            {
                // Greagoir goes into his corner.
                oTarg = GetObjectByTag(CIR_CR_GREAGOIR);

                UT_LocalJump(oTarg, "200");

                break;
            }


            case GREAGOIR_DIES:                 // CIR200_GREAGOIR
                                                // The player arrives too late at the Broken Circle.
                                                // Greagoir dies after giving his end speech.
            {
                oTarg = GetObjectByTag(CIR_CR_GREAGOIR);

                WR_DestroyObject(oTarg);

                break;
            }


            case PC_GIVES_CARROL_50_GOLD:        // 50G to get to tower

            {
                UT_MoneyTakeFromObject(oPC,0,0,40);

                break;
            }


            //Exit destroy the templars
            case POST_TEMPLAR_EXIT_DESTROY:
            {
                break;
            }

            //Exit destroy the mages
            case POST_MAGES_EXIT_DESTROY:
            {
                break;
            }

            //Set the post plot memorial templar to do his leaving thang.
            case POST_MEMORIAL_TEMPLAR_FINISHES:
            {
                DelayEvent(1.0, GetObjectByTag(CIR_CR_MEMORIAL_TEMPLAR), Event(EVENT_TYPE_CUSTOM_EVENT_01));

                break;
            }

            case SHAMBLING_CORPSES_ATTACK:
            {
                SetPlaceableState(GetObjectByTag(CIR_IP_SHAMBLING_DOOR),PLC_STATE_DOOR_DEAD);

                break;
            }


            case MORRIGAN_ESCAPES:
            {
                /*  Qwinn changed in version 3.5.
                object oMorrigan = Party_GetFollowerByTag(GEN_FL_MORRIGAN);

                WR_SetPlotFlag( PLT_GEN00PT_PARTY, GEN_MORRIGAN_RECRUITED, FALSE);

                WR_DestroyObject(oMorrigan);
                */
                WR_SetPlotFlag(PLT_GENPT_MORRIGAN_MAIN,  MORRIGAN_MAIN_LEAVES_FOR_GOOD, TRUE, TRUE);

                break;
            }

            case IRVING_SURRENDERS:
            {
                //Irving puts the outcome of the mages in the hands of the players and basically has the same logic as
                //all the mages being killed
                UT_TeamAppears(CIR_TEAM_MAGE_KIDS, FALSE);
                UT_TeamAppears(CIR_TEAM_WYNNE_HOSTILE, FALSE);

                WR_SetPlotFlag(PLT_CIR000PT_MAIN, ALL_MAGES_DEAD, TRUE, TRUE); //All the mages are dead (well captured)

                //Set the ambient mages to off
                WR_SetObjectActive(GetObjectByTag(CIR_CR_THANKFUL_MAGE), FALSE);
                WR_SetObjectActive(GetObjectByTag(CIR_CR_THANKFUL_MAGE_2), FALSE);

                break;
            }


            case POST_PLOT:   // After the plot is finished
            {
                if(WR_GetPlotFlag( PLT_COD_CHA_WYNNE, COD_CHA_WYNNE_KILLED)) //Don't give the background if Wynne is killed.
                {
                     WR_SetPlotFlag(PLT_COD_CHA_WYNNE, COD_CHA_WYNNE_BROKEN_CIRCLE, TRUE, TRUE);
                }
                break;
            }


        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case PC_IS_DEMON_CLASS:             // The PC is an Assassin, Reaver, or Blood Made
            {
                int bCondition1, nCounter;

                if (WR_GetPlotFlag( PLT_GEN00PT_CLASS_RACE_GEND, GEN_CLASS_ADV_ASSASSIN)) nCounter++;
                if (WR_GetPlotFlag( PLT_GEN00PT_CLASS_RACE_GEND, GEN_CLASS_ADV_BLOOD_MAGE)) nCounter++;
                if (WR_GetPlotFlag( PLT_GEN00PT_CLASS_RACE_GEND, GEN_CLASS_ADV_REAVER)) nCounter++;

                if ( nCounter > 0 ) bCondition1 = TRUE;
                nResult = bCondition1;

                break;
            }


            case PC_IS_BLOOD_MAGE_AND_WYNNE_IN_PARTY:
                                                // Check to see if the PC is a Blood Mage and Wynne is with the PC.
                                                // The PC is about to get busted.
            {
                int bCondition1 = WR_GetPlotFlag( PLT_GEN00PT_CLASS_RACE_GEND, GEN_CLASS_ADV_BLOOD_MAGE);
                int bCondition2 = WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_WYNNE_IN_PARTY);
                nResult = bCondition1 && bCondition2;

                break;
            }


           case PC_HAS_50_GOLD:
                                                // Check to see if the PC has 40 gold to get to mage tower
                                                //AMOUNT CHANGED TO 40 in DIALOG
            {
                // trmp true until we can get real conditionals
                nResult = UT_MoneyCheck(oPC,0,0,40);

                break;
            }


           case BROKEN_CIRCLE_PLOT_DONE_TOWER_SAVED:
           {
                int bCondition1 = WR_GetPlotFlag(PLT_CIR000PT_MAIN, TEMPLARS_IN_ARMY);
                int bCondition2 = WR_GetPlotFlag(PLT_CIR000PT_MAIN, MAGES_IN_ARMY);

                nResult = bCondition1 || bCondition2;

                break;

           }

           case CARROLL_PERSUADE:
           {
                //Return true if we have already tried to intimidate or pass the persuade check
                WR_SetPlotFlag(PLT_CIR000PT_MAIN, CARROLL_ATTEMPTED_PERSUADE, TRUE);

                int bCondition1 = WR_GetPlotFlag(PLT_CIR000PT_MAIN, CARROLL_ATTEMPTED_INTIMIDATE);
                int bCondition2 = WR_GetPlotFlag(PLT_GEN00PT_SKILLS, GEN_PERSUADE_MED);

                nResult = bCondition1 || bCondition2;
                break;
           }

           case CARROLL_INTIMIDATE:
           {
                //Return true if we have already tried to persuade or pass the intimidate check
                WR_SetPlotFlag(PLT_CIR000PT_MAIN, CARROLL_ATTEMPTED_INTIMIDATE, TRUE);

                int bCondition1 = WR_GetPlotFlag(PLT_CIR000PT_MAIN, CARROLL_ATTEMPTED_PERSUADE);
                int bCondition2 = WR_GetPlotFlag(PLT_GEN00PT_SKILLS, GEN_INTIMIDATE_LOW);

                nResult = bCondition1 || bCondition2;

                break;
           }

        }

    }

    return nResult;
}