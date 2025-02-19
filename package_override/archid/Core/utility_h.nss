#include "log_h"
#include "global_objects_h"
#include "wrappers_h"
#include "rules_h"
#include "sys_rubberband_h"
#include "effect_resurrection_h"
#include "events_h"
#include "ai_constants_h"
#include "stats_core_h"
#include "plt_tut_friendly_aoe"

/** @addtogroup scripting_utility Scripting Utility
*
* Generic level design functions
*/
/** @{*/

//void main() {}

// Attribute checks
const int UT_ATTR_HIGH = 1;
const int UT_ATTR_MED = 2;
const int UT_ATTR_LOW = 3;

//Skill checks
const int UT_SKILL_CHECK_LOW = 1;
const int UT_SKILL_CHECK_MED = 2;
const int UT_SKILL_CHECK_HIGH = 3;
const int UT_SKILL_CHECK_VERY_HIGH = 4;

//Intimidation checks
const int INTIMIDATE_CHECK_VERY_HIGH = 50;
const int INTIMIDATE_CHECK_HIGH = 30;
const int INTIMIDATE_CHECK_MEDIUM = 15;
const int INTIMIDATE_CHECK_LOW = 5;

//Skills
const int SKILL_PERSUADE = ABILITY_SKILL_PERSUADE_1;
const int SKILL_HERBALISM = ABILITY_SKILL_HERBALISM_1;
const int SKILL_POSION = ABILITY_SKILL_POISON_1;
const int SKILL_TRAPS = ABILITY_SKILL_TRAPS_1;
const int SKILL_STEALTH = ABILITY_SKILL_STEALTH_1;
const int SKILL_STEALING = ABILITY_SKILL_STEALING_1;
const int SKILL_SURVIVAL = ABILITY_SKILL_SURVIVAL_1;
const int SKILL_LOCKPICKING = ABILITY_SKILL_LOCKPICKING_1;
const int SKILL_INTIMIDATE = 9;

// Generic exit
const string GENERIC_EXIT = "wp_gen_exit";

const int MAX_CREATURES_IN_AREA = 1000;

// Surrender constants.
const string SURR_SURRENDER_ENABLED = "SURR_SURRENDER_ENABLED";
const string SURR_INIT_CONVERSATION = "SURR_INIT_CONVERSATION";
const string SURR_PLOT_NAME         = "SURR_PLOT_NAME";
const string SURR_PLOT_FLAG         = "SURR_PLOT_FLAG";

const int SURR_STATUS_DISABLED = 0; // The system is disabled.
const int SURR_STATUS_ENABLED  = 1; // System enabled; ready to surrender.
const int SURR_STATUS_ACTIVE   = 2; // System active; currently surrendering.

// World map 'area' ID for area transition system
const string UT_WORLD_MAP = "world_map";


/** @brief Makes someone jump to a specified waypoint within the same area
*
*   This should be used only for area/stage setup - arranging creatures for a certain encounter beforehand.
*   This should NOT be used for any instances in which the user can witness the jump. Note that this function
*   should be used only for jumps within the same area.
* @param oTarg - The object that is going to jump someplace.
* @param sWP - If the string is a # then oTarg will go to "jp_<OBJTAG>_#". If sWP is blank it defaults to 0. If something other than a # is here, then that is the string of the destination waypoint. NOTE: If the waypoint string starts with a number, it will be treated as a number not a string.
* @param nJumpImmediately - If TRUE, forces the jump to the front of the action queue.
* @param bNewHome - By default a creature's new "Home" is updated when you tell them to move someplace. Set this to FALSE if you want to keep their home point as is.
* @param bStaticCommand - the command will not be cleared by a standard WR_ClearAllCommands
* @author Ferret
**/
void UT_LocalJump(object oTarg, string sWP = "", int nJumpImmediately=TRUE, int bNewHome = TRUE, int bStaticCommand = FALSE, int bJumpParty = FALSE);

/** @brief Instantly initiate dialog with 2 objects
*
* Calling this function will instantly trigger dialog between 2 objects. The dialog
* can be ambient or not.
*
* @param oInitiator - The main talking creature - owner of the default dialog file, if any
* @param oTarget    - The creature being spoken to. Should be the player object most of the time
* @returns TRUE on success, FALSE on error
* @author Yaron
*/
void UT_Talk(object oInitiator, object oTarget, resource rConversation = R"", int nPartyResurrection = TRUE);

/** @brief Sets an object to use shouts in his dialog file.
*
* This function sets an object to use shouts whenever dialog is triggered.
* The function sets a variable on the object, that is read and cleared by
* Generic conversation flags. The flags can then be used to flag a shouts tree
* in the conversation.
*
* @param oObject - The object whose shouts flag is being changed
* @param bEnable - TRUE - enable shouts, FALSE - disable
* @sa UT_GetShoutsFlag
* @author Yaron
*/
void UT_SetShoutsFlag(object oObject, int bEnable);

/** @brief Returns the shout flag for an object
*
* brief Returns the shout flag for an object
*
* @param oObject - The object whose shouts flag is being changed
* @param bEnable - TRUE - enable shouts, FALSE - disable
* @returns the shouts flag for the creature (TRUE or FALSE)
* @sa UT_GetShoutsFlag
* @author Yaron
*/
int UT_GetShoutsFlag(object oObject);

/** @brief Forces a creature to stop combat and surrender to the player
*
* Sets a creature to surrender. This includes stopping combat, changing group hostility
* and to fire a one liner conversation (set GEN_SURRENDER_DURING).
* This function also sets the creature to trigger special post-surrender dialog
* after the surrendering if the variables SURR_PLOT_NAME and SURR_PLOT_FLAG
* are set appropriately on the creature.
*
* Implemented Aug 16, 2006, Grant Mackay: No one liner conversation fired;
* straight to surrender dialog.
*
* @param oCreature - The surrendering creature
* @sa UT_SetShoutsFlag
* @author Yaron
*/
void UT_Surrender(object oCreature);

/**
 * @brief Sets up a creature to surrender when they get low on health in combat.
 *
 * Enables the creature to surrender during combat and sets up the surrender
 * plot flag if sepcified.
 *
 * @param oCreature - The surrendering creature.
 * @param bSurrender - Set or un-set the creature's surrender functionality. Default is TRUE.
 * @param InitConversation - Creature will initiate a conversation on surrendering if this is TRUE.
 * @param sPlotName - The name of the plot which should have a flag set as the creature surrenders, if any. Default is empty.
 * @param nPlotFlag - The plot flag to be set as the creature surrenders, if any. The variable is irrelevant if sPlotName is empty.
 *
 * @author Grant
 */
void UT_SetSurrenderFlag(object oCreature, int bSurrender = TRUE, string sPlotName = "", int nPlotFlag = 0, int bInitConversation = TRUE);

/** @brief Checks the attribute level of oObject
*
* This function checks the attribute level of oObject.
* nAttribute should be a constant represneting one of the attributes.
* Notice that an attribute level is dynamic and depends on the player�s level � the
* player will need to keep increasing his attribute in order to keep it in the �high� level.
*
* @param nAttribute - The attribute being checked
* @param nLevel - The level of the attribute being checked (UT_ATTR_HIGH, UT_ATTR_MED or UT_ATTR_LOW)
* @param oCreature - the creature doing the attribute check
* @returns TRUE if the attribute matches the specified level range, FALSE otherwise.
* @author Yaron
*/
int UT_AttributeCheck(int nAttribute, int nLevel, object oCreature = OBJECT_SELF);

/** @brief Hire non-plot follower into the active party for oPC
*
* Hire follower into the active party for oPC. This function will do nothing for plot followers.
*
* @param oFollower - The creature joining the party
* @param bPreventLevelup - whether or not to prevent the follower from levelling up
* @sa FireFollower
* @author Yaron
*/
void UT_HireFollower(object oFollower, int bPreventLevelup = FALSE);

/** @brief Removes a non-plot follower from the active party, sending him back to the party pool
*
* Removes a follower from the active party, sending him back to the party pool. This function will do nothing for plot followers.
*
* @param oFollower - The creature leaving the party
* @param bRemoveFromPool - Remove or not from the party pool
* @sa HireFollower
* @author Yaron
*/
void UT_FireFollower(object oFollower, int bRemoveFromPool = FALSE, int bRemoveEquipment = TRUE);

/** @brief Returns TRUE if the follower is in the active party FALSE otherwise
*
* Returns TRUE if the follower is in the active party FALSE otherwise
* This should be used only for non-plot followers. For plot followers (Alistair, Sten etc') -
* use the plot flags in the global party plot.
*
* @param oFollower - the follower being checked
* @returns TRUE if the follower is in the active party FALSE otherwise
* @sa FireFollower, HireFollower
* @author Yaron
*/
int UT_IsFollowerInParty(object oFollower);

/** @brief Checking to see if oObject has enough skill level for a specific skill
*
* Checking to see if oObject has enough skill level for a specific skill
*
* @param nSkill - the skill being checked
* @param nLevel - the level of the skill being checked
* @param oObject - the creature attempting the skill check
* @returns TRUE if the skill checked succeeded, FALSE otherwise
* @author Yaron
*/
int UT_SkillCheck(int nSkill, int nLevel, object oObject = OBJECT_SELF);

/** @brief Returns the nearest creature
*
* Returns the nearest creature
*
* @param oObject - the object that we try to find a nearest creature from
* @returns the nearest creature to oObject
* @sa UT_GetNearestCreatureByTag, UT_GetNearestObjectByTag, UT_GetNearestCreatureByGroup, UT_GetNearestHostileCreature
* @author Yaron

*/
object UT_GetNearestCreature(object oObject, int nIncludeSelf = FALSE);

/** @brief Returns the nearest creature with a specific tag
*
* Returns the nearest creature with a specific tag
*
* @param oObject - the object that we try to find a nearest creature from
* @param sTag - the tag of the creature we are looking for
* @returns the nearest creature to oObject with the specified tag
* @sa UT_GetNearestCreature, UT_GetNearestObjectByTag, UT_GetNearestCreatureByGroup, UT_GetNearestHostileCreature
* @author Yaron
*/
object UT_GetNearestCreatureByTag(object oObject, string sTag, int nIncludeSelf = FALSE);

/** @brief Returns the nearest creature from a specific group
*
* Returns the nearest creature from a specific group
*
* @param oObject - the object from which we are trying to find a nearest creature from
* @param nGroup - the group of the creature we are looking for
* @returns the nearest creature to oObject from a specific group
* @sa UT_GetNearestCreature, UT_GetNearestCreatureByTag, UT_GetNearestObjectByTag, UT_GetNearestHostileCreature
* @author Yaron
*/
object UT_GetNearestCreatureByGroup(object oObject, int nGroup, int nIncludeSelf = FALSE);

/** @brief Returns the nearest living hostile creature
*
* Returns the nearest living hostile creature
*
* @param oObject - the object from which we are trying to find a nearest creature from
* @param nGroup - the group of the creature we are looking for
* @returns the nearest creature to oObject from a specific group
* @sa UT_GetNearestCreature, UT_GetNearestCreatureByTag, UT_GetNearestObjectByTag, UT_GetNearestCreatureByGroup
* @author Yaron
*/
object UT_GetNearestHostileCreature(object oObject, int nCheckLiving = FALSE);

/** @brief Transitions the entire party to a new area
*
* Jumps the party to sWP. If only sWP is specified then its a local area transition (same area list).
* If sArea and sAreaList are specified then its an area list transition
*
* @param oPlayer - the player whose party we are transitioning
* @param sWP - target wp for the transition
* @param sArea - target area for the transition (only for area list transitions)
* @param sAreaList - target area list for the transition (only for area list transitions)
* @author Yaron
*/
//void UT_AreaTransition(object oPlayer, string sWP, string sArea = "", string sAreaList = "");

/** @brief Transitions the entire party to a new area
*
* Jumps the party to sWP in a different area
*
* @param sArea - target area for the transition
* @param sWP - target wp for the transition
* @param sWorldMapLoc1 - world map location to set active
* @param sWorldMapLoc2 - world map location to set active
* @param sWorldMapLoc3 - world map location to set active
* @author Yaron
*/
void UT_DoAreaTransition(string sArea, string sWP, string sWorldMapLoc1 = "", string sWorldMapLoc2 = "", string sWorldMapLoc3 = "", string sWorldMapLoc4 = "", string nWorldMapLoc5 = "");

/** @brief Makes someone go to the exit and then destroy himself.
*
* @param oTarg - The object that is going to walk someplace.
* @param bRun - Whether the target will walk or run to the exit.
* @param sWP - This is an override string, if left blank oTarg will go to the nearest "wp_gen_exit".
* @param bRandomWait - Adds a short, random length wait command before the move command
* @author Ferret
**/
void UT_ExitDestroy( object oTarg, int bRun = FALSE, string sWP = GENERIC_EXIT, int bRandomWait = FALSE );

/** @brief Clears the entire active party and stores it.
*
*   Clears the entire active party and stores it. The party can then be restored using UT_PartyRestore().
*   The hero character remains in the party.
*
* @sa UT_PartyRestore
* @author Yaron
**/
void UT_PartyStore(int nSetNeutral = FALSE);

/** @brief Restores a party that was cleared using UT_PartyStore
*
*   Restores a party that was cleared using UT_PartyStore.
*
* @sa UT_PartyStore
* @author Yaron
**/
void UT_PartyRestore();

/** @brief Destroys all objects with tag sTag
*
*   This function destroys all objects with tag sTag that are in the same area
*   as the player.
*
* @param sTag - The tag of the objects that will be destroyed
* @author Ferret
**/
void UT_DestroyTag(string sTag);

/** @brief Returns the position of a substring within a string.
*
*   Returns the starting index of the specified instance of the substring sSubstring within the string sString.
*   Returns -1 if the specified instance of the substring does not occur in the string.
*   The search is 0 indexed, so if the substring occurs at the very beginning of the string this function will return 0.
*   'UT_FindSubString("monkey_laser_fun", "_", 2);' would return 12.
*
* @param sString - The string to search.
* @param sSubString - The substring to search for.
* @param nInstance - The instance of the substring to return (default is the first instance).
* @returns Returns the position of the substring, returns -1 on error.
* @author Craig
**/
int UT_FindSubString(string sString, string sSubString, int nInstance = 1);

/** @brief This function quickly moves a creature to a location.
*
*   Moves a creature to the location of the specified waypoint, or along a path if a number is given and bFollowPath is TRUE.
*
*
*
* @param sTag - The tag of the creature that will be moved
* @param sWP - The string of the waypoint it will  move to. By default it is "mp_[sTag]_0". If a number is passed then it moves the object to "_#".
* @param bRun - Indicates whether the creature will walk or run. By default it's walk.
* @param bFollowPath - Uses CommandMoveToMultiLocations. If a numbered waypoint is specified, the creature will move to each waypoint in turn until the specified waypoint is reached.
* @param bNewHome - By default a creature's new "Home" is updated when you tell them to move someplace. Set this to FALSE if you want to keep their home point as is.
* @param bStaticCommand - (for plot critical movements) If this is TRUE the movement commands will be static (not cleared by a standard ClearAllCommands)
* @author Ferret, Craig
**/
void UT_QuickMove(string sTag, string sWP = "0", int bRun = FALSE, int bFollowPath = FALSE, int bNewHome = TRUE, int bStaticCommand = FALSE);

/** @brief This function quickly moves a creature to a location.
*
*   Moves a creature to the location of the specified waypoint, or along a path if a number is given and bFollowPath is TRUE.
*
*
*
* @param oMover - The creature that will be moved
* @param sWP - The string of the waypoint it will  move to. By default it is "mp_[sTag]_0". If a number is passed then it moves the object to "_#".
* @param bRun - Indicates whether the creature will walk or run. By default it's walk.
* @param bFollowPath - Uses CommandMoveToMultiLocations. If a numbered waypoint is specified, the creature will move to each waypoint in turn until the specified waypoint is reached.
* @param bNewHome - By default a creature's new "Home" is updated when you tell them to move someplace. Set this to FALSE if you want to keep their home point as is.
* @param bStaticCommand - (for plot critical movements) If this is TRUE the movement commands will be static (not cleared by a standard ClearAllCommands)
* @author Ferret, Craig
**/
void UT_QuickMoveObject(object oMover, string sWP = "0", int bRun = FALSE, int bFollowPath = FALSE, int bNewHome = TRUE, int bStaticCommand = FALSE);


/** @brief Gets two creature to start combat.
*
* This function starts combat by turning 2 creatures hostile towards each other.
* It is assumed that the perception system will trigger combat once both sides are hostile.
* This function will switch the creature's group to be the 'hostile' group if it's current group is 'non-hostile'
* No other groups will be switched � for these cases the function will just set the 2 groups hostile.
*
* @param oAttacker - The attacking creature or the creature who initiates combat. This will not matter most of the time
* unless we are using the bTargetSelectionOverride parameter.
* @param oTarget - The target creature or the creature who is being attacked. This will not matter most of the time
* unless we are using the bTargetSelectionOverride parameter.
* @param bTargetSelectionOverride - if TRUE this will override the default target selection for the attacker for the first few rounds
* @param nOverridePermanent - if TRUE the attacker will not leave the specified target until it is dead.
* and will force the attacker to target the specified target. Otherwise they will just turn hostile and the AI
* system will decide who attacks who.
* @author Yaron
**/
void UT_CombatStart(object oAttacker, object oTarget, int bTargetSelectionOverride = FALSE, int nOverridePermanent = FALSE);


/** @brief Stops combat between 2 creatures.
*
* This function stops combat by turning 2 creatures non-hostile towards each other.
* The user is responsible for triggering it between any hostile creature towards the player
* or towards other creature. For example: this function will need to be called once for every
* creature that is attacking the player in order to stop combat.
* This function will switch the creature's group to be the 'non hostile group if it's current group is 'hostile'.
* No other groups will be switched � for these cases the function will just set the 2 groups non-hostile.
*
* @param oAttacker - The attacking creature or the creature who initiates combat. This will not matter most of the time
* unless we are using the bTargetSelectionOverride parameter.
* @param oTarget - The target creature or the creature who is being attacked. This will not matter most of the time
* unless we are using the bTargetSelectionOverride parameter.
* @param bTargetSelectionOverride - if TRUE this will override the default target selection for the attacker
* and will force the attacker to target the specified target. Otherwise they will just turn hostile and the AI
* system will decide who attacks who.
* @author Yaron
**/
void UT_CombatStop(object oCreatureA, object oCreatureB);

/** @brief Increments a local integer.
*
* By default this function increments a specified local integer by 1.
*
* @param oObject - Object to store the var on.
* @param sVarName - The name of the integer variable to store.
* @param nIncrement - The amount the integer will be changed by. Default 1.
* @author Ferret
**/
void UT_IncLocalInt(object oObject, string sVarName, int nIncrement = 1);

/** @brief Jumps the PC to a waypoint, checking area first
*
* This function can only be used for the PC because of the area transition.
*
* @param sArea - The string of the area to be checked before jump/transition; also used in transition
* @param sWaypoint - The string of the waypoint to be jumped/transitioned to.
* @param sWorldMapLoc1 - world map location to set active
* @param sWorldMapLoc2 - world map location to set active
* @param sWorldMapLoc3 - world map location to set active
* Logging is covered by UT_LocalJump & UT_DoAreaTransition
* @author Cori
**/
void UT_PCJumpOrAreaTransition(string sArea, string sWP, string sWorldMapLoc1 = "", string sWorldMapLoc2 = "", string sWorldMapLoc3 = "", string sWorldMapLoc4 = "", string sWorldMapLoc5 = "");

/** @brief Returns an array of all team members in the area.
*
* This function searches through all the creatures in the area and returns
* any creature that has it's team set to nTeamID
*
* @param nTeamID - This is the team ID number (stored in CREATURE_TEAM_ID)
* @param nMembersType - The type of members to retrieve (OBJECT_TYPE_CREATURE, OBJECT_TYPE_PLACEABLE)
* @author joshua
**/
object [] UT_GetTeam(int nTeamID, int nMembersType = OBJECT_TYPE_CREATURE );

/** @brief Makes a team appear (they are activated).
*
* This sets SetObjectActive to TRUE for every member of the specified team.
* 0 is not a valid parameter (because that's the default value of the variable).
*
* @param nTeamID - This is the team ID number (stored in CREATURE_TEAM_ID)
* @param bAppears - TRUE or FALSE
* @param nMembersType - The type of members to retrieve (OBJECT_TYPE_CREATURE, OBJECT_TYPE_PLACEABLE)
* @author Ferret
**/
void UT_TeamAppears(int nTeamID, int bAppears = TRUE, int nMembersType = OBJECT_TYPE_CREATURE );

/** @brief Makes a team go hostile.
*
* The specified team joins the hostile faction.
* 0 is not a valid parameter (because that's the default value of the variable).
*
* @param nTeamID - This is the team ID number (stored in CREATURE_TEAM_ID)
* @param bHostile - Default behavior is to turn the team to GROUP_HOSTILE. If this is set to FALSE, then instead the team will turn to GROUP_NEUTRAL.
* @author Ferret
**/
void UT_TeamGoesHostile(int nTeamID, int bHostile = TRUE);

/** @brief Makes a team jump to an object.
**
* @param nTeamID This is the team ID number
* @param sTagDestination The tag of the object the team is going to jump to.
* @param bJumpImmediately Set to TRUE if you want this added to the front of the command queue
* @param bStaticCommand - the command will not be cleared by a standard WR_ClearAllCommands
* @author Craig
**/
void UT_TeamJump(int nTeamID, string sTagDestination = "", int bJumpImmediately = FALSE, int bStaticCommand = FALSE, int bNewHome = FALSE);

/** @brief Makes a team go to an object.
*
* 0 is not a valid parameter (because that's the default value of the variable).
*
* @param nTeamID This is the team ID number
* @param sTagDestination The tag of the object the team is going to move to.
* @param bRun Set to TRUE if you want the team to run there
* @param fRange is the distance from the target the team will stop at
* @param bNewHome Set to TRUE if you want the team to set their home location to the destination.
* @author Ferret
**/
void UT_TeamMove(int nTeamID, string sTagDestination = "", int bRun = FALSE, float fRange = 0.0, int bNewHome = FALSE);

/** @brief Makes a team go to the nearest exit (wp_gen_exit).
*
* 0 is not a valid parameter (because that's the default value of the variable).
*
* @param nTeamID - This is the team ID number (stored in CREATURE_TEAM_ID)
* @param nRun - Set to TRUE if you want the team to run there
* @param sTagOverride - Instead of "wp_gen_exit" they go to this destination.
* @author Ferret
**/
void UT_TeamExit(int nTeamID, int nRun = FALSE, string sTagOverride = GENERIC_EXIT);

/** @brief Kills all the members of a team.
*
* @param nTeam      - The team number to kill.
* @param oKiller    - The killer (OBJECT_INVALID for creatures killed by plot).
* @author Craig
**/
void UT_KillTeam(int nTeam, object oKiller = OBJECT_INVALID);

/** @brief Sets a team to be stationary.
*
*
* @param nTeam - The team number to set stationary.
* @param nStationaryStatus - The stationary status of the team.  AI_STATIONARY_STATE_DISABLED AI_STATIONARY_STATE_SOFT or AI_STATIONARY_STATE_HARD
**/
void UT_SetTeamStationary(int nTeam, int nStationaryStatus);

/** @brief All the members of nTeam join nNewTeam.
*
* @param nTeam - The team merging into nNewTeam.
* @param nNewTeam - The team being joined.
* @param nMembersType - The type of members to retrieve (OBJECT_TYPE_CREATURE, OBJECT_TYPE_PLACEABLE)
* @author Craig
**/
void UT_TeamMerge(int nTeam, int nNewTeam, int nMembersType = OBJECT_TYPE_CREATURE);

/** @brief Sets all the members of a team interractive or not.
*
* @param nTeam - The team number to set interactive.
* @param bInterractive - TRUE or FALSE.
* @param nMembersType - The type of members to retrieve (OBJECT_TYPE_CREATURE, OBJECT_TYPE_PLACEABLE)
* @author Craig
**/
void UT_SetTeamInteractive(int nTeam, int bInterractive, int nMembersType = OBJECT_TYPE_CREATURE);

/** @brief Removes an item from the Player's active inventory
*
* This function removes the given item from inventory by it's resource.
* If nNumToRemove is specified, it will remove that many items from inventory,
* or as many items as it can until no more exist in inventory. This function
* returns the object of the first item stack it creates.
*
* @param rItem - resource of item to remove from inventory
* @param nNumToAdd - Amount of this item to remove from inventory
* @param oInvOwner - Override for applying function to object other than PC
* @returns the object of the first item stack created
* @author joshua
**/
void UT_RemoveItemFromInventory( resource rItem, int nNumToRemove = 1, object oInvOwner = OBJECT_INVALID, string sTag = "");

/** @brief Counts the number of an item in the Player's active inventory
*
* Counts the amount of a given item in inventory by it's resource.
*
* @param rItem - resource of item to check for
* @param oInvOwner - Override for applying function to object other than PC
* @returns The quantity of this item that is currently in the player's inventory
* @author joshua
**/
int UT_CountItemInInventory( resource rItem, object oInvOwner = OBJECT_INVALID, string sTag ="" );

/** @brief Adds an item to the Player's active inventory
*
* This fucntion adds the given item from inventory by it's resource.
* If nNumToAdd is specified, it will add that many items to inventory.
*
* @param nTeamID - resource of item to add to inventory
* @param nNumToAdd - Amount of this item to add to inventory
* @param oInvOwner - Override for applying function to object other than PC
* @author joshua
**/
object UT_AddItemToInventory(resource rItem, int nNumToAdd = 1, object oInvOwner = OBJECT_INVALID, string sTag = "", int bSuppressNote = FALSE, int bDroppable = TRUE);


// void unequips an item from an inventory slot
void UT_UnquipItem(object oCreature, int nSlot, int nWeaponSet = INVALID_WEAPON_SET)
{
    object oItem = GetItemInEquipSlot(nSlot, oCreature, nWeaponSet);
    if(IsObjectValid(oItem))
        UnequipItem(oCreature, oItem);
}


/** @brief Loads a cutscene.
*
* Loads the specified cutscene. Sets the specified plot flag after the
* cutscene plays (optional), and makes sTalkSpeaker initiate dialog
* with the player (also optional).
*
* Note: The plot flag and talk speaker parameters require the script
* gen00cs_cutscene_end.nss to be attached to the cutscene itself.
*
* @param rCutscene: Cutscene resource (CUTSCENE_* constants defined in cutscenes_h.nss)
* @param strPlot: Plot which contains the flag to be set
* @param nPlotflag: Plot flag to be set
* @param sTalkSpeaker: Tag of creature who will initiate dialog
*
* @author Jonathan
*/
void CS_LoadCutscene(resource rCutscene,
                     string strPlot = "",
                     int nPlotFlag = -1,
                     string sTalkSpeaker = "");

/** @brief Loads a cutscene with scripted replacement actors.
*
* ** FOR SPECIAL CASE USE ONLY **
* Most cutscenes should use CS_LoadCutscene(), as most actor mappings
* can be handled from the cutscene editor itself.
*
* @param rCutscene: Cutscene resource (CUTSCENE_* constants defined in cutscenes_h.nss)
* @param arActors: (string array) List of cutscene tracks whose actors will be replaced.
* @param arReplacements: (object array) List of objects that will replace the default actors.
* @param strPlot: Plot which contains the flag to be set
* @param nPlotflag: Plot flag to be set
* @param sTalkSpeaker: Tag of creature who will initiate dialog
*
* @author Jonathan
*/
void CS_LoadCutsceneWithReplacements(resource rCutscene,
                                     string [] arActors,
                                     object [] arReplacements,
                                     string strPlot = "",
                                     int nPlotFlag = -1,
                                     string sTalkSpeaker = "");

/** Takes care of stuff that should happen after cutscenes.
*
* The generic cutscene script (gen00cs_cutscene_end) must be set on the properties
* of the cutscene itself for this function to be called.
*
* @param None
* @author Jonathan
*/
void CS_CutsceneEnd();


/*******************************************************************************
* FUNCTION DEFINITIONS
*******************************************************************************/


void UT_Talk(object oSpeaker, object oListener, resource rConversation = R"", int nPartyResurrection = TRUE)
{

    string sDialogResRef = ResourceToString(rConversation);

    Log_Trace(LOG_CHANNEL_SYSTEMS, "utlity_h.UT_Talk", "speaker: " + GetTag(oSpeaker) + ", listener: " + GetTag(oListener) + ", conversation: " +
        sDialogResRef);

    if(GetGameMode() == GM_DEAD)
    {
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utlity_h.UT_Talk", "PARTY IS DEAD - CANT TRIGGER DIALOG!", OBJECT_INVALID, LOG_SEVERITY_CRITICAL);
        return;
    }

    int n = GetLocalInt(GetModule(), DISABLE_FOLLOWER_DIALOG);
    Log_Trace(LOG_CHANNEL_SYSTEMS, "utlity_h.UT_Talk", "disable follower dialog=  " + IntToString(n), OBJECT_INVALID, LOG_SEVERITY_CRITICAL);

    if(GetFollowerState(oSpeaker) != FOLLOWER_STATE_INVALID && GetLocalInt(GetModule(), DISABLE_FOLLOWER_DIALOG) == 1 && GetHero() != GetPartyLeader())
    {
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utlity_h.UT_Talk", "Party leader is not hero when clicking on follower - running soundset instead", OBJECT_INVALID, LOG_SEVERITY_CRITICAL);
        PlaySoundSet(oSpeaker, SS_YES);
        return;
    }

    if(nPartyResurrection)
        ResurrectPartyMembers(FALSE);

    ClearAmbientDialogs(oSpeaker); // this makes sure an already running ambient dialog triggers it's plot flag action

    if (IsFollower(oListener))
        oListener = GetPartyLeader();

    object oModule = GetModule();
    resource rOverrideConversation = GetLocalResource(oModule, PARTY_OVERRIDE_DIALOG);
    int bOverride = GetLocalInt(oModule, PARTY_OVERRIDE_DIALOG_ACTIVE);

    if (IsFollower(oSpeaker)
        && bOverride
        && GetPartyLeader() != GetHero())
    {
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utlity_h.UT_Talk", "overriding dialog with: " + ResourceToString(rOverrideConversation));
        rConversation = rOverrideConversation;
        sDialogResRef = ResourceToString(rConversation);
    }


    Log_Trace(LOG_CHANNEL_SYSTEMS, "utlity_h.UT_Talk", "Triggering BeginConversation NOW");

    TrackDialogEvent(EVENT_TYPE_DIALOGUE, oSpeaker, oListener, sDialogResRef);

    // Track the number of dialogues initiated
    STATS_TrackStartedDialogues(oListener);

    BeginConversation(oListener, oSpeaker, rConversation);
}


void UT_SetShoutsFlag(object oObject, int bEnable = TRUE)
{
    SetLocalInt(oObject, SHOUTS_ACTIVE, bEnable);
    // TBD once we have variables system
}

int UT_GetShoutsFlag(object oObject)
{
    return GetLocalInt(oObject, SHOUTS_ACTIVE);
}

void UT_Surrender(object oCreature)
{
    object oPC = GetPartyLeader();
    int i;

    // Have the creature end combat with the player.
    UT_CombatStop(oCreature, oPC);

    // Have all hostiles end combat with player.
    object[] arHostile = GetNearestObjectByHostility(oPC, TRUE, OBJECT_TYPE_CREATURE, MAX_CREATURES_IN_COMBAT, TRUE);
    int nSize = GetArraySize(arHostile);

    object oHostile;

    for (i = 0; i < nSize; ++i)
    {
        oHostile = arHostile[i];
        if (GetCombatState(oHostile))
            UT_CombatStop(arHostile[i], oPC);
    }

    // Have the player's party end combat with the surrenderer.
    object [] arParty = GetPartyList();
    nSize = GetArraySize(arParty);
    for (i = 0; i < nSize; ++i)
    {
        UT_CombatStop(arParty[i], oCreature);
    }

    // Update the surrender flag to reflect the active status for combat end verification.
    SetLocalInt(oCreature, SURR_SURRENDER_ENABLED, SURR_STATUS_ACTIVE);

}

void UT_SetSurrenderFlag(object oCreature, int bSurrender = TRUE, string sPlotName = "", int nPlotFlag = 0, int bInitConversation = TRUE)
{

    SetLocalInt(oCreature, SURR_SURRENDER_ENABLED, bSurrender);

    if (bSurrender)
        Log_Trace(LOG_CHANNEL_TEMP, "UT_SetSurrenderFlag", "Setting immortal to: TRUE");
    else
        Log_Trace(LOG_CHANNEL_TEMP, "UT_SetSurrenderFlag", "Setting immortal to: FALSE");

    SetImmortal(oCreature, bSurrender);

    if (sPlotName != "")
    {

        SetLocalString(oCreature, SURR_PLOT_NAME, sPlotName);
        SetLocalInt(oCreature, SURR_PLOT_FLAG, nPlotFlag);

    }

    SetLocalInt(oCreature, SURR_INIT_CONVERSATION, bInitConversation);
}

int UT_AttributeCheck(int nAttribute, int nLevel, object oPlayer = OBJECT_SELF)
{
    // TBD
    // GZ: Remember to cast into to float on the attributes
    // to get an attribute value, use
    // GetCreatureProperty(oPlayer,nAttribute,PROPERTY_VALUE_TOTAL);

    float fTargetLevel = 10.0f;
    float fPlayerLevel = GetCreatureProperty(oPlayer, PROPERTY_SIMPLE_LEVEL);
    float fValue = GetCreatureProperty(oPlayer,nAttribute,PROPERTY_VALUE_TOTAL);

    int nResult = FALSE;
    switch (nLevel)
    {
        case UT_ATTR_HIGH:
            nResult = (fValue >= 30.0);
            break;

        case UT_ATTR_MED:
            nResult = (fValue >= 15.0);
            break;

        case UT_ATTR_LOW:
            nResult = TRUE;
            break;

        default:
            // georg: dev warning if called with invalid parameters
            Warning("[UT_AttributeCheck] Attribute check against unknown nLevel. Please notify yaron. Details: " + GetCurrentScriptName());
    }


    Log_Trace(LOG_CHANNEL_SYSTEMS,"UT_AttributeCheck","Checking Attribute:" + ToString(nAttribute) + " Level:" + ToString(nLevel) + " Actual: " + ToString(fValue) + " Target:" + ToString(fTargetLevel) + " Result:" +ToString(nResult));

    return nResult;



}

int _UT_GetIsPlotFollower(object oFollower)
{
    int nRet = FALSE;
    string sTag = GetTag(oFollower);
    if(sTag == GEN_FL_ALISTAIR || sTag == GEN_FL_DOG ||
        sTag == GEN_FL_MORRIGAN || sTag == GEN_FL_WYNNE ||
        sTag == GEN_FL_SHALE || sTag == GEN_FL_STEN ||
        sTag == GEN_FL_ZEVRAN || sTag == GEN_FL_OGHREN ||
        sTag == GEN_FL_LELIANA || sTag == GEN_FL_LOGHAIN)
    {
        nRet = TRUE;
    }

    return nRet;
}

void UT_HireFollower(object oFollower, int bPreventLevelup = FALSE)
{
    object oPC = GetPartyLeader();
    if(!IsObjectValid(oFollower))
    {
        Log_Trace(LOG_CHANNEL_SYSTEMS, "UT_HireFollower", "INVALID FOLLOWER OBJECT!", OBJECT_SELF, LOG_SEVERITY_CRITICAL);
        return;
    }

    Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h.UT_HireFollower",
        "Trying to hire follower: " + GetTag(oFollower));

    if(_UT_GetIsPlotFollower(oFollower))
    {
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h.UT_HireFollower",
            "This function can not be used for plot followers! - use plot flags instead!", oFollower, LOG_SEVERITY_CRITICAL);
        return;
    }

    SetAutoLevelUp(oFollower, 2);
    SetGroupId(oFollower, GetGroupId(oPC));
    WR_SetFollowerState(oFollower, FOLLOWER_STATE_ACTIVE, TRUE, 0, TRUE);
    //SendPartyMemberHiredEvent(oFollower, FALSE, 0, bPreventLevelup);

    //Show the AOE flag when the PC is a mage and aquires a follower or the follower hired is a mage
    if(GetLocalInt(GetModule(), TUTORIAL_ENABLED) && (GetCreatureCoreClass(oPC) == CLASS_WIZARD || GetCreatureCoreClass(oFollower) == CLASS_WIZARD))
    {
        WR_SetPlotFlag(PLT_TUT_FRIENDLY_AOE, TUT_FRIENDLY_AOE_1, TRUE);
    }
}

void UT_FireFollower(object oFollower, int bRemoveFromPool = FALSE, int bRemoveEquipment = TRUE)
{
    if(!IsObjectValid(oFollower))
    {
        Log_Trace(LOG_CHANNEL_SYSTEMS, "UT_FireFollower", "INVALID FOLLOWER OBJECT!", OBJECT_SELF, LOG_SEVERITY_CRITICAL);
        return;
    }

    Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h.UT_FireFollower",
        "Trying to remove follower from the party: " + GetTag(oFollower));

    if(_UT_GetIsPlotFollower(oFollower))
    {
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h.UT_FireFollower",
            "This function can not be used for plot followers! - use plot flags instead!", oFollower, LOG_SEVERITY_CRITICAL);
        return;
    }



    // Removing from active party -> back into the pool
    WR_SetFollowerState(oFollower, FOLLOWER_STATE_AVAILABLE);

    if(bRemoveFromPool) // If we want to premanently remove the follower (active party AND pool)
    {
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h.UT_FireFollower",
                    "removing follower from active party AND party pool: " + GetTag(oFollower));
        WR_SetFollowerState(oFollower, FOLLOWER_STATE_INVALID);
    }

    object oLeader = GetPartyLeader();

    if(bRemoveEquipment == TRUE)
    {
        object [] arItems = GetItemsInInventory(oFollower, GET_ITEMS_OPTION_EQUIPPED);
        int nSize = GetArraySize(arItems);
        object oCurrent;
        int i;

        for(i = 0; i < nSize; i++)
        {
            oCurrent = arItems[i];
            MoveItem(oFollower, oLeader, oCurrent);
        }
    }

}

int UT_SkillCheck(int nSkill, int nLevel, object oObject = OBJECT_SELF)
{
    //There is an override set on the moduel to ensure success or failure.
    //if the override is 0, do not use it.
    //if the override is 1, always return TRUE.
    //if the override is anything else, always return FALSE.
    //David Sims, Novermber 7, 2006

    // Intimidate will now work like persuade
    // Yaron Jan 12, 2009
    object oModule = GetModule();
    int nOverride = GetLocalInt(oModule, DEBUG_SKILL_CHECK_OVERRIDE);
    int bReturn = FALSE;
    if (nOverride == 0)
    {
        //Herbalism, survival, poison, traps
        if (nSkill == SKILL_HERBALISM || nSkill == SKILL_POSION  || nSkill == SKILL_SURVIVAL || nSkill == SKILL_TRAPS)
        {
            object[] oParty = GetPartyList(oObject);
            int nSize = GetArraySize(oParty);
            int i;
            object oCurrent;
            for(i = 0; i < nSize; i++)
            {
                if(bReturn == FALSE)
                {
                    bReturn = GetHasSkill(nSkill, nLevel, oParty[i]);
                }
            }
        }
        else if (nSkill == SKILL_PERSUADE || nSkill == SKILL_INTIMIDATE)
        {
            // Each skill rank is equal 25 points
            // Each difficulty rank is 25 points
            // The player gets a bonus skill rank check of 1 point per attribute bonus value

            int nSkillCheck = 0;
            int nAttribute;
            if(nSkill == SKILL_PERSUADE)
                nAttribute = ATTRIBUTE_INT;
            else if(nSkill == SKILL_INTIMIDATE)
                nAttribute = ATTRIBUTE_STR;

            int nCheckBonus = FloatToInt(GetAttributeModifier(oObject, nAttribute));
            if(GetHasSkill(SKILL_PERSUADE, 1, oObject))
                nSkillCheck = 25;
            if(GetHasSkill(SKILL_PERSUADE, 2, oObject))
                nSkillCheck = 50;
            if(GetHasSkill(SKILL_PERSUADE, 3, oObject))
                nSkillCheck = 75;
            if(GetHasSkill(SKILL_PERSUADE, 4, oObject))
                nSkillCheck = 100;

            nSkillCheck += nCheckBonus;
            
            // Increases hostility and intimidation
            if (nSkill == SKILL_INTIMIDATE && GetHasEffects(oObject, 663906003))
                nSkillCheck += 10;

            if(nLevel == UT_SKILL_CHECK_LOW && nSkillCheck >= 25)
                bReturn = TRUE;
            else if(nLevel == UT_SKILL_CHECK_MED && nSkillCheck >= 50)
                bReturn = TRUE;
            else if(nLevel == UT_SKILL_CHECK_HIGH && nSkillCheck >= 75)
                bReturn = TRUE;
            else if(nLevel == UT_SKILL_CHECK_VERY_HIGH && nSkillCheck >= 100)
                bReturn = TRUE;

        } else if (nSkill == SKILL_LOCKPICKING)
        {
            float fPlayerScore = GetDisableDeviceLevel(oObject);
            float fTargetScore;

            if (nLevel == UT_SKILL_CHECK_VERY_HIGH)
            {
                fTargetScore = 60.0f; // very hard
            } else if (nLevel == UT_SKILL_CHECK_HIGH)
            {
                fTargetScore = 40.0f; // medium
            } else if (nLevel == UT_SKILL_CHECK_MED)
            {
                fTargetScore = 20.0f; // very easy
            } else
            {
                fTargetScore = 1.0f; // auto-success
            }

            if (fPlayerScore >= fTargetScore)
            {
                bReturn = TRUE;
            }
        } else
        {
            //if the override is not set, random result.
            bReturn = GetHasSkill(nSkill, nLevel, oObject);
        }
    }
    else if (nOverride == 1)
    {
        bReturn = TRUE;
    }
    else
    {
        bReturn = FALSE;
    }

    return bReturn;
}

object UT_GetNearestCreature(object oObject, int nIncludeSelf = FALSE)
{
    object [] arCreatures = GetNearestObject(oObject, OBJECT_TYPE_CREATURE, 1, FALSE, FALSE, nIncludeSelf);
    return arCreatures[0];
}

object UT_GetNearestCreatureByTag(object oObject, string sTag, int nIncludeSelf = FALSE)
{
    object [] arCreatures = GetNearestObjectByTag(oObject, sTag, OBJECT_TYPE_CREATURE, 1, FALSE, FALSE, nIncludeSelf);
    return arCreatures[0];
}

object UT_GetNearestCreatureByGroup(object oObject,int nGroup, int nIncludeSelf = FALSE)
{
    object [] arCreatures = GetNearestObjectByGroup(oObject, nGroup, OBJECT_TYPE_CREATURE, 1, FALSE, FALSE, nIncludeSelf);
    return arCreatures[0];
}

object UT_GetNearestHostileCreature(object oObject, int nCheckLiving = FALSE)
{
    object [] arCreatures = GetNearestObjectByHostility(oObject, TRUE, OBJECT_TYPE_CREATURE, MAX_CREATURES_IN_COMBAT, nCheckLiving);
    int i;
    object oCreature = OBJECT_INVALID;
    int nSize = GetArraySize(arCreatures);
    for(i = 0; i < nSize; i++)
    {
        oCreature = arCreatures[i];
        if(!IsDead(oCreature))
            break;
    }

    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_SYSTEMS,"UT_GetNearestHostileCreature", "returning: " + GetTag(oCreature));
    #endif
    return oCreature;
}

void UT_DoAreaTransition(string sArea, string sWP, string sWorldMapLoc1 = "", string sWorldMapLoc2 = "", string sWorldMapLoc3 = "", string sWorldMapLoc4 = "", string sWorldMapLoc5 = "")
{
    Log_Trace(LOG_CHANNEL_SYSTEMS, "UT_DoAreaTransition", "area= " + sArea + ", wp= " + sWP);
    int nSetLocationActive = -1;

    // First, check if specific area load hint is selected
    int iAreaHint = GetLocalInt(GetModule(), AREA_LOAD_HINT);
    if(iAreaHint != 0)
    {
        SetLoadHint(iAreaHint, 206);
        SetLocalInt(GetModule(), AREA_LOAD_HINT, 0);
    }
    else
    {
        // no specific area load hint. pick randomally
        // levels 1-3: very low level table
        // levels 4-7: low level table
        // levels 8-12: mid level table
        // levels 13+ high level table
        int nLevel = GetLevel(GetHero());
        int nTable;
        if(nLevel <= 3) nTable = 284;
        else if(nLevel > 3 && nLevel <= 7) nTable = 277;
        else if(nLevel > 7 && nLevel <= 12) nTable = 275;
        else nTable = 276;

        int iRows = GetM2DARows(nTable);
        Log_Trace(LOG_CHANNEL_SYSTEMS, "UT_DoAreaTransition", "rows1= " + IntToString(iRows));
        int nRandRow = Random(iRows);
        nRandRow = GetM2DARowIdFromRowIndex(nTable, nRandRow);
        Log_Trace(LOG_CHANNEL_SYSTEMS, "UT_DoAreaTransition", "rows2= " + IntToString(iRows));
        SetLoadHint(nRandRow, nTable);
    }


    if(sArea == UT_WORLD_MAP)
    {
        Log_Trace(LOG_CHANNEL_SYSTEMS, "UT_DoAreaTransition", "world map transition");
        SendEventTransitionToWorldMap(sArea, sWP, sWorldMapLoc1, sWorldMapLoc2, sWorldMapLoc3, sWorldMapLoc4, sWorldMapLoc5);
    }
    else
    {
        DoAreaTransition(sArea, sWP);
    }
}

/*void UT_AreaTransition(object oPlayer, string sWP, string sArea = "", string sAreaList = "")
{
    if(sArea == "") // Tranition within the same area list
    {
        object oWP = GetObjectByTag(sWP);
        if(!IsObjectValid(oWP))
        {
            return;
        }
        command cJump = CommandJumpToObject(oWP);
        WR_ClearAllCommands(oPlayer);
        WR_AddCommand(oPlayer, cJump);
    }
    else // area list transition
    {

       // ChangeAreaList(sAreaList, sArea, sWP);
    }



}*/

void UT_ExitDestroy( object oTarg, int bRun = FALSE, string sWP = GENERIC_EXIT, int bRandomWait = FALSE )
{
    float fWait;

    if ( !IsObjectValid(oTarg) ) Log_Trace(LOG_CHANNEL_SYSTEMS,"UT_ExitDestroy was passed a bad object from " + GetTag(OBJECT_SELF));
    else Log_Trace(LOG_CHANNEL_SYSTEMS,"UT_ExitDestroy was passed object " + GetTag(oTarg));

    object oExit = UT_GetNearestObjectByTag( oTarg,sWP );
    event evSetActive = Event(EVENT_TYPE_SET_OBJECT_ACTIVE);
    evSetActive = SetEventInteger(evSetActive, 0, FALSE);

    // Turn off HOME behavior
    SetLocalInt(oTarg, RUBBER_HOME_ENABLED, 0);

    SetObjectInteractive(oTarg, FALSE);

    if(bRandomWait == TRUE)
    {
        // Add a random-length wait command. Useful when a group exits at
        // the same time, so their exits are slightly staggered
        fWait = RandomFloat() * 1.5;
        WR_AddCommand( oTarg, CommandWait(fWait), FALSE, TRUE );
    }
    location lLoc = GetLocation(oExit);
    WR_AddCommand( oTarg,CommandMoveToLocation(lLoc,bRun, TRUE), FALSE, TRUE );

}

void UT_LocalJump(object oTarg, string sWP = "", int nJumpImmediately=TRUE, int bNewHome = TRUE, int bStaticCommand = FALSE, int bJumpParty = FALSE)
{

    if (IsPartyMember(oTarg))
    {
         RemoveEffectsDueToPlotEvent(oTarg);
    }


    string sDestination = sWP;

    if (IsObjectValid(oTarg) == FALSE )
    {
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h.UT_LocalJump", "FAILED - <" + GetTag(oTarg) + "> is not a valid object.");
        return;
    }

    // Default case, go to tp_<OBJSTRING>_0
    if (sWP == "" ) sDestination = "jp_" + GetTag(oTarg) + "_0";

    // sWP is a number, use that instead
    if (StringToInt(sWP) != 0 ) sDestination = "jp_" + GetTag(oTarg) + "_" + sWP;

    object oDest = UT_GetNearestObjectByTag(oTarg, sDestination);



    if (IsObjectValid(oDest) == FALSE )
    {
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h.UT_LocalJump", "FAILED - <" + sDestination + "> is not a valid waypoint.");
        return;
    }
    else if(IsObjectValid(GetArea(oDest)) == FALSE || GetArea(oTarg) != GetArea(oDest))
    {
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h.UT_LocalJump", "FAILED - jumping creature: <" + GetTag(oTarg) + "> and target waypoint: <" +
            GetTag(oDest) + "> are not in the same area!");
        return;
    }
    else
    {
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h.UT_LocalJump", "UT_LocalJump: Object " + GetTag(oTarg) + " is moving to " + sDestination);
    }

    // Added so that this is the new "Home" for the creature
    // FAB 9/4
    if ( bNewHome )
    {
        Rubber_SetHome(oTarg, oDest);
    }


    // -------------------------------------------------------------------------
    // Georg: Tracking wants to know about this too.
    // --------------------------------------------------------------------------
    TrackJumpEvent(oTarg, oDest);

    vector vPos = GetPosition(oDest);
    vector vOrientation = GetOrientation(oDest);



    if(!bJumpParty)
    {
        if(nJumpImmediately)
        {
            SetPosition(oTarg, vPos, TRUE);
            SetOrientation(oTarg, vOrientation);
        }
        else
            WR_AddCommand(oTarg, CommandJumpToObject(oDest), nJumpImmediately, bStaticCommand);
    }
    // Will jump the player's entire party.
    else //if(bJumpParty)
    {
        object    oPartyMember;
        object [] arParty    = GetPartyList(GetPartyLeader());

        int       nLoop;
        int       nPartySize = GetArraySize(arParty);

        for (nLoop = 0; nLoop < nPartySize; nLoop++)
        {
            oPartyMember = arParty[nLoop];

            if (IsObjectValid(oPartyMember) )
            {
                if(nJumpImmediately)
                    SetPosition(oPartyMember, vPos, TRUE);
                else
                    WR_AddCommand( oPartyMember, CommandJumpToObject(oDest), nJumpImmediately, bStaticCommand);
            }
            else
            {
                Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h.UT_LocalJump", "FAILED - <" + GetTag(oPartyMember) + "> is not a valid object.");
            }
        }
    }

}

object [] UT_GetAllObjectsInAreaByTag(string sTag, int nType = OBJECT_TYPE_ALL)
{
    object oPC = GetPartyLeader();
    object [] arCreatures = GetNearestObjectByTag(oPC, sTag, nType, MAX_CREATURES_IN_AREA);
    return arCreatures;
}

void UT_PartyStore(int nSetNeutral = FALSE)
{
    Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h.UT_PartyStore", "Storing active party (up to 3 followers can be stores)");

    object [] arParty = GetPartyList(GetPartyLeader());
    int nSize = GetArraySize(arParty);
    int i;
    SetLocalObject(GetModule(), PARTY_STORE_SLOT_1, OBJECT_INVALID);
    SetLocalObject(GetModule(), PARTY_STORE_SLOT_2, OBJECT_INVALID);
    SetLocalObject(GetModule(), PARTY_STORE_SLOT_3, OBJECT_INVALID);

    object oCurrent;
    for(i = 0; i < nSize; i++)
    {
        oCurrent = arParty[i];
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h.UT_PartyStore", "current party member: " + GetTag(oCurrent));

        if(IsFollower(oCurrent) && !IsHero(oCurrent) && !IsSummoned(oCurrent) )
        {
            Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h.UT_PartyStore", "STORING CURRENT PARTY MEMBER");
            if(GetLocalObject(GetModule(), PARTY_STORE_SLOT_1) == OBJECT_INVALID)
            {
                SetLocalObject(GetModule(), PARTY_STORE_SLOT_1, oCurrent);
                WR_SetFollowerState(oCurrent, FOLLOWER_STATE_UNAVAILABLE);
                if(nSetNeutral)
                    SetGroupId(oCurrent, GROUP_NEUTRAL);
            }
            else if(GetLocalObject(GetModule(), PARTY_STORE_SLOT_2) == OBJECT_INVALID)
            {
                SetLocalObject(GetModule(), PARTY_STORE_SLOT_2, oCurrent);
                WR_SetFollowerState(oCurrent, FOLLOWER_STATE_UNAVAILABLE);
                if(nSetNeutral)
                    SetGroupId(oCurrent, GROUP_NEUTRAL);

            }
            else if(GetLocalObject(GetModule(), PARTY_STORE_SLOT_3) == OBJECT_INVALID)
            {
                SetLocalObject(GetModule(), PARTY_STORE_SLOT_3, oCurrent);
                WR_SetFollowerState(oCurrent, FOLLOWER_STATE_UNAVAILABLE);
                if(nSetNeutral)
                    SetGroupId(oCurrent, GROUP_NEUTRAL);

            }

        }

    }
    Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h.UT_PartyStore", "END");
}


void UT_PartyRestore()
{
    Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h.UT_PartyStore", "Restoring active party (any existing party members will be set invalid)");

    object [] arParty = GetPartyList(GetHero());
    int nSize = GetArraySize(arParty);
    int i;

    object oCurrent;
    for(i = 0; i < nSize; i++)
    {
        oCurrent = arParty[i];
        if(!IsHero(oCurrent))
            WR_SetFollowerState(oCurrent, FOLLOWER_STATE_INVALID);
    }

    object oFollower1 = GetLocalObject(GetModule(), PARTY_STORE_SLOT_1);
    object oFollower2 = GetLocalObject(GetModule(), PARTY_STORE_SLOT_2);
    object oFollower3 = GetLocalObject(GetModule(), PARTY_STORE_SLOT_3);

    if(IsObjectValid(oFollower1))
    {
        Log_Trace(LOG_CHANNEL_SYSTEMS, "UT_PartyRestore", "Restoring: " + GetTag(oFollower1));
        WR_SetObjectActive(oFollower1, TRUE);
        WR_SetFollowerState(oFollower1, FOLLOWER_STATE_ACTIVE);
        SetGroupId(oFollower1, GROUP_PC);
    }

    if(IsObjectValid(oFollower2))
    {
        Log_Trace(LOG_CHANNEL_SYSTEMS, "UT_PartyRestore", "Restoring: " + GetTag(oFollower2));
        WR_SetObjectActive(oFollower2, TRUE);
        WR_SetFollowerState(oFollower2, FOLLOWER_STATE_ACTIVE);
        SetGroupId(oFollower2, GROUP_PC);
    }

    if(IsObjectValid(oFollower3))
    {
        Log_Trace(LOG_CHANNEL_SYSTEMS, "UT_PartyRestore", "Restoring: " + GetTag(oFollower3));
        WR_SetObjectActive(oFollower3, TRUE);
        WR_SetFollowerState(oFollower3, FOLLOWER_STATE_ACTIVE);
        SetGroupId(oFollower3, GROUP_PC);
    }

}

void UT_DestroyTag(string sTag)
{
    object oCreature;
    int i;

    object [] arTargets = UT_GetAllObjectsInAreaByTag(sTag);

    // Now destroy everything in the array
    int nSize = GetArraySize(arTargets);
    for(i = 0; i < nSize; i++)
    {
        oCreature = arTargets[i];
        DestroyObject(oCreature, 0);
    }

}


int UT_FindSubString(string sString, string sSubString, int nInstance=1)
{
    int nIndex = 1;
    int nAbsoluteIndex = 0;
    int nLength;
    while (nInstance >= 1 && nIndex > 0)
    {
        nIndex = FindSubString(sString, sSubString);
        nLength = GetStringLength(sString) - nIndex;
        sString = SubString(sString, nIndex + 1, nLength);

        if (nInstance != 1 && nIndex != -1)
        {
             nIndex++;
        }
        nAbsoluteIndex += nIndex;
        nInstance--;
    }
    return nAbsoluteIndex;
}

void UT_QuickMove(string sTag, string sWP = "0", int bRun = FALSE, int bFollowPath = FALSE, int bNewHome = TRUE, int bStaticCommand = FALSE)
{
    object oPC = GetPartyLeader();
    object oMover = UT_GetNearestCreatureByTag(oPC, sTag);
    UT_QuickMoveObject(oMover, sWP, bRun, bFollowPath, bNewHome, bStaticCommand);
}

void UT_QuickMoveObject(object oMover, string sWP = "0", int bRun = FALSE, int bFollowPath = FALSE, int bNewHome = TRUE, int bStaticCommand = FALSE)
{
    string sDestination = sWP;

    string sTag = GetTag(oMover);
    object oTarget;
    command cMoveToTarget;
    int nDestinationWP = StringToInt(sWP);
    object oDestination;
    location [] arLocs;
    int i;

    if ( !IsObjectValid(oMover) )
    {
        LogTrace(LOG_CHANNEL_SYSTEMS, "QuickMove failed - " + GetTag(oMover) + " is not a valid object.");
        return;
    }

    if(bFollowPath != FALSE)
    {
        // if a numbered waypoint is specified, move to each waypoint in turn
        // until the last waypoint is reached
        if (nDestinationWP != 0)
        {
            // Assemble an array of objects to move to
            sDestination = "mp_" + GetTag(oMover) + "_1";
            oDestination = UT_GetNearestObjectByTag(oMover, sDestination);

            i = 0;
            while(IsObjectValid(oDestination) && (i < nDestinationWP) )
            {
                arLocs[i] = GetLocation(oDestination);
                LogTrace(LOG_CHANNEL_SYSTEMS, "QuickMove location added - " + sDestination, oDestination);
                i++;
                sDestination = "mp_" + sTag + "_" + IntToString(i + 1);
                oDestination = UT_GetNearestObjectByTag(oMover, sDestination);
            }
        }
        int nSize = GetArraySize(arLocs);

        LogTrace(LOG_CHANNEL_SYSTEMS, "QuickMove size of queue: " + IntToString(nSize));
        if(nSize <= 0)
        {
            LogTrace(LOG_CHANNEL_SYSTEMS, "QuickMove failed - " + GetTag(oMover) + " no valid list of locations to move to.");
            return;
        }
        oTarget = UT_GetNearestObjectByTag(oMover, "mp_" + sTag + "_" + sWP);
        cMoveToTarget = CommandMoveToMultiLocations(arLocs, bRun);

    }
    else
    {
        // Default case, go to mp_<OBJSTRING>_0
        if ( sWP == "" || sWP == "0" ) sDestination = "mp_" + sTag + "_0";
        // sWP is a number, use that instead
        if ( nDestinationWP != 0 ) sDestination = "mp_" + sTag + "_" + sWP;

        oTarget = UT_GetNearestObjectByTag(oMover, sDestination);

        if ( !IsObjectValid(oTarget) )
        {
            LogTrace(LOG_CHANNEL_SYSTEMS, "QuickMove failed - " + sDestination + " is not a valid waypoint.");
            return;
        }
        cMoveToTarget = CommandMoveToObject(oTarget, bRun);
    }

    // Added so that this is the new "Home" for the creature
    // FAB 9/4
    if ( bNewHome ) Rubber_SetHome(oMover, oTarget);

    WR_AddCommand(oMover, cMoveToTarget, FALSE, bStaticCommand);

    //Face the same way as the last waypoint
    command cTurn = CommandTurn(GetFacing(oTarget));
    AddCommand(oMover, cTurn, FALSE, bStaticCommand, COMMAND_ADDBEHAVIOR_DONTCLEAR);

    LogTrace(LOG_CHANNEL_SYSTEMS, "Object " + sTag +" is moving to " + sDestination);
}

void UT_CombatStart(object oAttacker, object oTarget, int bTargetSelectionOverride = FALSE, int nOverridePermanent = FALSE)
{

    int     nAttackGroup      = GetGroupId(oAttacker);
    int     nTargetGroup      = GetGroupId(oTarget);
    int     bHostilityChanged = FALSE;

    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_SYSTEMS, "UT_CombatStart", "oAttacker: " + GetTag(oAttacker) + ", oTarget: " + GetTag(oTarget));
    #endif

    // Handle special case:
    // If both objects have the same group, there is nothing that can be done.
    if ( nAttackGroup == nTargetGroup )
    {
        #ifdef DEBUG
        Log_Trace( LOG_CHANNEL_SYSTEMS, "UT_CombatStart",
            "Creatures have the same group: [" +
            IntToString(nAttackGroup) + "] [" + IntToString(nTargetGroup) + "]",
            OBJECT_SELF, LOG_SEVERITY_CRITICAL );
        #endif
        return;
    }

    // If creature was lying on the groun then need to remove fake-death effect
    if(GetLocalInt(oAttacker, CREATURE_SPAWN_DEAD) == 2)
    {
        SetLocalInt(oAttacker, CREATURE_SPAWN_DEAD, 0);
        RemoveEffectsByParameters(oAttacker, EFFECT_TYPE_SIMULATE_DEATH);
    }

    // [PC] attacking [Neutral/Friendly]
    if( ((nAttackGroup==GROUP_PC)&&(nTargetGroup==GROUP_NEUTRAL||nTargetGroup==GROUP_FRIENDLY)) )
    {
        SetGroupId( oTarget, GROUP_HOSTILE );
        #ifdef DEBUG
        Log_Trace( LOG_CHANNEL_SYSTEMS, "UT_CombatStart",
        "Changing the following creature's group to be HOSTILE: " + GetTag(oTarget) );
        #endif
        bHostilityChanged = TRUE;
    }
    // [Neutral/Friendly] attacking [PC]
    else if( ((nTargetGroup==GROUP_PC)&&(nAttackGroup==GROUP_NEUTRAL||nAttackGroup==GROUP_FRIENDLY)) )
    {
        SetGroupId( oAttacker, GROUP_HOSTILE );
        #ifdef DEBUG
        Log_Trace( LOG_CHANNEL_SYSTEMS, "UT_CombatStart",
        "Changing the following creature's group to be HOSTILE: " + GetTag(oAttacker) );
        #endif
        bHostilityChanged = TRUE;
    }

    // [The Rest]
    else if ( !(nTargetGroup==GROUP_PC||nTargetGroup==GROUP_NEUTRAL||nTargetGroup==GROUP_FRIENDLY||nTargetGroup==GROUP_HOSTILE) ||
              !(nAttackGroup==GROUP_PC||nAttackGroup==GROUP_NEUTRAL||nAttackGroup==GROUP_FRIENDLY||nAttackGroup==GROUP_HOSTILE) )
    {
        #ifdef DEBUG
        Log_Trace( LOG_CHANNEL_SYSTEMS, "UT_CombatStart",
            "Setting the following groups to be hostile towards each other: [" +
            IntToString(nAttackGroup) + "] [" + IntToString(nTargetGroup) + "]" );
        #endif
        SetGroupHostility( nAttackGroup, nTargetGroup, TRUE );
        bHostilityChanged = TRUE;
    }

    // Check for overriding the Attackers Target.
    if ( bTargetSelectionOverride )
    {
        #ifdef DEBUG
        Log_Trace( LOG_CHANNEL_SYSTEMS, "UT_CombatStart",
            "Forcing attacker to attack target" );
        #endif
            SetLocalObject( oAttacker, AI_TARGET_OVERRIDE, oTarget );
            if(nOverridePermanent)
                SetLocalInt(oAttacker, AI_TARGET_OVERRIDE_DUR_COUNT, -1); // -1 flags permanent override
            else
                SetLocalInt( oAttacker, AI_TARGET_OVERRIDE_DUR_COUNT, 0 );
    }

    // Hostility Change Failed
    if( !bHostilityChanged )
    {
        #ifdef DEBUG
        Log_Trace( LOG_CHANNEL_SYSTEMS, "UT_CombatStart",
            "Could not turn creatures hostile towards each other: [" +
            IntToString(nAttackGroup) + "] [" + IntToString(nTargetGroup) + "]",
            OBJECT_SELF, LOG_SEVERITY_CRITICAL );
        #endif
    }

}



void UT_CombatStop(object oCreatureA, object oCreatureB)
{
    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_SYSTEMS, "UT_CombatStop", "CreatureA: " + GetTag(oCreatureA) + ", oCreatureB: " + GetTag(oCreatureB));
    #endif
    // Handle attacker
    int nCreatureAGroup = GetGroupId(oCreatureA);
    int nCreatureBGroup = GetGroupId(oCreatureB);
    int nHostilityChanged = FALSE;

    // First, clear everything for both creatures
    WR_ClearAllCommands(oCreatureA);
    WR_ClearAllCommands(oCreatureB);

    if(nCreatureAGroup == GROUP_HOSTILE) // switch to neutral
    {
        SetGroupId(oCreatureA, GROUP_NEUTRAL);
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_SYSTEMS, "UT_CombatStop",
            "Changing the following creature's group to be NON_HOSTILE: " + GetTag(oCreatureA));
        #endif
        nHostilityChanged = TRUE;
    }
    else if(nCreatureBGroup == GROUP_HOSTILE)
    {
        SetGroupId(oCreatureB, GROUP_NEUTRAL);
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_SYSTEMS, "UT_CombatStop",
            "Changing the following creature's group to be NON_HOSTILE: " + GetTag(oCreatureB));
        #endif
        nHostilityChanged = TRUE;
    }

    if(!nHostilityChanged && (nCreatureAGroup != GROUP_PC && nCreatureAGroup != GROUP_HOSTILE &&
        nCreatureAGroup != GROUP_FRIENDLY && nCreatureAGroup != GROUP_NEUTRAL) || (nCreatureBGroup != GROUP_PC &&
        nCreatureBGroup != GROUP_FRIENDLY && nCreatureBGroup != GROUP_NEUTRAL && nCreatureBGroup != GROUP_HOSTILE)) // no change yet -> we are dealing with at least one custom group
    {
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_SYSTEMS, "UT_CombatStop",
            "Setting the following groups to be non-hostile towards each other: [" + IntToString(nCreatureAGroup) + "] ["
                + IntToString(nCreatureBGroup) + "]");
        #endif
        SetGroupHostility(nCreatureAGroup, nCreatureBGroup, FALSE);
        nHostilityChanged = TRUE;
    }

    if(!nHostilityChanged)
    {
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_SYSTEMS, "UT_CombatStop",
            "Could not turn creatures hostile towards each other", OBJECT_SELF, LOG_SEVERITY_CRITICAL);
        #endif
    }
}

void UT_IncLocalInt(object oObject, string sVarName, int nIncrement = 1)
{
    int nOldValue = GetLocalInt(oObject, sVarName);
    int nNewValue = nOldValue + nIncrement;

    SetLocalInt(oObject, sVarName, nNewValue);

}

void UT_PCJumpOrAreaTransition(string sArea, string sWaypoint, string sWorldMapLoc1 = "", string sWorldMapLoc2 = "", string sWorldMapLoc3 = "", string sWorldMapLoc4 = "", string sWorldMapLoc5 = "")
{
    object oPC = GetPartyLeader();
    object oArea = GetArea(oPC);
    string sAreaTag = GetTag(oArea);

    if (GetGameMode() == GM_COMBAT)
    {
        UI_DisplayMessage(GetMainControlled(), UI_MESSAGE_CANT_DO_IN_COMBAT);
    }
    else if(sAreaTag == sArea)
    {
        UT_LocalJump(oPC,sWaypoint);
    }
    else
    {
        UT_DoAreaTransition(sArea, sWaypoint, sWorldMapLoc1, sWorldMapLoc2, sWorldMapLoc3, sWorldMapLoc4, sWorldMapLoc5);
    }
}

object [] UT_GetTeam ( int nTeamID, int nMembersType = OBJECT_TYPE_CREATURE )
{
    object []   arNewList;

    if ( nTeamID <= 0 )
    {
        Log_Trace( LOG_CHANNEL_SYSTEMS, "utility_h:UT_GetTeam", "Invalid Team ID" );
        return arNewList;
    }

    arNewList = GetTeam(nTeamID, nMembersType);

    return arNewList;

}

void UT_TeamAppears(int nTeamID, int bAppears = TRUE, int nMembersType = OBJECT_TYPE_CREATURE )
{

    int         nIndex;
    object      oPC = GetPartyLeader();
    object []   arTeam = UT_GetTeam( nTeamID, nMembersType );

    for ( nIndex = 0; nIndex < GetArraySize(arTeam); nIndex++ )
        WR_SetObjectActive( arTeam[nIndex], bAppears );

    #ifdef DEBUG
    if ( !nIndex )
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h:UT_TeamAppears",
            "No team members found for TeamID #" + ToString(nTeamID) );

    else
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h:UT_TeamAppears",
            "Team ID #" + ToString(nTeamID) + " has been set to ACTIVE. " +
            ToString(nIndex) + " objects have been affected" );
    #endif

}

void UT_TeamGoesHostile(int nTeamID, int bHostile = TRUE)
{

    int         nIndex;
    object      oPC = GetPartyLeader();
    object []   arTeam = UT_GetTeam( nTeamID );

    if ( bHostile )     // The team will go to GROUP_HOSTILE
    {
        for ( nIndex = 0; nIndex < GetArraySize(arTeam); nIndex++ )
            UT_CombatStart( arTeam[nIndex], oPC );
    }
    else                // The team will go to GROUP_NEUTRAL
    {
        for ( nIndex = 0; nIndex < GetArraySize(arTeam); nIndex++ )
            SetGroupId(arTeam[nIndex], GROUP_NEUTRAL);
    }

    #ifdef DEBUG
    if ( !nIndex )
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h:UT_TeamGoesHostile",
            "No team members found for Team ID #" + ToString(nTeamID) );

    else
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h:UT_TeamGoesHostile",
            "Team ID #" + ToString(nTeamID) + " has gone HOSTILE. " +
            ToString(nIndex) + " objects have been affected" );
    #endif

}

void UT_TeamExit(int nTeamID, int nRun = FALSE, string sTagOverride = GENERIC_EXIT)
{

    int         nIndex;
    object      oPC = GetPartyLeader();
    object []   arTeam = UT_GetTeam( nTeamID );

    for ( nIndex = 0; nIndex < GetArraySize(arTeam); nIndex++ )
        UT_ExitDestroy( arTeam[nIndex], nRun, sTagOverride, TRUE );

    #ifdef DEBUG
    if ( !nIndex )
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h:UT_TeamExit",
            "No team members found for Team ID #" + ToString(nTeamID) );

    else
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h:UT_TeamExit",
            "Team ID #" + ToString(nTeamID) + " is heading to the EXIT. " +
            ToString(nIndex) + " objects have been affected" );
    #endif

}

void UT_TeamJump(int nTeamID, string sTagDestination = "", int bJumpImmediately = FALSE, int bStaticCommand = FALSE, int bNewHome = FALSE)
{
    int         nIndex;
    object      oPC = GetPartyLeader();
    object []   arTeam = UT_GetTeam( nTeamID );
    object      oDestination = UT_GetNearestObjectByTag(oPC, sTagDestination);

    int         nQuickJump;

    // This checks if an integer was passed as the waypoint.
    // If so instead of everyone jumping to the same location, instead everyone moves to
    // their own spot using the same logic as the UT_LocalJump code.
    if ( sTagDestination == "0" || StringToInt(sTagDestination) != 0 ) nQuickJump = TRUE;

    if ( nQuickJump )
    {
        for ( nIndex = 0; nIndex < GetArraySize(arTeam); nIndex++ )
        {
            Log_Trace(LOG_CHANNEL_PLOT, GetTag(arTeam[nIndex]));

            oDestination = UT_GetNearestObjectByTag(oPC, "jp_" + GetTag(arTeam[nIndex]) + "_" + sTagDestination);

            if ( IsObjectValid(oDestination) )
            {
                WR_AddCommand(arTeam[nIndex], CommandJumpToObject(oDestination), bJumpImmediately, bStaticCommand);
            }
            else
            {
                Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h:UT_TeamJump",
                    "Function passed an invalid destination (" + sTagDestination + ") for team member " +
                        GetTag(arTeam[nIndex]) + "." );
            }
            if (bNewHome == TRUE)
            {
                Rubber_SetHome(arTeam[nIndex], oDestination);
            }
        }
    }
    else if ( IsObjectValid(oDestination) )
    {
        for ( nIndex = 0; nIndex < GetArraySize(arTeam); nIndex++ )
        {
            Log_Trace(LOG_CHANNEL_PLOT, GetTag(arTeam[nIndex]));
            WR_AddCommand(arTeam[nIndex], CommandJumpToObject(oDestination), bJumpImmediately, bStaticCommand);
            if (bNewHome == TRUE)
            {
                Rubber_SetHome(arTeam[nIndex], oDestination);
            }
        }
    }
    else
    {
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h:UT_TeamJump",
            "Function passed an invalid destination (" + sTagDestination + ")." );
    }

    if ( !nIndex )
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h:UT_TeamJump",
            "No team members found for Team ID #" + ToString(nTeamID) );

    else
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h:UT_TeamJump",
            "Team ID #" + ToString(nTeamID) + " is heading to its desintation (" + sTagDestination + "). " +
            ToString(nIndex) + " objects have been affected." );
}

void UT_TeamMove(int nTeamID, string sTagDestination = "", int bRun = FALSE, float fRange = 0.0, int bNewHome = FALSE)
{
    int         nIndex;
    object      oPC = GetPartyLeader();
    object []   arTeam = UT_GetTeam( nTeamID );
    object      oDestination = UT_GetNearestObjectByTag(oPC, sTagDestination);

    if ( IsObjectValid(oDestination) )
    {
        for ( nIndex = 0; nIndex < GetArraySize(arTeam); nIndex++ )
        {
            Log_Trace(LOG_CHANNEL_PLOT, GetTag(arTeam[nIndex]));
            WR_AddCommand(arTeam[nIndex], CommandMoveToObject(oDestination, bRun, fRange), TRUE);
            if ( bNewHome )
            {
                Rubber_SetHome(arTeam[nIndex], oDestination);
            }
        }
    }
    else
    {
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h:UT_TeamMove",
            "Function passed an invalid destination (" + sTagDestination + ")." );
    }

    if ( !nIndex )
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h:UT_TeamMove",
            "No team members found for Team ID #" + ToString(nTeamID) );

    else
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h:UT_TeamMove",
            "Team ID #" + ToString(nTeamID) + " is heading to its desintation (" + sTagDestination + "). " +
            ToString(nIndex) + " objects have been affected." );
}

void UT_KillTeam(int nTeam, object oKiller = OBJECT_INVALID)
{
    object[] arTeam = UT_GetTeam(nTeam);
    int nIndex;
    int nTeamSize = GetArraySize(arTeam);
    for ( nIndex = 0; nIndex < nTeamSize; nIndex++ )
    {
        KillCreature(arTeam[nIndex], oKiller);
    }
}

void UT_TeamMerge(int nTeam, int nNewTeam, int nMembersType = OBJECT_TYPE_CREATURE )
{
    object[] arTeam = UT_GetTeam(nTeam, nMembersType);
    int nIndex;
    int nTeamSize = GetArraySize(arTeam);
    for ( nIndex = 0; nIndex < nTeamSize; nIndex++ )
    {
        SetTeamId(arTeam[nIndex], nNewTeam);
    }
}


void UT_SetTeamStationary(int nTeam, int nStationaryStatus)
{
    object[] arTeam = UT_GetTeam(nTeam);
    int nIndex;
    int nTeamSize = GetArraySize(arTeam);
    for ( nIndex = 0; nIndex < nTeamSize; nIndex++ )
    {
        SetLocalInt(arTeam[nIndex], AI_FLAG_STATIONARY, nStationaryStatus);
    }
}

void UT_SetTeamInteractive(int nTeam, int bInterractive, int nMembersType = OBJECT_TYPE_CREATURE)
{
    object[] arTeam = UT_GetTeam(nTeam, nMembersType);
    int nIndex;
    int nTeamSize = GetArraySize(arTeam);
    for ( nIndex = 0; nIndex < nTeamSize; nIndex++ )
    {
        SetObjectInteractive(arTeam[nIndex], bInterractive);
    }
}



int UT_IsFollowerInParty(object oFollower)
{
    return (GetFollowerState(oFollower) == FOLLOWER_STATE_ACTIVE);
}


void UT_RemoveItemFromInventory( resource rItem, int nNumToRemove = 1, object oInvOwner = OBJECT_INVALID, string sTag = "")
{

    if ( oInvOwner == OBJECT_INVALID )
        oInvOwner = GetPartyLeader();

    if ( sTag == "" )
        sTag = ResourceToTag(rItem);

    Log_Trace( LOG_CHANNEL_SYSTEMS, "utility_h:UT_RemoveItemFromInventory",
                    "Total to Remove: [" + sTag + " x " + ToString(nNumToRemove) + "]", oInvOwner );

    RemoveItemsByTag(oInvOwner,sTag,nNumToRemove);


    /*
    int     nIndex;
    int     nNumItems;
    int     nNumLeftToRemove = nNumToRemove;
    int     nCurrentStackSize;
    object  oItem;

    // We are standardizing the item's tag to be the same as it's resource name,
    // minus the extension. We do this to insure that they match, because
    // they should. If they don't match, it is a bug. This squashes such an
    // occurance.
    string  sItemTag = (sTag != "") ? sTag :  ResourceToTag(rItem);
    object [] arItems = GetItemsInInventory( oInvOwner, TRUE, 0, sItemTag );
    nNumItems = GetArraySize( arItems );

    Log_Trace( LOG_CHANNEL_SYSTEMS, "utility_h:UT_RemoveItemFromInventory",
                    "Total to Remove: [" + sItemTag + " x " + ToString(nNumToRemove) + "]", oInvOwner );

    //--------------------------------------------------------------------------
    // ***TEMPORARY***
    // Simple Selection Sort: smallest stack size first
    int nIndex2, nSmallest = 0;
    for ( nIndex = 0; nIndex < nNumItems; nIndex++ )
    {
        nSmallest = nIndex;
        for ( nIndex2 = nIndex; nIndex2 < nNumItems; nIndex2++ )
        {
            if (GetItemStackSize(arItems[nSmallest]) > GetItemStackSize(arItems[nIndex2]))
                nSmallest = nIndex2;
        }
        oItem = arItems[nIndex];
        arItems[nIndex] = arItems[nSmallest];
        arItems[nSmallest] = oItem;
    }
    //--------------------------------------------------------------------------

    // Loop through all the item stacks to delete the correct amount of items.
    for ( nIndex = 0; nIndex < nNumItems; nIndex++ )
    {

        oItem = arItems[nIndex];

        if ( IsObjectValid(oItem) )
        {

            nCurrentStackSize = GetItemStackSize(oItem);

            // Case 1:  There are enough items left in this stack to finish
            //          the removing procedure. Simply remove the remaining
            //          items out of the stack.
            if (nCurrentStackSize > nNumLeftToRemove)
            {

                SetItemStackSize( oItem, (nCurrentStackSize-nNumLeftToRemove) );

                Log_Trace( LOG_CHANNEL_SYSTEMS, "utility_h:UT_RemoveItemFromInventory",
                    "Removed: [" + sItemTag + " x " + ToString(nCurrentStackSize) + "] --> " +
                    "[" + sItemTag + " x " + ToString((nCurrentStackSize-nNumLeftToRemove)) + "] " +
                    "(-"  + ToString(nNumLeftToRemove) + ")", oInvOwner );



                nNumLeftToRemove = 0;

                break;

            }

            // Case 2:  We need to remove more items then are available in this
            //          stack. We will just destroy this stack and go on to the
            //          next one if it exists.
            else
            {

                Log_Trace( LOG_CHANNEL_SYSTEMS, "utility_h:UT_RemoveItemFromInventory",
                    "Removed: [" + sItemTag + " x " + ToString((nCurrentStackSize)) + "]", oInvOwner );

                nNumLeftToRemove = nNumLeftToRemove - nCurrentStackSize;

                WR_DestroyObject( oItem );

            }
        }
    }

    Log_Trace( LOG_CHANNEL_SYSTEMS, "utility_h:UT_RemoveItemFromInventory",
        "Total Removed: [" + sItemTag + " x " + ToString((nNumToRemove-nNumLeftToRemove)) + "]", oInvOwner );
   */

}



int UT_CountItemInInventory( resource rItem, object oInvOwner = OBJECT_INVALID, string sTag ="" )
{

    if ( oInvOwner == OBJECT_INVALID )
        oInvOwner = GetPartyLeader();

    if ( sTag == "" )
        sTag = ResourceToTag(rItem);

    Log_Trace( LOG_CHANNEL_SYSTEMS, "utility_h:UT_CountItemInInventory",
                    "Item to Count: [" + sTag + "]", oInvOwner );

    return CountItemsByTag(oInvOwner,sTag);
}

object UT_AddItemToInventory(resource rItem, int nNumToAdd = 1, object oInvOwner = OBJECT_INVALID, string sTag = "", int bSuppressNote = FALSE, int bDroppable = TRUE)
{


    if ( oInvOwner == OBJECT_INVALID )
        oInvOwner = GetPartyLeader();

    Log_Trace( LOG_CHANNEL_SYSTEMS, "utility_h:UT_AddItemToInventory",
                    "Total to Add: [" + ResourceToTag(rItem) + " x " + ToString(nNumToAdd) + "]", oInvOwner );

    return CreateItemOnObject(rItem,oInvOwner,nNumToAdd,sTag,bSuppressNote,bDroppable);
}

/**-----------------------------------------------------------------------------
* @brief Opens a door away from the user and sends the door an EVENT_TYPE_OPENED event.
* @param oDoor      The door to open
* @param oUser      The creature opening the door.
*-----------------------------------------------------------------------------*/
void UT_OpenDoor(object oDoor, object oUser)
{
    float fAngle = GetAngleBetweenObjects(oDoor, oUser);
    SetPlaceableState(oDoor, ((fAngle > 90.0f && fAngle < 270.0f) ? PLC_STATE_DOOR_OPEN_2 : PLC_STATE_DOOR_OPEN));
    SendEventOpened(oDoor, oUser);
}

void CS_CutsceneEnd()
{
    Log_Trace(LOG_CHANNEL_SYSTEMS, "cutscenes_h.nss, CS_CutsceneEnd",
        "CS_CutsceneEnd() called");

    object oModule = GetModule();

    // Get info from last cutscene call
    string sPlot = GetLocalString(oModule, CUTSCENE_SET_PLOT);
    int nFlag = GetLocalInt(oModule, CUTSCENE_SET_PLOT_FLAG);
    string sTalkSpeaker = GetLocalString(oModule, CUTSCENE_TALK_SPEAKER);

    // Reset local variables
    SetLocalString(oModule, CUTSCENE_SET_PLOT, "");
    SetLocalInt(oModule, CUTSCENE_SET_PLOT_FLAG, -1);
    SetLocalString(oModule, CUTSCENE_TALK_SPEAKER, "");

    // Check if we need to set a plot flag
    if(sPlot != "")
    {
        if(nFlag > -1)
        {
            // Set the plot flag
            WR_SetPlotFlag(sPlot, nFlag, TRUE, TRUE);
        }
    }

    // Check if there is someone who should begin a conversation
    if(sTalkSpeaker != "")
    {
        object oPC = GetHero();
        object oTalkSpeaker = UT_GetNearestCreatureByTag(oPC, sTalkSpeaker);
        if(IsObjectValid(oTalkSpeaker))
        {
            UT_Talk(oTalkSpeaker, oPC);
        }
        else
        {
            Log_Systems("CS_CutsceneEnd: could not find sTalkSpeaker: " + sTalkSpeaker, LOG_LEVEL_ERROR);
        }
    }
}

void CS_LoadCutscene(resource rCutscene,
                     string strPlot = "",
                     int nPlotFlag = -1,
                     string sTalkSpeaker = "")
{
    string [] arActors;
    object [] arReplacements;

    CS_LoadCutsceneWithReplacements(rCutscene,
                                    arActors,
                                    arReplacements,
                                    strPlot,
                                    nPlotFlag,
                                    sTalkSpeaker);
}

void CS_LoadCutsceneWithReplacements(resource rCutscene,
                                     string [] arActors,
                                     object [] arReplacements,
                                     string strPlot = "",
                                     int nPlotFlag = -1,
                                     string sTalkSpeaker = "")
{
    object oModule = GetModule();

    SetLocalString(oModule, CUTSCENE_SET_PLOT, strPlot);
    SetLocalInt(oModule, CUTSCENE_SET_PLOT_FLAG, nPlotFlag);
    SetLocalString(oModule, CUTSCENE_TALK_SPEAKER, sTalkSpeaker);

    LoadCutscene(rCutscene, OBJECT_INVALID, TRUE, arActors, arReplacements, TRUE);
}

/** @} */