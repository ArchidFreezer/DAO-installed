//:://////////////////////////////////////////////
/*
    party checks
*/
//:://////////////////////////////////////////////
//:: Created By: Yaron
//:: Created On: July 11th, 2006
//:://////////////////////////////////////////////


#include "plt_gen00pt_party"
#include "utility_h"
//included in achievement_core_h; #include "wrappers_h"
#include "global_objects_h"
#include "plot_h"
#include "party_h"
#include "events_h"
#include "approval_h"

#include "achievement_core_h"

void CheckRecruiterAchievement()
{
    // Check for "all recruited"
    int bAlistair = GetHasAchievementByID(ACH_FAKE_RECRUITER_ALISTAIR);
    int bMorrigan = GetHasAchievementByID(ACH_FAKE_RECRUITER_MORRIGAN);
    int bWynne = GetHasAchievementByID(ACH_FAKE_RECRUITER_WYNNE);
    int bZevran = GetHasAchievementByID(ACH_FAKE_RECRUITER_ZEVRAN);
    int bOghren = GetHasAchievementByID(ACH_FAKE_RECRUITER_OGHREN);
    int bDog = GetHasAchievementByID(ACH_FAKE_RECRUITER_DOG);
    int bLeliana = GetHasAchievementByID(ACH_FAKE_RECRUITER_LELIANA);
    int bSten = GetHasAchievementByID(ACH_FAKE_RECRUITER_STEN);
    int bLoghain = GetHasAchievementByID(ACH_FAKE_RECRUITER_LOGHAIN);

    // Log Block :: /////////////////////////////////////////////////////
    if (bAlistair) ACH_LogTrace(LOG_CHANNEL_REWARDS, "Alistair is recruited");
    if (bMorrigan) ACH_LogTrace(LOG_CHANNEL_REWARDS, "Morrigan is recruited");
    if (bWynne) ACH_LogTrace(LOG_CHANNEL_REWARDS, "Wynne is recruited");
    if (bZevran) ACH_LogTrace(LOG_CHANNEL_REWARDS, "Zevran is recruited");
    if (bOghren) ACH_LogTrace(LOG_CHANNEL_REWARDS, "Oghren is recruited");
    if (bDog) ACH_LogTrace(LOG_CHANNEL_REWARDS, "Dog is recruited");
    if (bLeliana) ACH_LogTrace(LOG_CHANNEL_REWARDS, "Leliana is recruited");
    if (bSten) ACH_LogTrace(LOG_CHANNEL_REWARDS, "Sten is recruited");
    if (bLoghain) ACH_LogTrace(LOG_CHANNEL_REWARDS, "Loghain is recruited");
    // End Log Block :: /////////////////////////////////////////////////

    if ( (bAlistair) && (bMorrigan) && (bWynne) && (bZevran) && (bOghren) && (bDog) && (bLeliana) && (bSten) && (bLoghain) )
    {
        WR_UnlockAchievement(ACH_COLLECT_RECRUITER, TRUE, TRUE);
    }
}

void SetFollowerInParty(object oFollower, string sPlot, int nFlag)
{
    WR_SetPlotFlag(sPlot, nFlag, FALSE);
    WR_SetObjectActive(oFollower, TRUE);
    WR_SetFollowerState(oFollower, FOLLOWER_STATE_ACTIVE, TRUE);
    command cJump = CommandJumpToObject(GetPartyLeader());
    WR_AddCommand(oFollower, cJump);
}

void SetFollowerRecruited(object oFollower, int nValue, string sPlot, int nCampFlag, int nPartyFlag, int nShowPartyPicker, int nForceAddToParty = FALSE)
{
    Log_Trace(LOG_CHANNEL_SYSTEMS, "SetFollowerRecruited", "Value: " + IntToString(nValue) + ", sPlot: " + sPlot +
        ", nShowPartyPicker: " + IntToString(nShowPartyPicker));
    string sFollower = GetTag(oFollower);
    object oPC = GetPartyLeader();
    object oArea = GetArea(oPC);
    if(nValue == TRUE)
    {
        SetTeamId(oFollower, -1);
        SetFollowerApprovalEnabled(oFollower, TRUE);
        SetFollowerApprovalDescription(oFollower, 371487);
        if(GetTag(oFollower) == GEN_FL_DOG)
        {
            AdjustFollowerApproval(oFollower, 100);
            SetFollowerApprovalDescription(oFollower, 371489);
        }

        if(nForceAddToParty)
        {
            // Clearing active party so there won't be 1+4 party members
            if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_ALISTAIR_RECRUITED))
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_CAMP, TRUE, TRUE);
            if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_DOG_RECRUITED))
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_CAMP, TRUE, TRUE);
            if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_SHALE_RECRUITED))
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_SHALE_IN_CAMP, TRUE, TRUE);
            if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_STEN_RECRUITED))
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_STEN_IN_CAMP, TRUE, TRUE);
            if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_ZEVRAN_RECRUITED))
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_CAMP, TRUE, TRUE);
            if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_OGHREN_RECRUITED))
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_OGHREN_IN_CAMP, TRUE, TRUE);
            if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_LELIANA_RECRUITED))
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_IN_CAMP, TRUE, TRUE);
            if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_MORRIGAN_RECRUITED))
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_IN_CAMP, TRUE, TRUE);
            if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_WYNNE_RECRUITED))
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_CAMP, TRUE, TRUE);
            if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_LOGHAIN_RECRUITED))
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_LOGHAIN_IN_CAMP, TRUE, TRUE);

            WR_SetPlotFlag(sPlot, nPartyFlag, TRUE, TRUE); // Setting locked followers's in-party flag here since it won't be trigger using the GUI
            WR_SetFollowerState(oFollower, FOLLOWER_STATE_LOCKEDACTIVE, FALSE);
        }
        else // not locked into party - set follower to be available for adding into party
        {
             WR_SetFollowerState(oFollower, FOLLOWER_STATE_AVAILABLE, FALSE);
        }


        if(nShowPartyPicker)
        {
            // Party picker GUI is triggered in player_core, through the event
        }
        else if(!nShowPartyPicker)
        {
            WR_SetFollowerState(oFollower, FOLLOWER_STATE_ACTIVE, FALSE);
            WR_SetPlotFlag(sPlot, nPartyFlag, TRUE);
        }
        Log_Trace(LOG_CHANNEL_SYSTEMS, "SetFollowerRecruited", "Setting follower script to player_core and calling hired event, showpartypicker = " + IntToString(nShowPartyPicker));
        SetEventScript(oFollower, RESOURCE_SCRIPT_PLAYER_CORE); // needed for sending the hired event, below
        SendPartyMemberHiredEvent(oFollower, nShowPartyPicker);
    }
    else // clearing the flag -> follower leaves for good
    {
        WR_SetFollowerState(oFollower, FOLLOWER_STATE_INVALID);
        WR_SetPlotFlag(sPlot, nCampFlag, FALSE);
        WR_SetPlotFlag(sPlot, nPartyFlag, FALSE);
        WR_SetObjectActive(oFollower, FALSE);

        // clear approval romance flag
        int nFollower = Approval_GetFollowerIndex(oFollower);
        Approval_SetRomanceActive(nFollower, FALSE);

        // clear gift codex (so it won't appear as the last entry)
        // Qwinn:  Changed "OBJECT_SELF" to "oFollower" in the following.
        // Unfortunately removal of entry doesn't happen until you load a save game
        if(GetTag(oFollower) == GEN_FL_ALISTAIR)
            WR_SetPlotFlag("cod_cha_alistair", 8, FALSE,TRUE);
        else if(GetTag(oFollower) == GEN_FL_MORRIGAN)
            WR_SetPlotFlag("cod_cha_morrigan", 6, FALSE,TRUE);
        else if(GetTag(oFollower) == GEN_FL_WYNNE)
            WR_SetPlotFlag("cod_cha_wynne", 7, FALSE,TRUE);
        else if(GetTag(oFollower) == GEN_FL_STEN)
            WR_SetPlotFlag("cod_cha_sten", 5, FALSE,TRUE);
        else if(GetTag(oFollower) == GEN_FL_ZEVRAN)
            WR_SetPlotFlag("cod_cha_zevran", 10, FALSE,TRUE);
        else if(GetTag(oFollower) == GEN_FL_OGHREN)
            WR_SetPlotFlag("cod_cha_oghren", 5, FALSE,TRUE);
        else if(GetTag(oFollower) == GEN_FL_LELIANA)
            WR_SetPlotFlag("cod_cha_leliana", 10, FALSE,TRUE);
        else if(GetTag(oFollower) == GEN_FL_LOGHAIN)
            WR_SetPlotFlag("cod_cha_loghain", 11, FALSE,TRUE);
    }

}



int StartingConditional()
{
    event eParms = GetCurrentEvent();                // Contains all input parameters
    int nType = GetEventType(eParms);               // GET or SET call
    string strPlot = GetEventString(eParms, 0);         // Plot GUID
    int nBitFlag = GetEventInteger(eParms, 1);          // The bit flag # being affected
    object oParty = GetEventCreator(eParms);      // The owner of the plot table for this script
    object oConversationOwner = GetEventObject(eParms, 0);
    int nResult = FALSE;

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    object oPC = GetPartyLeader();

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value


        switch(nBitFlag)
        {
            case GEN_PARTY_STORE:
            {
                UT_PartyStore();
                break;
            }
            case GEN_PARTY_RESTORE:
            {
                UT_PartyRestore();
                break;
            }
            case GEN_ALISTAIR_RECRUITED:
            {
                //only show the tutorial when recruited
                object oAlistair = Party_GetFollowerByTag(GEN_FL_ALISTAIR);
                SetFollowerRecruited(oAlistair, nValue, strPlot, GEN_ALISTAIR_IN_CAMP, GEN_ALISTAIR_IN_PARTY, FALSE);

                if (nValue == TRUE)
                {
                    // Set fake achievement
                    WR_UnlockAchievement(ACH_FAKE_RECRUITER_ALISTAIR, FALSE);
                    CheckRecruiterAchievement();
                }
                break;
            }
            case GEN_ALISTAIR_IN_PARTY:
            {
                object oAlistair = Party_GetFollowerByTag(GEN_FL_ALISTAIR);
                SetFollowerInParty(oAlistair, strPlot, GEN_ALISTAIR_IN_CAMP);
                break;
            }
            case GEN_ALISTAIR_IN_CAMP:
            {
                object oAlistair = Party_GetFollowerByTag(GEN_FL_ALISTAIR);
                Party_SetFollowerInCamp(oAlistair, GEN_ALISTAIR_IN_PARTY);
                break;
            }
            case GEN_MORRIGAN_RECRUITED:
            {
                object oMorrigan = Party_GetFollowerByTag(GEN_FL_MORRIGAN);

                SetFollowerRecruited(oMorrigan, nValue, strPlot, GEN_MORRIGAN_IN_CAMP, GEN_MORRIGAN_IN_PARTY, FALSE);
                // Set fake achievement
                WR_UnlockAchievement(ACH_FAKE_RECRUITER_MORRIGAN, FALSE);
                CheckRecruiterAchievement();

                break;
            }
            case GEN_MORRIGAN_IN_PARTY:
            {
                object oMorrigan = Party_GetFollowerByTag(GEN_FL_MORRIGAN);

                SetFollowerInParty(oMorrigan, strPlot, GEN_MORRIGAN_IN_CAMP);
                break;
            }
            case GEN_MORRIGAN_IN_CAMP:
            {
                object oMorrigan = Party_GetFollowerByTag(GEN_FL_MORRIGAN);

                Party_SetFollowerInCamp(oMorrigan, GEN_MORRIGAN_IN_PARTY);
                break;
            }
            case GEN_WYNNE_RECRUITED:
            {
                object oWynne = Party_GetFollowerByTag(GEN_FL_WYNNE);

                SetFollowerRecruited(oWynne, nValue, strPlot, GEN_WYNNE_IN_CAMP, GEN_WYNNE_IN_PARTY, TRUE, TRUE);
                // Set fake achievement
                WR_UnlockAchievement(ACH_FAKE_RECRUITER_WYNNE, FALSE);
                CheckRecruiterAchievement();
                break;
            }
            case GEN_WYNNE_IN_PARTY:
            {
                object oWynne = Party_GetFollowerByTag(GEN_FL_WYNNE);

                SetFollowerInParty(oWynne, strPlot, GEN_WYNNE_IN_CAMP);
                break;
            }
            case GEN_WYNNE_IN_CAMP:
            {
                object oWynne = Party_GetFollowerByTag(GEN_FL_WYNNE);

                Party_SetFollowerInCamp(oWynne, GEN_WYNNE_IN_PARTY);
                break;
            }
            case GEN_ZEVRAN_RECRUITED:
            {
                object oZevran = Party_GetFollowerByTag(GEN_FL_ZEVRAN);

                SetFollowerRecruited(oZevran, nValue, strPlot, GEN_ZEVRAN_IN_CAMP, GEN_ZEVRAN_IN_PARTY, TRUE);
                // Set fake achievement
                WR_UnlockAchievement(ACH_FAKE_RECRUITER_ZEVRAN, FALSE);
                CheckRecruiterAchievement();
                break;
            }
            case GEN_ZEVRAN_IN_PARTY:
            {
                object oZevran = Party_GetFollowerByTag(GEN_FL_ZEVRAN);

                SetFollowerInParty(oZevran, strPlot, GEN_ZEVRAN_IN_CAMP);
                break;
            }
            case GEN_ZEVRAN_IN_CAMP:
            {
                object oZevran = Party_GetFollowerByTag(GEN_FL_ZEVRAN);

                Party_SetFollowerInCamp(oZevran, GEN_ZEVRAN_IN_PARTY);
                break;
            }
            case GEN_OGHREN_RECRUITED:
            {
                object oOghren = Party_GetFollowerByTag(GEN_FL_OGHREN);

                SetFollowerRecruited(oOghren, nValue, strPlot, GEN_OGHREN_IN_CAMP, GEN_OGHREN_IN_PARTY, TRUE);
                // Set fake achievement
                WR_UnlockAchievement(ACH_FAKE_RECRUITER_OGHREN, FALSE);
                CheckRecruiterAchievement();
                break;
            }
            case GEN_OGHREN_IN_PARTY:
            {
                object oOghren = Party_GetFollowerByTag(GEN_FL_OGHREN);

                SetFollowerInParty(oOghren, strPlot, GEN_OGHREN_IN_CAMP);
                break;
            }
            case GEN_OGHREN_IN_CAMP:
            {
                object oOghren = Party_GetFollowerByTag(GEN_FL_OGHREN);

                Party_SetFollowerInCamp(oOghren, GEN_OGHREN_IN_PARTY);
                break;
            }
            case GEN_SHALE_RECRUITED:
            {
                object oShale = Party_GetFollowerByTag(GEN_FL_SHALE);

                SetFollowerRecruited(oShale, nValue, strPlot, GEN_SHALE_IN_CAMP, GEN_SHALE_IN_PARTY, TRUE);

                break;
            }
            case GEN_SHALE_IN_PARTY:
            {
                object oShale = Party_GetFollowerByTag(GEN_FL_SHALE);

                SetFollowerInParty(oShale, strPlot, GEN_SHALE_IN_CAMP);
                break;
            }
            case GEN_SHALE_IN_CAMP:
            {
                object oShale = Party_GetFollowerByTag(GEN_FL_SHALE);

                Party_SetFollowerInCamp(oShale, GEN_SHALE_IN_PARTY);
                break;
            }
            case GEN_DOG_RECRUITED:
            {
                object oDog = Party_GetFollowerByTag(GEN_FL_DOG);

                SetFollowerRecruited(oDog, nValue, strPlot, GEN_DOG_IN_CAMP, GEN_DOG_IN_PARTY, FALSE);
                // Set fake achievement
                WR_UnlockAchievement(ACH_FAKE_RECRUITER_DOG, FALSE);
                CheckRecruiterAchievement();
                break;
            }
            case GEN_DOG_IN_PARTY:
            {
                object oDog = Party_GetFollowerByTag(GEN_FL_DOG);

                SetFollowerInParty(oDog, strPlot, GEN_DOG_IN_CAMP);
                break;
            }
            case GEN_DOG_IN_CAMP:
            {
                object oDog = Party_GetFollowerByTag(GEN_FL_DOG);

                Party_SetFollowerInCamp(oDog, GEN_DOG_IN_PARTY);
                break;
            }
            case GEN_LELIANA_RECRUITED:
            {
                object oLeliana = Party_GetFollowerByTag(GEN_FL_LELIANA);

                SetFollowerRecruited(oLeliana, nValue, strPlot, GEN_LELIANA_IN_CAMP, GEN_LELIANA_IN_PARTY, TRUE);
                // Set fake achievement
                WR_UnlockAchievement(ACH_FAKE_RECRUITER_LELIANA, FALSE);
                CheckRecruiterAchievement();
                break;
            }
            case GEN_LELIANA_IN_PARTY:
            {
                object oLeliana = Party_GetFollowerByTag(GEN_FL_LELIANA);

                SetFollowerInParty(oLeliana, strPlot, GEN_LELIANA_IN_CAMP);
                break;
            }
            case GEN_LELIANA_IN_CAMP:
            {
                object oLeliana = Party_GetFollowerByTag(GEN_FL_LELIANA);

                Party_SetFollowerInCamp(oLeliana, GEN_LELIANA_IN_PARTY);
                break;
            }
            case GEN_STEN_RECRUITED:
            {
                object oSten = Party_GetFollowerByTag(GEN_FL_STEN);

                SetFollowerRecruited(oSten, nValue, strPlot, GEN_STEN_IN_CAMP, GEN_STEN_IN_PARTY, TRUE);
                // Set fake achievement
                WR_UnlockAchievement(ACH_FAKE_RECRUITER_STEN, FALSE);
                CheckRecruiterAchievement();
                break;
            }
            case GEN_STEN_IN_PARTY:
            {
                object oSten = Party_GetFollowerByTag(GEN_FL_STEN);

                SetFollowerInParty(oSten, strPlot, GEN_STEN_IN_CAMP);
                break;
            }
            case GEN_STEN_IN_CAMP:
            {
                object oSten = Party_GetFollowerByTag(GEN_FL_STEN);

                Party_SetFollowerInCamp(oSten, GEN_STEN_IN_PARTY);
                break;
            }
            case GEN_LOGHAIN_RECRUITED:
            {
                object oLoghain = Party_GetFollowerByTag(GEN_FL_LOGHAIN);

                SetFollowerRecruited(oLoghain, nValue, strPlot, GEN_LOGHAIN_IN_CAMP, GEN_LOGHAIN_IN_PARTY, FALSE);
                // Set fake achievement
                WR_UnlockAchievement(ACH_FAKE_RECRUITER_LOGHAIN, FALSE);
                CheckRecruiterAchievement();

                break;
            }
            case GEN_LOGHAIN_IN_PARTY:
            {
                object oLoghain = Party_GetFollowerByTag(GEN_FL_LOGHAIN);

                SetFollowerInParty(oLoghain, strPlot, GEN_LOGHAIN_IN_CAMP);
                break;
            }
            case GEN_LOGHAIN_IN_CAMP:
            {
                object oLoghain = Party_GetFollowerByTag(GEN_FL_LOGHAIN);

                Party_SetFollowerInCamp(oLoghain, GEN_LOGHAIN_IN_PARTY);
                break;
            }
            case GEN_HIRE_FOLLOWER:
            {
                UT_HireFollower(oConversationOwner);
                break;
            }
            case GEN_FIRE_FOLLOWER:
            {
                UT_FireFollower(oConversationOwner);
                break;
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        switch(nBitFlag)
        {
            case GEN_PARTY_HAS_WEAPONS_DRAWN:
            {
                // TBD
                break;
            }
            case GEN_PARTY_SIZE_2:
            {
                // party size must be exactly 2
                // party size 1 is only the player
                object [] arParty = GetPartyList(oPC);
                if(GetArraySize(arParty) == 2)
                    nResult = TRUE;
                break;
            }
            case GEN_PARTY_SIZE_3:
            {
                // party size must be exactly 3
                // party size 1 is only the player
                object [] arParty = GetPartyList(oPC);
                if(GetArraySize(arParty) == 3)
                    nResult = TRUE;
                break;
            }
            case GEN_PARTY_SIZE_4:
            {
                // party size must be exactly 4
                // party size 1 is only the player
                object [] arParty = GetPartyList(oPC);
                if(GetArraySize(arParty) == 4)
                    nResult = TRUE;
                break;
            }
            case GEN_PLAYER_ALONE:
            {
                object [] arParty = GetPartyList();
                if(GetArraySize(arParty) == 1)
                    nResult = TRUE;
                break;
            }
            case GEN_PLAYER_HAS_PARTY:
            {
                // party size must be 2 or more.
                // party size 1 is only the player
                object [] arParty = GetPartyList(oPC);
                if(GetArraySize(arParty) > 1)
                    nResult = TRUE;
                break;
            }
            case GEN_ALISTAIR_SPEAKING:
            {
                nResult = GetTag(oConversationOwner) == GEN_FL_ALISTAIR;
                break;
            }
            case GEN_DOG_SPEAKING:
            {
                nResult = GetTag(oConversationOwner) == GEN_FL_DOG;
                break;
            }
            case GEN_LELIANA_SPEAKING:
            {
                nResult = GetTag(oConversationOwner) == GEN_FL_LELIANA;

                break;
            }
            case GEN_LOGHAIN_SPEAKING:
            {
                nResult = GetTag(oConversationOwner) == GEN_FL_LOGHAIN;

                break;
            }
            case GEN_MORRIGAN_SPEAKING:
            {
                nResult = GetTag(oConversationOwner) == GEN_FL_MORRIGAN;

                break;
            }
            case GEN_OGHREN_SPEAKING:
            {
                nResult = GetTag(oConversationOwner) == GEN_FL_OGHREN;

                break;
            }
            case GEN_SHALE_SPEAKING:
            {
                nResult = GetTag(oConversationOwner) == GEN_FL_SHALE;

                break;
            }
            case GEN_STEN_SPEAKING:
            {
                nResult = GetTag(oConversationOwner) == GEN_FL_STEN;

                break;
            }
            case GEN_WYNNE_SPEAKING:
            {
                nResult = GetTag(oConversationOwner) == GEN_FL_WYNNE;

                break;
            }
            case GEN_ZEVRAN_SPEAKING:
            {
                nResult = GetTag(oConversationOwner) == GEN_FL_ZEVRAN;

                break;
            }
        }

    }
    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}