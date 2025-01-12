//::///////////////////////////////////////////////
//:: Plot Events For the Siege of Redcliffe
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////

//:://////////////////////////////////////////////
//:: Created By: Sheryl
//:: Created On: March 10, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "cai_h"
#include "cutscenes_h"
#include "arl_constants_h"
#include "arl_siege_h"
#include "arl_functions_h"

#include "plt_arl100pt_siege"
#include "plt_arl150pt_loghain_spy"
#include "plt_gen00pt_backgrounds"
#include "plt_arl100pt_oil_stores"
#include "plt_gen00pt_stealing"
#include "plt_arl110pt_bevin_lost"
#include "plt_gen00pt_party"
#include "cli_functions_h"
#include "plt_lite_mage_silence"
#include "plt_mnp000pt_autoss_main"


const int ARL_NUMBER_OF_SIMULTANEOUS_WINDMILL_CORPSES = 8;
const int ARL_NUMBER_OF_REINFORCMENT_WINDMILL_CORPSES = 10;
const int ARL_NUMBER_OF_SIMULTANEOUS_VILLAGE_CORPSES = 10;
const int ARL_NUMBER_OF_REINFORCMENT_VILLAGE_CORPSES = 10;

const int ARL_BARRICADE_EAST = 1;
const int ARL_BARRICADE_SOUTHEAST = 2;
const int ARL_BARRICADE_SOUTH = 3;

void ARL_SiegeEnd();
void ARL_SiegeEnd()
{
    object oArea = GetArea(GetHero());
    event evSiegeOver = Event(ARL_EVENT_BATTLE_OVER);
    DelayEvent(5.0, oArea, evSiegeOver);
}


/* Qwinn disabled - this does nothing, replaced with amulets conferring benefits of traits listed in ABI_base.xls.
void Arl_SiegeApplyMoraleEffects();
void Arl_SiegeApplyMoraleEffects()
{
    int bMilitiaMoraleHigh = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_MILITIA_MORALE_HIGH, TRUE);
    int bMilitiaMoraleLow = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_MILITIA_MORALE_LOW, TRUE);
    int bKnightsMoraleHigh = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_KNIGHTS_MORALE_HIGH, TRUE);
    int bKnightsMoraleLow = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_KNIGHTS_MORALE_LOW, TRUE);

    object[] oMiltiaArray = GetTeam(ARL_TEAM_VILLAGERS);
    int nMilitia = GetArraySize(oMiltiaArray);
    int nIndex = 0;
    for (nIndex = 0; nIndex < nMilitia; nIndex++)
    {
        object oMilitia = oMiltiaArray[nIndex];
        if (bMilitiaMoraleHigh == TRUE)
        {
            AddAbility(oMilitia, ABILITY_TRAIT_HIGH_MORALE);
        }
        else if (bMilitiaMoraleLow == TRUE)
        {
            AddAbility(oMilitia, ABILITY_TRAIT_LOW_MORALE);
        }

    }

    int nKnightsMorale = Arl_GetKnightsMorale();

    object[] oKnightsArray = GetTeam(ARL_TEAM_KNIGHTS);
    int nKnights = GetArraySize(oKnightsArray);
    for (nIndex = 0; nIndex < nKnights; nIndex++)
    {
        object oKnight = oKnightsArray[nIndex];
        if (bKnightsMoraleHigh == TRUE)
        {
            AddAbility(oKnight, ABILITY_TRAIT_HIGH_MORALE);
        }
        else if (bKnightsMoraleLow == TRUE)
        {
            AddAbility(oKnight, ABILITY_TRAIT_LOW_MORALE);
        }
    }
}
*/

/* Qwinn:  Not using anymore, moved to ARL_SIEGE_SET_UP_DEFENDERS
void ARL_SiegeEquipMilitiaByTeam(int nTeam);
void ARL_SiegeEquipMilitiaByTeam(int nTeam)
{

    object[] oMiltiaArray = GetTeam(nTeam);
    int nMilitia = GetArraySize(oMiltiaArray);
    int nIndex = 0;
    for (nIndex = 0; nIndex < nMilitia; nIndex++)
    {
        object oMilitia = oMiltiaArray[nIndex];
        ARL_SiegeEquipMilitiaMember(oMilitia);
    }
}
*/

int StartingConditional()
{
    event eParms = GetCurrentEvent();                // Contains all input parameters
    int nType = GetEventType(eParms);               // GET or SET call
    string strPlot = GetEventString(eParms, 0);         // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);          // The bit flag # being affected
    object oParty = GetEventCreator(eParms);      // The owner of the plot table for this script
    object oConversationOwner = GetEventObject(eParms, 0); // Owner on the conversation, if any
    int nResult = FALSE; // used to return value for DEFINED GET events
    object oPC = GetHero();
    object oArea = GetArea(oPC);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info



    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {

            case ARL_SIEGE_AREA_ENTERED: //When the player enters the night (battle) village. Starts the fight.
            {
                //Activate and deactivate creatures, equip gear, set teams etc:
                WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_SET_UP_DEFENDERS, TRUE, TRUE);
                CS_LoadCutscene(CUTSCENE_ARL_THE_SUN_SETS, PLT_ARL100PT_SIEGE, ARL_SIEGE_FIGHT_STARTS);

                //Take the canned screenshot of the attack starting
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN, AUTOSS_ARL_NIGHT_BATTLE_BEGINS, TRUE, TRUE);

                break;
            }


            case ARL_SIEGE_SET_UP_DEFENDERS:
            {
                // Qwinn:  Minimized
                // Log_Trace(LOG_CHANNEL_PLOT, "arl100pt_siege", "Entering the siege area, starting the battle.");

                //Clear the player's infamy
                WR_SetPlotFlag(PLT_GEN00PT_STEALING, STEALING_ARL_INFAMY, FALSE);

                int bDwynMilitia = WR_GetPlotFlag(PLT_ARL130PT_RECRUIT_DWYN, ARL_RECRUIT_DWYN_DWYN_HELPING);
                int bLloydMilitia = WR_GetPlotFlag(PLT_ARL150PT_TAVERN_DRINKS, ARL_TAVERN_DRINKS_LLOYD_FIGHTING_WITH_MILITIA);
                int bBerwickMilitia = WR_GetPlotFlag(PLT_ARL150PT_LOGHAIN_SPY, ARL_LOGHAIN_SPY_BERWICK_DEFENDS_VILLAGE);
                // int bShaleActive = WR_GetPlotFlag(PLT_ARL100PT_ACTIVATE_SHALE, ARL_ACTIVATE_SHALE_SHALE_REACTIVATED);
                // int bShaleKnights = WR_GetPlotFlag(PLT_ARL100PT_ACTIVATE_SHALE, ARL_ACTIVATE_SHALE_SHALE_HELPING_PERTH);
                // int bShaleMilitia = WR_GetPlotFlag(PLT_ARL100PT_ACTIVATE_SHALE, ARL_ACTIVATE_SHALE_SHALE_HELPING_MILITIA);
                // int bShaleInParty = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_SHALE_IN_PARTY);
                int bOilSeen = WR_GetPlotFlag(PLT_ARL100PT_OIL_STORES, ARL_OIL_STORES_PC_SEEN_OIL);
                int bPerthToldOil = WR_GetPlotFlag(PLT_ARL100PT_OIL_STORES, ARL_OIL_STORES_PERTH_TOLD_ABOUT_OIL);
                int bPerthGivenOil = WR_GetPlotFlag(PLT_ARL100PT_OIL_STORES, ARL_OIL_STORES_PERTH_USING_OIL);
                int bPlayerKnowsHolyProtection = WR_GetPlotFlag(PLT_ARL100PT_HOLY_AMULET, ARL_HOLY_AMULET_PC_KNOWS_PERTH_WANTS_HOLY_PROT);
                int bPerthUsingAmulets = WR_GetPlotFlag(PLT_ARL100PT_HOLY_AMULET, ARL_HOLY_AMULET_PERTH_HAS_AMULETS);
                int bPerthDeniedAmulets = WR_GetPlotFlag(PLT_ARL100PT_HOLY_AMULET, ARL_HOLY_AMULET_PERTH_DENIED_HELP);

                //Make the defenders friendly so they fight.
                ARL_SetTeamGroup(ARL_TEAM_DWYN, GROUP_FRIENDLY);
                ARL_SetTeamGroup(ARL_TEAM_VILLAGERS, GROUP_FRIENDLY);
                ARL_SetTeamGroup(ARL_TEAM_KNIGHTS, GROUP_FRIENDLY);
                ARL_SetTeamGroup(ARL_TEAM_BERWICK, GROUP_FRIENDLY);
                ARL_SetTeamGroup(ARL_TEAM_LLOYD, GROUP_FRIENDLY);

/*                //if the player found the oil but didn't give tell perth about it, close that quest.
                if ( (bOilSeen== TRUE) && (bPerthToldOil == FALSE) && (bPerthGivenOil == FALSE) )
                {
                    WR_SetPlotFlag(PLT_ARL100PT_OIL_STORES, ARL_OIL_STORES_BATTLE_STARTED, TRUE, TRUE);
                }
*/
                //if the player convinced hannah to let Perth use the amulets, but did not tell perth about it, close the quest.
                /* Qwinn:  Now dealt with in plt_qwinn:ARL_SIEGE_PREP_CLOSE_SUBQUESTS.
                if ( (bPlayerKnowsHolyProtection == TRUE) && (bPerthUsingAmulets == FALSE) && (bPerthDeniedAmulets == FALSE) )
                {
                    WR_SetPlotFlag(PLT_ARL100PT_HOLY_AMULET, ARL_HOLY_AMULET_BATTLE_STARTED, TRUE, TRUE);
                }
                */


                //activates Lloyd if he promised to join the militia and the battle isn't over, and he isn't dead
                if (bLloydMilitia == TRUE)
                {
                    UT_TeamAppears(ARL_TEAM_LLOYD, TRUE);
                    object oLloyd = UT_GetNearestObjectByTag(oPC, ARL_CR_LLOYD);
                    ARL_SiegeGiveItemAndEquip(ARL_R_IT_MILITIA_WEAPON_STANDARD, oLloyd, INVENTORY_SLOT_MAIN, 0);

                }

                //activates Dwyn if he promised to join the militia and the battle isn't over, and he isn't dead
                if (bDwynMilitia == TRUE)
                {
                    UT_TeamAppears(ARL_TEAM_DWYN, TRUE);
                    object oDwyn = UT_GetNearestObjectByTag(oPC, ARL_CR_DWYN);
                    UT_RemoveItemFromInventory(ARL_R_IT_DWYN_LOCKBOX_KEY, 1, oDwyn);
                }

                ///activates Berwick if he promised to join the militia and the battle isn't over, and he isn't dead
                if (bBerwickMilitia == TRUE)
                {
                    UT_TeamAppears(ARL_TEAM_BERWICK, TRUE);
                }

                //Shale can be with the party, helping the knights, helping the militia,
                //innactive, or gone completely.
                //Using a seperate creature for the inactive Shale rather than trying
                //to jump him with the party.
                /* Qwinn:  Deactivating this code, it does nothing
                if (bShaleActive == TRUE)
                {
                    int bSiegeShaleFighting = FALSE;

                    if (bShaleKnights == TRUE)
                    {
                        UT_TeamJump(ARL_TEAM_SIEGE_SHALE, ARL_WP_SIEGE_SHALE_KNIGHTS, TRUE, TRUE, TRUE);
                        bSiegeShaleFighting = TRUE;
                    }
                    if (bShaleMilitia == TRUE)
                    {
                        UT_TeamJump(ARL_TEAM_SIEGE_SHALE, ARL_WP_SIEGE_SHALE_MILITIA, TRUE, TRUE, TRUE);
                        bSiegeShaleFighting = TRUE;
                    }
                    if (bShaleInParty == TRUE)
                    {
                        WR_SetPlotFlag(PLT_ARL100PT_ACTIVATE_SHALE, ARL_ACTIVATE_SHALE_MURDOCK_COMMENTED_ON_SHALE, TRUE);
                    }

                    if (bSiegeShaleFighting == TRUE)
                    {
                        UT_TeamAppears(ARL_TEAM_SIEGE_SHALE, TRUE);
                        ARL_SetTeamGroup(ARL_TEAM_SIEGE_SHALE, GROUP_FRIENDLY);
                        //Stop Murdock commenting on Shale.
                        WR_SetPlotFlag(PLT_ARL100PT_ACTIVATE_SHALE, ARL_ACTIVATE_SHALE_MURDOCK_COMMENTED_ON_SHALE, TRUE);
                    }
                    else
                    {
                        UT_TeamAppears(ARL_TEAM_SIEGE_SHALE, FALSE);
                    }

                }
                else
                {
                    UT_SetTeamInteractive(ARL_TEAM_SIEGE_SHALE, FALSE);
                }
                */

                // Qwinn disabled, being handled in SIEGE_EQUIP_MILITIA with amulets
                // Arl_SiegeApplyMoraleEffects();

                // Qwinn:  Attempting to minimize script calls for compatibility with other mods. Moved the logic
                // from ARL_SIEGE_EQUIP_MILITIA to here and replaced function calls with the actual logic where possible
                // That script shouldn't be called anymore, but still setting flag in case it gets checked anywhere
                // WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_EQUIP_MILITIA, TRUE, TRUE);
                WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_EQUIP_MILITIA, TRUE, FALSE);

                resource rMilitiaMorale = INVALID_RESOURCE;
                // if (WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_MILITIA_MORALE_HIGH)) rMilitiaMorale = R"qw_amu_morale_hi.uti";
                // if (WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_MILITIA_MORALE_LOW)) rMilitiaMorale = R"qw_amu_morale_lo.uti";
                if (Arl_GetMilitiaMorale() >= 2) rMilitiaMorale = R"qw_amu_morale_hi.uti";
                if (Arl_GetMilitiaMorale() <= -1) rMilitiaMorale = R"qw_amu_morale_lo.uti";

                object[] oMilitiaArray = GetTeam(ARL_TEAM_VILLAGERS);
                int nMilitia = GetArraySize(oMilitiaArray);
                int nIndex = 0;
                for (nIndex = 0; nIndex < nMilitia; nIndex++)
                {
                    object oMilitia = oMilitiaArray[nIndex];
                    // Version 3.5 - moving amulet equip into main equip function
                    // ARL_SiegeGiveItemAndEquip(rMilitiaMorale, oMilitia, INVENTORY_SLOT_NECK);
                    // ARL_SiegeEquipMilitiaMember(oMilitia);
                    ARL_SiegeEquipMilitiaMember(oMilitia, rMilitiaMorale);
                }

                /*  Qwinn:  This isn't necessary, the cutscene was changed to a bink movie so the actors don't get equipped anyway
                oMilitiaArray = GetTeam(ARL_TEAM_CUTSCENE_MILITIA);
                nMilitia = GetArraySize(oMilitiaArray);
                nIndex = 0;
                for (nIndex = 0; nIndex < nMilitia; nIndex++)
                {
                    object oMilitia = oMilitiaArray[nIndex];
                    ARL_SiegeEquipMilitiaMember(oMilitia, rMilitiaMorale);       
                }
                */


                // Add morale amulets to knights if acquired
                if (WR_GetPlotFlag(PLT_ARL100PT_HOLY_AMULET, ARL_HOLY_AMULET_PERTH_HAS_AMULETS))
                {
                    resource rKnightMorale = R"qw_amu_morale_hi.uti";
                    object[] oKnightArray = GetTeam(ARL_TEAM_KNIGHTS);
                    int nKnights = GetArraySize(oKnightArray);
                    int nIndex = 0;
                    for (nIndex = 0; nIndex < nKnights; nIndex++)
                    {
                        object oKnight = oKnightArray[nIndex];
                        object oAmulet = UT_AddItemToInventory(rKnightMorale, 1, oKnight);
                        EquipItem(oKnight, oAmulet, INVENTORY_SLOT_NECK, INVALID_WEAPON_SET);
                        SetItemDroppable(oAmulet,FALSE);
                        SetItemIrremovable(oAmulet,TRUE);
                        SetLocalInt(oKnight, FLAG_STOLEN_FROM, TRUE);
                        SetLocalInt(oKnight, "TS_TREASURE_GENERATED", -1);
                    }
                }

                break;
            }

            case ARL_SIEGE_FIGHT_STARTS: //Spawns the creatures and starts the actualy fighting.
            {
                int bTrapActive = WR_GetPlotFlag(PLT_ARL100PT_OIL_STORES, ARL_OIL_STORES_PERTH_USING_OIL);

                int bPlayerStartingAtWindmill = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_PC_FIGHTING_WITH_PERTH);
                int bPlayerStartingAtVillage = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_PC_FIGHTING_WITH_MURDOCK);

                object oPerth = UT_GetNearestCreatureByTag(oPC, ARL_CR_PERTH);

                //Get rid of the cutscene milita
                UT_TeamAppears(ARL_TEAM_CUTSCENE_MILITIA, FALSE);

                //Activate the barricade (not active through cutscene)
                UT_TeamAppears(ARL_TEAM_VILLAGE_BARRICADES, TRUE, OBJECT_TYPE_PLACEABLE);

                //Deactivate Militia1, we'll need him for the half way conversation
                object oMilitia1 = UT_GetNearestCreatureByTag(oPC, ARL_CR_MILITIA_1);
                SetObjectActive(oMilitia1, FALSE);

                //Order the first wave of undead to attack.
                object[] oFirstTeamArray = GetTeam(ARL_TEAM_SIEGE_WINDMILL_CORPSES_1);
                Cli_SetTeamScript(oFirstTeamArray, oArea, 0);
                UT_TeamMove(ARL_TEAM_SIEGE_WINDMILL_CORPSES_1, ARL_WP_SIEGE_WINDMILL_DESTINATION, TRUE);
                Climax_SpawnDarkspawnArmy(GetArea(GetHero()), ARL_TEAM_SIEGE_WINDMILL_CORPSES_1);

                //Start ambient lines for perth
                UT_Talk(oPerth, oPC);

                object[] oFogWPArray = GetNearestObjectByTag(oPC, ARL_WP_SIEGE_FOG, OBJECT_TYPE_WAYPOINT, 50);
                int nIndex = 0;
                int nArraySize = GetArraySize(oFogWPArray);
                effect eFog = EffectVisualEffect(92028);
                for (nIndex = 0; nIndex < nArraySize; nIndex++)
                {
                    object oWP = oFogWPArray[nIndex];
                    location lWP = GetLocation(oWP);
                    Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_PERMANENT, eFog, lWP, 0.0, oWP);
                }

                DoAutoSave();
                break;
            }

            case ARL_SIEGE_INITIATE_LIGHTING_OF_FIRE_TRAP:
            {
                object oKnight2 = UT_GetNearestCreatureByTag(oPC, ARL_CR_KNIGHT_2);
                object oTarget = UT_GetNearestObjectByTag(oKnight2, ARL_IP_FIRE_TRAP_TARGET);
                SwitchWeaponSet(oKnight2, 1);
                WR_AddCommand(oKnight2, CommandAttack(oTarget), FALSE, FALSE, COMMAND_ADDBEHAVIOR_DONTCLEAR);
                //WR_AddCommand(oKnight2, CommandSwitchWeaponSet(), FALSE, FALSE, COMMAND_ADDBEHAVIOR_DONTCLEAR);
                break;
            }


            case ARL_SIEGE_FIRE_TRAP_STARTED:
            {
                object oTarget = UT_GetNearestObjectByTag(oPC, ARL_IP_FIRE_TRAP_TARGET);

                object oFireWP = UT_GetNearestObjectByTag(oTarget, ARL_WP_OIL_TRAP_FIRE);
                location lAOELocation = GetLocation(oFireWP);

                //Removed AOE to prevent coprses pathfinding around it. Uses a trigger - David, March 16 2009
                //effect effFire = EffectAreaOfEffect(AOE_PLOT_ARL_FIRE_TRAP, ARL_R_FIRE_TRAP_SCRIPT, ARL_VFX_FIRE_TRAP_FLAMES);
                //Engine_ApplyEffectAtLocation( EFFECT_DURATION_TYPE_PERMANENT, effFire, lAOELocation, 0.0f, oArea );

                effect effFireVis = EffectVisualEffect(ARL_VFX_FIRE_TRAP_FLAMES);
                Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_PERMANENT, effFireVis, lAOELocation);

                object[] arWoodFires  = GetNearestObjectByTag( oTarget, ARL_IP_SIEGE_BURNING_WOOD, OBJECT_TYPE_PLACEABLE, 20);

                int nIndex = 0;
                float fDelay = 0.1;

                for ( nIndex = 0; nIndex < GetArraySize(arWoodFires); nIndex++ )
                {
                    object oFireTarget = arWoodFires[nIndex];
                    location lWP = GetLocation(oFireTarget);
                    event evFireImpact = Event(ARL_EVENT_FIRE_TRAP_SPREAD);
                    evFireImpact = SetEventLocation(evFireImpact, 0, lWP);

                    DelayEvent(fDelay, oArea, evFireImpact);

                    fDelay += RandomFloat();
                }
                break;
            }


            case ARL_SIEGE_EQUIP_MILITIA:
            {
                // Qwinn:  This shouldn't be used anymore, moved up to ARL_SIEGE_SET_UP_DEFENDERS
                //Loop through the miltia, give them the proper armor.

                // ARL_SiegeEquipMilitiaByTeam(ARL_TEAM_VILLAGERS);
                // ARL_SiegeEquipMilitiaByTeam(ARL_TEAM_CUTSCENE_MILITIA);

                break;
            }


            case ARL_SIEGE_WINDMILL_TEAM_1_DEATH:
            {
                object oMilitia = UT_GetNearestObjectByTag(oPC, ARL_CR_MILITIA_1);
                WR_SetObjectActive(oMilitia, TRUE);
                WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_MID_BATTLE_CONVERSATION, TRUE, TRUE);
                UT_Talk(oMilitia, oPC);
                break;
            }


            case ARL_SIEGE_WINDMILL_TEAM_3_DEATH:
            {
                int bVillageTeamDead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_VILLAGE_TEAM_DEATH);
                if (bVillageTeamDead == TRUE)
                {
                    ARL_SiegeEnd();
                }
                break;
            }


            case ARL_SIEGE_VILLAGE_TEAM_DEATH:
            {
                ARL_SiegeEnd();
                break;
            }


            case ARL_SIEGE_START_SECOND_WAVE:
            {
                /*
                int bKnightsGoToVillage = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_PERTH_GOES_TO_VILLAGE);
                if (bKnightsGoToVillage == TRUE)
                {
                    //Have the knights follow the party
                    object oKnight1 = UT_GetNearestCreatureByTag(oPC, ARL_CR_KNIGHT_1);
                    object oKnight2 = UT_GetNearestCreatureByTag(oPC, ARL_CR_KNIGHT_2);
                    object oKnight3 = UT_GetNearestCreatureByTag(oPC, ARL_CR_KNIGHT_3);
                    object oPerth = UT_GetNearestCreatureByTag(oPC, ARL_CR_PERTH);

                    int bPerthDead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_PERTH_DIED_IN_SIEGE, TRUE);
                    int bKnight1Dead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_KNIGHT_1_DIED_IN_SIEGE, TRUE);
                    int bKnight2Dead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_KNIGHT_2_DIED_IN_SIEGE, TRUE);
                    int bKnight3Dead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_KNIGHT_3_DIED_IN_SIEGE, TRUE);

                    if (bPerthDead == FALSE)
                    {
                        AddNonPartyFollower(oPerth);
                    }
                    if (bKnight1Dead == FALSE)
                    {
                        AddNonPartyFollower(oKnight1);
                    }
                    if (bKnight2Dead == FALSE)
                    {
                        AddNonPartyFollower(oKnight2);
                    }
                    if (bKnight3Dead == FALSE)
                    {
                        AddNonPartyFollower(oKnight3);
                    }


                }
                else
                {
                    //Spawn a trickle of corpses coming from the castle

                }
                */

                UT_TeamAppears(ARL_TEAM_SIEGE_VILLAGE_CORPSES);
                object[] oTeamArray = GetTeam(ARL_TEAM_SIEGE_VILLAGE_CORPSES);
                Cli_SetTeamScript(oTeamArray, oArea);
                UT_TeamMove(ARL_TEAM_SIEGE_VILLAGE_CORPSES, ARL_WP_SIEGE_VILLAGE_DESTINATION, TRUE);
                Climax_SpawnDarkspawnArmy(GetArea(GetHero()), ARL_TEAM_SIEGE_VILLAGE_CORPSES);

                object oMilitia = UT_GetNearestObjectByTag(oPC, ARL_CR_MILITIA_1);
                UT_QuickMoveObject(oMilitia, ARL_WP_SIEGE_MILITIA_1_VILLAGE, TRUE, FALSE, TRUE);
                break;
            }


            case ARL_SIEGE_START_WINDMILL_FLANK_ATTACK:
            {
                int bPathUndefended = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_WINDMILL_PATH_UNDEFENDED);
                if (bPathUndefended == TRUE)
                {
                    //Climax_SpawnDarkspawnArmy(GetArea(GetHero()), ARL_TEAM_SIEGE_WINDMILL_CORPSES_3);
                }
                else
                {
                    Climax_SpawnDarkspawnArmy(GetArea(GetHero()), ARL_TEAM_SIEGE_WINDMILL_CORPSES_2);
                }
                break;
            }


            case ARL_SIEGE_SIEGE_OVER: //Run after getting back to the day version of the village.
            {


                int bMurdockDead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_MURDOCK_DIED_IN_SIEGE, TRUE);
                int bPerthDead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_PERTH_DIED_IN_SIEGE, TRUE);
                int bLloydDead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_LLOYD_DIED_IN_SIEGE, TRUE);
                int bDwynDead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_DWYN_DIED_IN_SIEGE, TRUE);
                int bBerwickDead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_BERWICK_DIED_IN_SIEGE, TRUE);
                int bTomasDead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_TOMAS_DIED_IN_SIEGE, TRUE);
                int bKnight1Dead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_KNIGHT_1_DIED_IN_SIEGE, TRUE);
                int bKnight2Dead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_KNIGHT_2_DIED_IN_SIEGE, TRUE);
                int bKnight3Dead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_KNIGHT_3_DIED_IN_SIEGE, TRUE);
                int bMilitia1Dead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_MILITIA_1_DIED_IN_SIEGE, TRUE);
                int bMilitia2Dead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_MILITIA_2_DIED_IN_SIEGE, TRUE);
                int bMilitia3Dead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_MILITIA_3_DIED_IN_SIEGE, TRUE);
                int bMilitia4Dead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_MILITIA_4_DIED_IN_SIEGE, TRUE);
                int bMilitia5Dead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_MILITIA_5_DIED_IN_SIEGE, TRUE);

                //int bDwynFighting = WR_GetPlotFlag(PLT_ARL130PT_RECRUIT_DWYN, ARL_RECRUIT_DWYN_DWYN_HELPING);

                object oTeagan = UT_GetNearestCreatureByTag(oPC, ARL_CR_TEAGAN);
                object oHannah = UT_GetNearestCreatureByTag(oPC, ARL_CR_HANNAH);

                // If anyone (except Berwick or thugs) died, set flag ARL_SIEGE_OUTCOME_NORMAL,
                // otherwise set ARL_SIEGE_OUTCOME_BEST. No one cares if Berwick dies because
                // he's an elf and a spy.

                UT_RemoveItemFromInventory(ARL_R_IT_SPY_LETTER, 1);

                int bKnightDead = (bKnight1Dead || bKnight2Dead || bKnight3Dead);
                int bMilitiaDead = (bMilitia1Dead || bMilitia2Dead || bMilitia3Dead || bMilitia4Dead || bMilitia5Dead);

                if (bMurdockDead || bPerthDead || bLloydDead || bDwynDead || bTomasDead || bKnightDead || bMilitiaDead)
                {
                    WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_SIEGE_OUTCOME_NORMAL, TRUE, TRUE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_SIEGE_OUTCOME_BEST, TRUE, TRUE);
                }

                //If you didn't find Bevin for Kaitlyn, update the quest as failed.
                int bToldAboutBevin = WR_GetPlotFlag(PLT_ARL110PT_BEVIN_LOST, ARL_BEVIN_LOST_KAITLYN_TOLD_PC_ABOUT_BEVIN, TRUE);
                int bBevinFound = WR_GetPlotFlag(PLT_ARL110PT_BEVIN_LOST, ARL_BEVIN_LOST_BEVIN_FOUND, TRUE);
                if ((bToldAboutBevin == TRUE) && (bBevinFound == FALSE))
                {
                    WR_SetPlotFlag(PLT_ARL110PT_BEVIN_LOST, ARL_BEVIN_LOST_BATTLE_STARTED_BEVIN_NOT_FOUND, TRUE, TRUE);
                }

                //The light_mage_silence plot is now available from the mage box
                WR_SetPlotFlag(PLT_LITE_MAGE_SILENCE, SILENCE_MAGE_BOARD, TRUE);

                // activate Hannah
                WR_SetObjectActive(oHannah, TRUE);

                //Activate ambient villagers for the speech
                UT_TeamAppears(ARL_TEAM_POST_BATTLE_SPEECH_CROWD, TRUE);

                // activate Teagan and make him talk
                //WR_SetObjectActive(oTeagan, TRUE);
                UT_Talk(oTeagan, oPC);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_REDCLIFFE_2a);
                break;
            }


            case ARL_SIEGE_TEAGAN_NOT_REVIVED:
            {
                //object oTeagan = UT_GetNearestCreatureByTag(oPC, ARL_CR_TEAGAN);
                //command cPlayDead = CommandPlayAnimation(BASE_ANIMATION_DEAD_1);
                //WR_AddCommand(oTeagan, cPlayDead);
                break;
            }


            case ARL_SIEGE_TEAGAN_RUNS_OUT_TO_FIND_VILLAGE_DESTROYED:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_REDCLIFFE_2b);
                break;
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case ARL_SIEGE_SIEGE_NOT_OVER:
            {
                int bSiegeOver = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_SIEGE_OVER);
                int bVillageAbandoned = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_VILLAGE_ABANDONED);

                nResult = (bSiegeOver == FALSE) && (bVillageAbandoned == FALSE);
                break;
            }


            case ARL_SIEGE_ALL_WINDMILL_DEFENDERS_DEAD:
            {
                int bPerthDead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_PERTH_DIED_IN_SIEGE);
                int bKnight1Dead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_KNIGHT_1_DIED_IN_SIEGE);
                int bKnight2Dead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_KNIGHT_2_DIED_IN_SIEGE);
                int bKnight3Dead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_KNIGHT_3_DIED_IN_SIEGE);

                int bDwynDead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_DWYN_DIED_IN_SIEGE);
                int bThug1Dead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_THUG_1_DIED_IN_SIEGE);
                int bThug2Dead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_THUG_2_DIED_IN_SIEGE);
                int bBerwickDead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_BERWICK_DIED_IN_SIEGE);

                int bDwynFighting = WR_GetPlotFlag(PLT_ARL130PT_RECRUIT_DWYN, ARL_RECRUIT_DWYN_DWYN_HELPING);
                int bBerwickFighting = WR_GetPlotFlag(PLT_ARL150PT_LOGHAIN_SPY, ARL_LOGHAIN_SPY_BERWICK_DEFENDS_VILLAGE);

                int bDwynGone = (bDwynDead == TRUE) || (bDwynFighting == FALSE);
                int bThug1Gone = (bThug1Dead == TRUE) || (bDwynFighting == FALSE);
                int bThug2Gone = (bThug2Dead == TRUE) || (bDwynFighting == FALSE);
                int bBerwickGone = (bBerwickDead == TRUE) || (bBerwickFighting == FALSE);

                int bAllKnightsDead = (bPerthDead == TRUE) && (bKnight1Dead == TRUE) && (bKnight2Dead == TRUE) && (bKnight3Dead == TRUE);
                int bAllExtrasGone = (bDwynGone == TRUE) && (bThug1Gone == TRUE) && (bThug2Gone == TRUE) && (bBerwickGone == TRUE);

                nResult = (bAllKnightsDead == TRUE) && (bAllExtrasGone == TRUE);
                break;
            }


        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}