// This script is called on entry to Lothering, by PRCSCR_bpsk.GDA.
// It places an entrance to Spider Cave near to the spiders.
// Additionally, the script handles the party's return from the cave,
// as it is not possible to dynamically create a waypoint.
//
#include "utility_h"
#include "wrappers_h"
#include "plt_mnp000pt_main_lothering"
#include "plt_bp_spiders_knives"
#include "plt_bpsk_rescue_knives"

//--------------------------------------------------------------------------------------------------
// FUNCTIONS
//--------------------------------------------------------------------------------------------------
/**
* @brief Sets the position of each party member
* @param vPosition - a position vector containing the new coordinates for the party
* @param bSafePosition - TRUE, if a safe position should be calculated and used, or FALSE
* @remarks If a safe position cannot be found and the bSafePosition flag is set to TRUE, the function will fail.
* @author Sunjammer
**/
void Party_SetPosition(vector vPosition, int bSafePosition = TRUE)
{
    int nPartyMember;
    object[] oPartyMembers = GetPartyList(GetPartyLeader());
    int nPartyMembers = GetArraySize(oPartyMembers);
    for(nPartyMember = 0; nPartyMember < nPartyMembers; nPartyMember++)
    {
        SetPosition(oPartyMembers[nPartyMember], vPosition, bSafePosition);
    }
}
//--------------------------------------------------------------------------------------------------
// MAIN
//--------------------------------------------------------------------------------------------------

void main()
{
    if (!WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_CAVE_ENTRANCE_PLACED))
    {

        object oPC = GetHero();
        vector vCave = [384.5, 302.2, 0.7];
        location lCave = Location(GetArea(oPC),vCave, 50.0);
        object oEntrance = CreateObject(OBJECT_TYPE_PLACEABLE,R"bpsk_to_cave.utp",lCave);
        WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_CAVE_ENTRANCE_PLACED,TRUE);

//        DisplayFloatyMessage(oPC,"Cave entrance in place.",FLOATY_MESSAGE,0xff0000,10.0);
    }

    // Mark cave if quest begun, or Chantry if almost complete
    if ((WR_GetPlotFlag(PLT_BPSK_RESCUE_KNIVES,KNIVES_QUEST_ACCEPTED)) &&
        !(WR_GetPlotFlag(PLT_BPSK_RESCUE_KNIVES,KNIVES_REWARD_GIVEN)))
    {
        object oCave = GetObjectByTag("bpsk_to_cave");
        SetPlotGiver(oCave,TRUE);
        if (WR_GetPlotFlag(PLT_BPSK_RESCUE_KNIVES,KNIVES_FATHER_FOUND))
        {
            object oChantry = GetObjectByTag("lot100ip_to_chantry");
            SetPlotGiver(oChantry,TRUE);
            SetPlotGiver(oCave,FALSE);
        }
    }

    // Sort out return position from cave - needs to be 'safe' else party ends up stranded
    if (WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_CAVE_ENTERED))
    {
        Party_SetPosition(Vector(387.0,303.0,1.17),TRUE);
        WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_CAVE_ENTERED,FALSE);
    }

    // Return from Knife Edge to southern road, if northern entrance not cleared
    if ((WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_MANOR_ENTERED)) &&
        !(WR_GetPlotFlag(PLT_MNP000PT_MAIN_LOTHERING,MAIN_LOTHERING_PC_CROSSED_LOTHERING)))
    {
        UT_LocalJump(GetHero(),"wmw_lot_south");
        WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_MANOR_ENTERED,FALSE);
    }

}