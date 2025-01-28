#include "af_eds_include_h"
#include "sys_areabalance"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    switch (nEventType) {
        case EVENT_TYPE_COMMAND_PENDING: {
            int nCommandId       = GetEventInteger(ev, 0);
            if (COMMAND_TYPE_USE_ABILITY == nCommandId) {
                int nCommandSubType  = GetEventInteger(ev, 1);
                switch (nCommandSubType) {
                    case ABILITY_TALENT_NATURE_I_COURAGE_OF_THE_PACK:
                    case ABILITY_TALENT_NATURE_II_HARDINESS_OF_THE_BEAR:
                    case ABILITY_TALENT_SUMMON_SPIDER:
                    case ABILITY_SPELL_ANIMATE_DEAD: {
                        afLogDebug("eds_dheu_event_override : Intercepted Summon Spell Begin. Removing Dog", AF_LOGGING_EDS);
                        object oCaster = GetEventObject(ev, 0);
                        object oDog = OBJECT_INVALID;
                        if (isDogAttached(oCaster)) {
                            oDog = unAttachDogFromPartyMember(oCaster);
                        }
                        break;
                    }
                    case ABILITY_SPELL_SPIDER_SHAPE:
                    case ABILITY_SPELL_FLYING_SWARM:
                    case ABILITY_SPELL_BEAR: {
                        // When they activate a shapechange, it has a
                        // location object. When they disable a shapechange
                        // it does not. However, disabling shapechange does
                        // not break the dog slot.

                        location l1 = GetEventLocation(ev,0);
                        vector pos1 = GetPositionFromLocation(l1);
                        if (0.0 != pos1.x && 0.0 != pos1.y && 0.0 != pos1.z) {
                            afLogDebug("eds_dheu_event_override : Intercepted Summon Spell Begin. Removing Dog", AF_LOGGING_EDS);
                            object oCaster = GetEventObject(ev, 0);
                            object oDog = OBJECT_INVALID;
                            if (isDogAttached(oCaster)) {
                                oDog = unAttachDogFromPartyMember(oCaster);
                            }
                        }
                    }
                    break;
                }
            }
            break;
        }

        case EVENT_TYPE_COMMAND_COMPLETE: {
            int nCommandId       = GetEventInteger(ev, 0);
            if (COMMAND_TYPE_USE_ABILITY == nCommandId) {
                int nCommandSubType  = GetEventInteger(ev, 2);
                switch (nCommandSubType) {
                    case ABILITY_TALENT_NATURE_I_COURAGE_OF_THE_PACK:
                    case ABILITY_TALENT_NATURE_II_HARDINESS_OF_THE_BEAR:
                    case ABILITY_TALENT_SUMMON_SPIDER:
                    case ABILITY_SPELL_ANIMATE_DEAD:
                    case ABILITY_SPELL_SPIDER_SHAPE:
                    case ABILITY_SPELL_FLYING_SWARM:
                    case ABILITY_SPELL_BEAR: {
                        afLogDebug("eds_dheu_event_override : Intercepted Summon Spell End. Re-Adding Dog", AF_LOGGING_EDS);
                        checkDogSlot();
                    }
                    break;
                }
            }
            break;
        }

        case EVENT_TYPE_DYING: {
            object oKiller = GetEventObject(ev, 0);
            object oCreature = OBJECT_SELF;
            object oPC = GetPartyLeader();

            // Extra : Non-Party kills XP
            if (IsObjectValid(oKiller) && TRUE != IsPartyMember(oKiller) && IsObjectHostile(OBJECT_SELF, oPC)) {
                RewardXPParty(0, XP_TYPE_COMBAT, oCreature, oPC);
                if (GetCombatantType(oCreature) != CREATURE_TYPE_NON_COMBATANT) {
                    HandleEvent(ev, AF_RES_SYS_TREASURE);
                }
            }

            // Extra Dog Slot
            //
            // Dog shifts to new owner if owner dies in combat.
            //
            // Notes: Dog Dying event fires first when owner dies, but
            // his death event fires after the owner. The idea is to
            // catch the dying event and revive the dog if he is the
            // last man standing so that combat doesn't end early.
            //
            // There is no way of knowing what the dogs health/stamina was
            // before the event fired, so we simply grant half health
            // on resurrection/transfer to new owner.
            //
            // This should be complimented by an end of combat event
            // so we can fix the dog owner after the party has been
            // resurrected.

            if (IsPartyMember(oCreature)) {
                // afLogDebug("Party member is dying", AF_LOGGING_EDS);
                // PrintEventProperties(ev);

                // Do we care? Only if there are more than 4
                // party members:
                int total = getNumNonSummonedPartyMembers();
                if (total > 4) {
                    // If we can find a dog owner, there
                    // is no need in continueing.
                    object oOwner = getDogOwner();
                    if (FALSE == IsObjectValid(oOwner)) {
                        // OK, something is up. 5 people in
                        // party, but dog doesn't have an owner...

                        if (GetTag(oCreature) == GEN_FL_DOG) {
                            afLogDebug("Party member is Dog", AF_LOGGING_EDS);

                            // To get the new variables to work, I had
                            // to make my own var_module.gda file and
                            // declare my variable names/types.

                            if (GetLocalInt(GetModule(),DOG_BYPASS)) {
                                afLogDebug("ByPass is TRUE. Ignoring Dog Dying event", AF_LOGGING_EDS);
                                SetLocalInt(GetModule(),DOG_BYPASS,FALSE);
                            } else {
                                afLogDebug("ByPass is FALSE. Handling Dog Dying event", AF_LOGGING_EDS);

                                // What is known:
                                // - there are > 4 PM, so the dog should have an owner
                                // - the getDogOwner function returned nothing, so
                                //   case 1: the owner just died and took the dog with it
                                //   case 2: all living NPCs had summons, and there wan't any room for an attachment
                                //   case 3: Dog is the last man standing and he just died.
                                //
                                // - When we scan for a dog owner, on success we store
                                //   the tag in a variable. If that tag has a value,
                                //   then the dog HAD an owner... (case 1). If it
                                //   is empty, then it is case 2 or 3... but case
                                //   2 and 3 do not involve resurrecting/salvaging
                                //   the dog. (We can treat them both the same)

                                string sOwner = getStoredDogOwner();
                                afLogDebug("Stored Owner returned [" +  sOwner + "]", AF_LOGGING_EDS);
                                if ("" != sOwner) {
                                    afLogDebug("Owner died. Handling", AF_LOGGING_EDS);

                                    // case 1: 1 the owner just died and took the dog with it

                                    object oOldOwner = eds_GetPartyPoolMemberByTag(sOwner);
                                    object oDog = unAttachDogFromPartyMember(oOldOwner);
                                    if (IsObjectValid(oDog)) {
                                        // Attempt to re-attach to someone who isn't dead....
                                        attachDogToParty(oDog);
                                    }
                                } else {
                                    // Case 2 or 3.
                                    //
                                    //   Case 2 - There could be party members alive
                                    //   and a summon might have died since our last
                                    //   check. If this is the case, a clickable
                                    //   portrait would be nice.
                                    //
                                    //   Case 3 - Scanning the dead party will be a
                                    //   waste of time. But figuring out if the party
                                    //   is dead or not would take just as much time,
                                    //   so it doesn't hurt to simply scan. (Same
                                    //   implementation as case 2)
                                    //
                                    //   NOTE : We could add a check for
                                    //   EVENT_SUMMON_DIED and handle these scenarios
                                    //   there...

                                    attachDogToParty(oCreature);
                                }
                            }
                        } else {
                            // What is known:
                            // - there are > 4 PM, so the dog should have an owner
                            // - the getDogOwner function returned nothing. It is
                            //   possible that the owner of a dead dog just died.
                            //   If that is the case, we want to move the portrait
                            //   to someone else.

                            string sOwner = getStoredDogOwner();
                            // afLogDebug("Stored Owner returned [" +  sOwner + "]", AF_LOGGING_EDS);
                            if (sOwner ==  GetTag(oCreature)) {
                                object oDog = unAttachDogFromPartyMember(oOwner,FALSE);
                                if (IsObjectValid(oDog)) {
                                    // Attempt to re-attach to someone who isn't dead....
                                    attachDogToParty(oDog);
                                }
                            }
                        }
                    } // if oOwner object is valid
                } // if party size > 4
            } // if isPartyMember(oCreature)
            break;
        }

        case EVENT_TYPE_SUMMON_DIED: {
            object oOwner = OBJECT_SELF;
            int nAbility = GetEventInteger(ev,0);

            // eds_Log("EVENT_TYPE_SUMMON_DIED CAUGHT for [" + GetTag(oOwner) + "]");
            // PrintEventProperties(ev);
            checkDogSlot();
            break;
        }

        case EVENT_TYPE_PARTY_MEMBER_FIRED: {
            // fix for human noble intro.
            string sArea = GetTag(GetArea(GetHero()));
            if ("bhn100ar_castle_cousland" == sArea)
                break;

            // NOTES: When the game removes the party, it pings the current
            // party list and then, the first 3 array entries (list[1] -> list[3]
            // sets party member as being at camp. This happens all at once.
            // THEN, these events start to trickle. So by the time
            // the first event happens, getPartyList will already be returning
            // only the PC and what was previously the 5th party member.
            //
            // MOST the time, the fifth party member array element/was the dog,
            // but sometimes it belongs to someone else. Problem is, when the
            // game restores the other 3 party members, it will destroy the person
            // with the PC, effectively removing that person from the game and
            // possibly breaking the game.
            //
            // SO... Regardless of who the last person is, if we get down
            // to 2 party members, we automaticallly remove the second
            // party member.
            //
            // This code assumes that there are not more than 5 (non-summoned)
            // companions.

            object [] arParty = GetPartyList();
            int nSize = GetArraySize(arParty);
            if (nSize > 1) {
                int total = getNumNonSummonedPartyMembers();
                if (total == 2) {
                    removeDog();

                    // Just in case the last person is not the dog
                    arParty = GetPartyList();
                    nSize = GetArraySize(arParty);

                    int i;
                    for (i = 1; i < nSize; i++) {
                        eds_RemoveParyMember(arParty[i]);
                    }
                }
            }
            break;
        }
    }
}
