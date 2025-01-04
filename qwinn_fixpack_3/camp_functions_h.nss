#include "party_h"
#include "utility_h"
#include "wrappers_h"
#include "plt_gen00pt_party"
#include "sys_rewards_h"
#include "sys_ambient_h"
#include "camp_constants_h"

const string WP_CAMP_FOLLOWER_PREFIX = "wp_camp_";

void Camp_ActivateShrieks()
{

    object  [] arParty      =   GetPartyPoolList();
    object  [] arShrieks    =   UT_GetAllObjectsInAreaByTag(CAMP_SHRIEK_ATTACKER_NORM, OBJECT_TYPE_CREATURE);

    int     nPartySize      =   GetArraySize(arParty);
    int     nIndex;

    for(nIndex = 0; nIndex < nPartySize; nIndex++)
    {

        // Max 4 Normal Shrieks.
        if( nIndex >= 3 )
        {
            return;
        }

        else
        {
            object oAttacker = arShrieks[nIndex];

            if( !IsInvalidDeadOrDying(oAttacker) )
            {

                WR_SetObjectActive(oAttacker, TRUE);

                SetTeamId(oAttacker, CAMP_TEAM_DARKSPAWN_CAMP_ATTACKERS);

                Log_Trace(LOG_CHANNEL_PLOT, "Activating normal shriek #: ", IntToString(nIndex + 1));

            }

        }

    }

}

void Camp_FollowerAmbient(object oFollower, int bStart)
{

    string  sTag    =   GetTag(oFollower);
    string  sArea   =   GetTag(GetArea(oFollower));

    Log_Trace(LOG_CHANNEL_PLOT, "Follower: " + sTag, "Found in Area: " + sArea);

    // No movement phase, just animation.
    SetLocalInt(oFollower, AMBIENT_ANIM_STATE, AMBIENT_ANIM_RESET);

    int     nAnim;

    // Set ambient system variables
    if(bStart)
    {

        // The Redcliff Castle main floor - climax.
        // Alistair, Loghain and Morrigan are not in this area.
        if(sTag == CAM_CASTLE_CLIMAX)
        {

            if     (sTag == GEN_FL_DOG)         nAnim   =   4;      // Relaxed.
            else if(sTag == GEN_FL_WYNNE)       nAnim   =   85;     // Listener Passive 3
            else if(sTag == GEN_FL_STEN)        nAnim   =   19;     // Arms crossed.
            else if(sTag == GEN_FL_ZEVRAN)      nAnim   =   67;     // Bored Loitering 1
            else if(sTag == GEN_FL_OGHREN)      nAnim   =   103;    // Bored Stationary.
            else if(sTag == GEN_FL_LELIANA)     nAnim   =   14;     // Listener Passive 2

            Ambient_Start(oFollower, AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_NONE, AMBIENT_MOVE_PREFIX_NONE, nAnim, AMBIENT_ANIM_FREQ_ORDERED);

        }

        // If in the party camp.
        else/*((sTag == CAM_AR_ARCH1) || (sTag == CAM_AR_CAMP_PLAINS) || (sTag == CAM_AR_ARCH3))*/
        {

            if     (sTag == GEN_FL_DOG)         nAnim   =   4;      // Relaxed.
            else if(sTag == GEN_FL_WYNNE)       nAnim   =   85;     // Listener Passive 3
            else if(sTag == GEN_FL_STEN)        nAnim   =   24;     // Guard Wander Left and Right
            else if(sTag == GEN_FL_ZEVRAN)      nAnim   =   67;     // Bored Loitering 1
            else if(sTag == GEN_FL_OGHREN)      nAnim   =   103;    // Bored Stationary
            else if(sTag == GEN_FL_LELIANA)     nAnim   =   71;     // Chat by fire.
            else if(sTag == GEN_FL_MORRIGAN)    nAnim   =   70;     // Warm by fire.
            else if(sTag == GEN_FL_ALISTAIR)    nAnim   =   100;    // Squat by fire.
            else if(sTag == GEN_FL_LOGHAIN)     nAnim   =   68;     // Bored Loitering 2

            Ambient_Start(oFollower, AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_NONE, AMBIENT_MOVE_PREFIX_NONE, nAnim, AMBIENT_ANIM_FREQ_ORDERED);

        }

        Log_Trace(LOG_CHANNEL_PLOT, "Starting Ambient Animations for: " + sTag, "Playing Animation: " + IntToString(nAnim));

    }

    else
    {

        Ambient_Stop(oFollower);

    }

}

void Camp_PlaceFollowersInCamp()
{
    object oAlistair = Party_GetFollowerByTag(GEN_FL_ALISTAIR);
    object oMorrigan = Party_GetFollowerByTag(GEN_FL_MORRIGAN);
    object oDog = Party_GetFollowerByTag(GEN_FL_DOG);
    object oWynne = Party_GetFollowerByTag(GEN_FL_WYNNE);
    object oShale = Party_GetFollowerByTag(GEN_FL_SHALE);
    object oSten = Party_GetFollowerByTag(GEN_FL_STEN);
    object oZevran = Party_GetFollowerByTag(GEN_FL_ZEVRAN);
    object oOghren = Party_GetFollowerByTag(GEN_FL_OGHREN);
    object oLeliana = Party_GetFollowerByTag(GEN_FL_LELIANA);
    object oLoghain = Party_GetFollowerByTag(GEN_FL_LOGHAIN);


    // Activating any followers that are in the party


    if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_ALISTAIR_RECRUITED))
    {
        WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_CAMP, TRUE, TRUE);
        WR_SetObjectActive(oAlistair, TRUE);
    }
    if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_DOG_RECRUITED))
    {
        WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_CAMP, TRUE, TRUE);
        WR_SetObjectActive(oDog, TRUE);
    }
    if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_WYNNE_RECRUITED))
    {
        WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_CAMP, TRUE, TRUE);
        WR_SetObjectActive(oWynne, TRUE);
    }
    if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_SHALE_RECRUITED))
    {
        WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_SHALE_IN_CAMP, TRUE, TRUE);
        WR_SetObjectActive(oShale, TRUE);
    }
    if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_STEN_RECRUITED))
    {
        WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_STEN_IN_CAMP, TRUE, TRUE);
        WR_SetObjectActive(oSten, TRUE);
    }
    if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_ZEVRAN_RECRUITED))
    {
        WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_CAMP, TRUE, TRUE);
        WR_SetObjectActive(oZevran, TRUE);
    }
    if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_OGHREN_RECRUITED))
    {
        WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_OGHREN_IN_CAMP, TRUE, TRUE);
        WR_SetObjectActive(oOghren, TRUE);
    }
    if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_LELIANA_RECRUITED))
    {
        WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_IN_CAMP, TRUE, TRUE);
        WR_SetObjectActive(oLeliana, TRUE);
    }
    if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_MORRIGAN_RECRUITED))
    {
        WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_IN_CAMP, TRUE, TRUE);
        WR_SetObjectActive(oMorrigan, TRUE);
    }
    if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_LOGHAIN_RECRUITED))
    {
        WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_LOGHAIN_IN_CAMP, TRUE, TRUE);
        WR_SetObjectActive(oLoghain, TRUE);
    }


    // Place all active party members in their spots
    object [] arParty = GetPartyPoolList();
    int nSize = GetArraySize(arParty);
    int i;
    object oCurrent;
    string sWP;
    object oWP;
    int nXP;
    int nHeroXP = GetExperience(GetHero());
//    int nMinFollowerXP = FloatToInt(MIN_CAMP_FOLLOWER_XP * IntToFloat(nHeroXP));

    // first, remove all map pins (in case someone left the group)
    object [] arPins = GetObjectsInArea(OBJECT_SELF);
    int nObjectsSize = GetArraySize(arPins);
    int j;
    object oCurrentObject;
    for(j = 0; j < nObjectsSize; j++)
    {
        oCurrentObject = arPins[j];
        if(GetObjectType(oCurrentObject) == OBJECT_TYPE_WAYPOINT && StringLeft(GetTag(oCurrentObject), 8) == WP_CAMP_FOLLOWER_PREFIX)
            SetMapPinState(oCurrentObject, FALSE);
    }


    // then add the proper ones

    for(i = 0; i < nSize; i++)
    {
        oCurrent = arParty[i];
        if(GetObjectActive(oCurrent) && !IsHero(oCurrent))
        {
            sWP = WP_CAMP_FOLLOWER_PREFIX + GetTag(oCurrent);
            UT_LocalJump(oCurrent, sWP);
            oWP = GetObjectByTag(sWP);
            SetMapPinState(oWP, TRUE);
            SetImmortal(oCurrent, TRUE);
            nXP = GetExperience(oCurrent);
            RW_CatchUpToPlayer(oCurrent);
            SetLocalInt(oCurrent, FLAG_STOLEN_FROM, TRUE);

            // Start the follower ambient system.
            Camp_FollowerAmbient(oCurrent, TRUE);

        }
    }

}