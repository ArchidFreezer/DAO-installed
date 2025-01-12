//::///////////////////////////////////////////////
//:: epi_attendees_h
//:: Copyright (c) 2008 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Functions to trigger proper
    attendees for the Epilogue
*/
//:://////////////////////////////////////////////
//:: Created By: Mark Barazzuol
//:: Created On: June 12, 2008
//:://////////////////////////////////////////////

#include "utility_h"
#include "epi_constants_h"
#include "camp_constants_h"

#include "plt_arl100pt_enter_castle"
#include "plt_arl200pt_remove_demon"
#include "plt_bdn100pt_noble_hunters"
#include "plt_clipt_archdemon"
#include "plt_clipt_alistair"
#include "plt_clipt_morrigan_ritual"
#include "plt_cir000pt_main"
#include "plt_denpt_alistair"
#include "plt_denpt_anora"
#include "plt_denpt_main"
#include "plt_denpt_rescue_the_queen"
#include "plt_gen00pt_backgrounds"
#include "plt_gen00pt_party"
#include "plt_ntb000pt_main"
#include "plt_ntb100pt_lanaya"
#include "plt_orz400pt_zerlinda"
#include "plt_orz510pt_legion"
#include "plt_orzpt_main"
#include "plt_ranpt_generic_actions"
#include "plt_urn200pt_cult"
#include "plt_genpt_leliana_main"
#include "plt_genpt_sten_main"
#include "plt_genpt_oghren_main"
#include "plt_gen00pt_class_race_gend"

#include "plt_genpt_app_zevran"
#include "plt_genpt_app_leliana"
#include "plt_genpt_app_alistair"

#include "plt_urnpt_main"

#include "plt_zz_epi_debug"

// Qwinn: Added this for Ser Cauthrien check below
#include "plt_denpt_captured"
// Qwinn: Added these for Cyrion check below
#include "plt_denpt_slave_trade"
#include "plt_epipt_main"

void EPI_RemoveParty();

void EPI_EquipAlistair();
void EPI_EquipLeliana();

void EPI_AlistairCrowd();
void EPI_ZevranCrowd();
void EPI_OghrenCrowd();
void EPI_LelianaCrowd();
void EPI_WynneCrowd();

// Function to show if all NPCs should appear in epilogue.
// This is a debug command.
int IsAllNPCShowing()
{
    return WR_GetPlotFlag( PLT_ZZ_EPI_DEBUG, ZZ_EPI_DEBUG_SET_FULL_NPCS_ATTENDING );
}

void SetKingAndQueen()
{

    object  oPC = GetHero();

    // Qwinn:  This code is vastly overcomplicated. One existing flag, EPIPT_MAIN:ALISTAIR_ALIVE_AND_KING could
    // replace 80% of this.  However, as a separate fix, we're making Alistair always appear unless he's dead or
    // exiled, and Eamon always appear too.
    /*
    // Alistair Vars
    int         bSoleKing               = WR_GetPlotFlag( PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_IS_KING );
    int         bAlistairAnoraMarried   = WR_GetPlotFlag( PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_ENGAGED_TO_ANORA );
    int         bAlistairKillArchdemon  = WR_GetPlotFlag( PLT_CLIPT_ARCHDEMON, CLIMAX_ARCHDEMON_ALISTAIR_KILLS_ARCHDEMON );
    int         bAlistairRitual         = WR_GetPlotFlag( PLT_CLIPT_MORRIGAN_RITUAL, MORRIGAN_RITUAL_WITH_ALISTAIR );
    int         bAlistairAlive;
    int         bAlistairWedPlayer      = WR_GetPlotFlag( PLT_DENPT_ALISTAIR, DEN_ALISTAIR_MARRYING_PLAYER );
    int         bAlistairAtFinalBattle  = WR_GetPlotFlag( PLT_CLIPT_ALISTAIR, CLIMAX_ALISTAIR_WITH_PARTY_AT_ARCHDEMON_FIGHT );
    object      oAlistair               = UT_GetNearestCreatureByTag( oPC, EPI_CR_ALISTAIR );

    // Anora Vars
    object      oAnora = UT_GetNearestCreatureByTag( oPC, EPI_CR_ANORA );
    int         bSoleQueen = WR_GetPlotFlag( PLT_DENPT_MAIN, LANDSMEET_ANORA_IS_QUEEN );
    int         bAnoraOnThrone = WR_GetPlotFlag( PLT_DENPT_MAIN, LANDSMEET_ANORA_ON_THRONE, TRUE );
    int         bAnoraWedPlayer = WR_GetPlotFlag( PLT_DENPT_MAIN, LANDSMEET_PLAYER_IS_KING );

    // Arl Eamon Vars
    object      oEamon = UT_GetNearestCreatureByTag( oPC, EPI_CR_EAMON );

    // Check to see if Alistair is alive
    if (bAlistairKillArchdemon && !bAlistairRitual)
    {
        // Alistair is dead
        bAlistairAlive = FALSE;
    }
    else bAlistairAlive = TRUE;

    // If Alistair is alive, and he's on the throne or was at the final
    // battle he will be at the coronation.
    if ((bAlistairAlive) &&
    (bAlistairAnoraMarried || bSoleKing || bAlistairWedPlayer || bAlistairAtFinalBattle))
    {
        WR_SetObjectActive( oAlistair, TRUE );

        // If Alistair is king Arl Eamon is there.
        if (bSoleKing || bAlistairAnoraMarried || bAlistairWedPlayer)
            WR_SetObjectActive( oEamon, TRUE );
    }

    // If Anora is on the throne OR
    // Anora is marrying the player OR
    // Alistair is dead.
    if (bAnoraOnThrone || bAnoraWedPlayer || !bAlistairAlive)
            WR_SetObjectActive( oAnora, TRUE );
    */

    // Qwinn:  Unlike the above code, this also makes sure Alistair wasn't killed at Landsmeet
    object oAlistair  = UT_GetNearestCreatureByTag( oPC, EPI_CR_ALISTAIR );
    object oAnora     = UT_GetNearestCreatureByTag( oPC, EPI_CR_ANORA );
    object oEamon     = UT_GetNearestCreatureByTag( oPC, EPI_CR_EAMON );

    int bAlistairDead =   (WR_GetPlotFlag(PLT_CLIPT_ARCHDEMON,CLIMAX_ARCHDEMON_ALISTAIR_KILLS_ARCHDEMON) ||
                           WR_GetPlotFlag(PLT_DENPT_MAIN,LANDSMEET_ALISTAIR_KILLED));
    int bAlistairExiled =  WR_GetPlotFlag(PLT_DENPT_MAIN,LANDSMEET_ALISTAIR_LEAVES_FOREVER);

    if ((!bAlistairDead) && (!bAlistairExiled))
       WR_SetObjectActive( oAlistair, TRUE );

    WR_SetObjectActive( oEamon, TRUE );

    int bAnoraOnThrone = WR_GetPlotFlag( PLT_DENPT_MAIN, LANDSMEET_ANORA_ON_THRONE);
    if (bAnoraOnThrone || bAlistairDead)
        WR_SetObjectActive( oAnora, TRUE );
}

void SetPartyMembersAttending()
{
    object  oPC             = GetHero();

    //Dog
    int         bDog = WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_DOG_RECRUITED );
    object      oDog = GetObjectByTag(EPI_CR_DOG);
    object      oPartyDog = GetObjectByTag(GEN_FL_DOG);
    string      sDogName  = GetName(oPartyDog);
    //if dog has been recruited - we need to grab the dog object from the party pool and set it active and jump it to its post
    if( bDog == TRUE)
    {
        WR_SetObjectActive(oDog, TRUE);
        SetName(oDog, sDogName);
        // Qwinn added
        SetObjectInteractive(oDog, TRUE);
    }
    else WR_SetObjectActive(oDog, FALSE);


    //Lelania
    int         bLelania = WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_LELIANA_RECRUITED );
    object      oLelania = GetObjectByTag( EPI_CR_LELIANA );
    if( bLelania )
    {
        WR_SetObjectActive( oLelania, TRUE );
        EPI_LelianaCrowd();
    }


    //Loghain
    // Check if Logain died in climax
    int         bLoghain        = WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_LOGHAIN_RECRUITED );
    int         bLoghainRitual  = WR_GetPlotFlag( PLT_CLIPT_MORRIGAN_RITUAL, MORRIGAN_RITUAL_WITH_LOGHAIN );
    int         bLoghainDeath   = WR_GetPlotFlag( PLT_CLIPT_ARCHDEMON, CLIMAX_ARCHDEMON_LOGHAIN_KILLS_ARCHDEMON );
    object      oLoghain        = UT_GetNearestCreatureByTag( oPC, EPI_CR_LOGHAIN );

    // IF:  Recruited AND
    // IF: Either Died, and had ritual, or Didn't die.
    if (( bLoghain ) &&
      (( bLoghainDeath && bLoghainRitual ) || ( !bLoghainDeath )))
        WR_SetObjectActive( oLoghain, TRUE );

    //Oghren
    int         bOghren = WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_OGHREN_RECRUITED );
    object      oOghren = UT_GetNearestCreatureByTag( oPC, EPI_CR_OGHREN );
    if( bOghren )
    {
        WR_SetObjectActive( oOghren, TRUE );
        EPI_OghrenCrowd();
    }


    //Shale
    int         bShale = WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_SHALE_RECRUITED );
    object      oShale = UT_GetNearestCreatureByTag( oPC, EPI_CR_SHALE );
    if( bShale )
        WR_SetObjectActive( oShale, TRUE );

    //Sten
    int         bSten      = WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_STEN_RECRUITED );
    int         bStenSword = WR_GetPlotFlag( PLT_GENPT_STEN_MAIN, STEN_MAIN_HAS_SWORD_BACK);
    object      oSten      = UT_GetNearestCreatureByTag( oPC, EPI_CR_STEN );
    object      oItem      = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oSten);

    if( bSten )
    {
        WR_SetObjectActive( oSten, TRUE );

        if( bStenSword )
        {
            // Give Sten
            UnequipItem(oSten, oItem);

            object oSword = CreateItemOnObject(EPI_STEN_SWORD, oSten, 1, "", TRUE);

            EquipItem(oSten, oSword, INVENTORY_SLOT_MAIN);

        }

    }

    else
    {
        UT_TeamAppears(EPI_TEAM_STEN_STAND_IN, TRUE);
    }

    //Wynne
    int         bWynne = WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_WYNNE_RECRUITED );
    object      oWynne = UT_GetNearestCreatureByTag( oPC, EPI_CR_WYNNE );
    if( bWynne )
    {
        WR_SetObjectActive( oWynne, TRUE );
        EPI_WynneCrowd();
    }


    //Zevran
    int         bZevran = WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_ZEVRAN_RECRUITED );
    object      oZevran = UT_GetNearestCreatureByTag( oPC, EPI_CR_ZEVRAN );
    if( bZevran )
    {
        WR_SetObjectActive( oZevran, TRUE );
        EPI_ZevranCrowd();
    }


}

void SetOriginMembersAttending()
{

    object  oPC             = GetHero();

    //Ashalle
    int         bElfDalish  = WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_ELF_DALISH );
    object      oAshalle    = UT_GetNearestCreatureByTag( oPC, EPI_CR_ASHALLE );
    if( bElfDalish )
        WR_SetObjectActive( oAshalle, TRUE );

    //Cyrion
    /* int         bElfCity    = WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_ELF_CITY );
    object      oCyrion     = UT_GetNearestCreatureByTag( oPC, EPI_CR_CYRION );
    if( bElfCity )
        WR_SetObjectActive( oCyrion, TRUE );
    */
    //Qwinn: added the 3 Caladrius exceptions, in those 3 circumstances Cyrion is either dead or a slave.
    //v2.0: Keep him if player died killing archdemon, too hard to remove
    int         bElfCity    = WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_ELF_CITY );
    int         bCaladrius1 = WR_GetPlotFlag( PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_CALADRIUS_LEAVES_WITH_SLAVES_AND_MONEY );
    int         bCaladrius2 = WR_GetPlotFlag( PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_CALADRIUS_LEAVES_PROFITS );
    int         bCaladrius3 = WR_GetPlotFlag( PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_CALADRIUS_GIVES_PLAYER_CON_BOOST );
    int         bPlayerDead = WR_GetPlotFlag( PLT_EPIPT_MAIN, EPI_PLAYER_IS_DEAD );
    object      oCyrion     = UT_GetNearestCreatureByTag( oPC, EPI_CR_CYRION );
    if( bElfCity && ( (!bCaladrius1 && !bCaladrius2 && !bCaladrius3) || bPlayerDead ))
        WR_SetObjectActive( oCyrion, TRUE );

    //Fergus
    int         bHumanNoble = WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_HUMAN_NOBLE );
    object      oFergus     = UT_GetNearestCreatureByTag( oPC, EPI_CR_FERGUS );
    if( bHumanNoble )
        WR_SetObjectActive( oFergus, TRUE );

    //Gorim
    int         bDwarfNoble = WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_DWARF_NOBLE );
    object      oGorim      = UT_GetNearestCreatureByTag( oPC, EPI_CR_GORIM );
    if( bDwarfNoble )
        WR_SetObjectActive( oGorim, TRUE );

    //Irving
    int         bIrvingDead = WR_GetPlotFlag( PLT_CIR000PT_MAIN, ALL_MAGES_DEAD );
    int         bMageOrigin = WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_CIRCLE );
    object      oIrving     = UT_GetNearestCreatureByTag( oPC, EPI_CR_IRVING );
    if((bIrvingDead == FALSE) && (bMageOrigin == TRUE) )
        WR_SetObjectActive( oIrving, TRUE );

    //Rica
    int         bDwarfCommoner  = WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_DWARF_COMMONER );
    object      oRica           = UT_GetNearestCreatureByTag( oPC, EPI_CR_RICA );
    if( bDwarfCommoner )
        WR_SetObjectActive( oRica, TRUE );


    //Leliana's Nug Scmooples
    int         bLeliana    = WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_LELIANA_RECRUITED );
    int         bNug        = WR_GetPlotFlag( PLT_GENPT_LELIANA_MAIN, LELIANA_MIAN_LELIANA_HAS_NUG );
    object      oNug    = UT_GetNearestCreatureByTag( oPC, CAMP_NUG );
    if( bLeliana && bNug )
        WR_SetObjectActive( oNug, TRUE );

}



void SetOtherNPCsAttending()
{

    object  oPC             = GetHero();

    // Check for debug, showing all NPCs
    int bAllNPCs = IsAllNPCShowing();

    // Bryland
    // Always supports you and is always there.
    object      oBryland = UT_GetNearestCreatureByTag( oPC, EPI_CR_BRYLAND );
    WR_SetObjectActive( oBryland, TRUE );

    // Connor
    int         bConnor = WR_GetPlotFlag( PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_CONNOR_FREED );
    object      oConnor = UT_GetNearestCreatureByTag( oPC, EPI_CR_CONNOR );
    if( bConnor || bAllNPCs)
        WR_SetObjectActive( oConnor, TRUE );

    // Cullen
    int         bCullen = WR_GetPlotFlag( PLT_CIR000PT_MAIN, TEMPLARS_IN_ARMY );
    object      oCullen = UT_GetNearestCreatureByTag( oPC, EPI_CR_CULLEN );
    if( bCullen || bAllNPCs)
        WR_SetObjectActive( oCullen, TRUE );

    // Dulin
    int         bDulin = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_HARROWMONT );
    object      oDulin = UT_GetNearestCreatureByTag( oPC, EPI_CR_DULIN );
    if( bDulin || bAllNPCs)
        WR_SetObjectActive( oDulin, TRUE );

    // Genitivi
    int         bPartedWell = WR_GetPlotFlag( PLT_URNPT_MAIN, GENITIVI_RETURNS_TO_DENERIM );
    int         bUrnTainted = WR_GetPlotFlag( PLT_URN200PT_CULT, URN_TAINTED );
    // Qwinn added - he can be killed in Denerim
    int         bGenitiviKilled = WR_GetPlotFlag( PLT_URNPT_MAIN, GENITIVI_ATTACKED );

    object      oGenitivi = UT_GetNearestCreatureByTag( oPC, EPI_CR_GENITIVI );
    if ((bPartedWell && (!bUrnTainted) && (!bGenitiviKilled)) || bAllNPCs)
        WR_SetObjectActive( oGenitivi, TRUE );
    // Qwinn added - he is already active in area file, so he always appeared
    else
        WR_SetObjectActive( oGenitivi, FALSE );

    // Greagoir
    int         bGreagoir = WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_CIRCLE );
    object      oGreagoir = UT_GetNearestCreatureByTag( oPC, EPI_CR_GREAGOIR );
    if( bGreagoir )
        WR_SetObjectActive( oGreagoir, TRUE );

    // Isolde
    int         bIsolde = WR_GetPlotFlag( PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_CIRCLE_DOES_RITUAL );
    object      oIsolde = UT_GetNearestCreatureByTag( oPC, EPI_CR_ISOLDE );
    if( bIsolde || bAllNPCs)
        WR_SetObjectActive( oIsolde, TRUE );

    // Jowan
    int         bDefendedJowan  = WR_GetPlotFlag( PLT_ARL100PT_ENTER_CASTLE, ARL_ENTER_CASTLE_PC_BRINGS_JOWAN_TO_HALL );
    int         bJowanDead      = WR_GetPlotFlag( PLT_ARL100PT_ENTER_CASTLE, ARL_ENTER_CASTLE_JOWAN_DEAD );
    int         bJowanKilled    = WR_GetPlotFlag(PLT_RANPT_GENERIC_ACTIONS, RAN_JOWAN_DEAD);
    object      oJowan          = UT_GetNearestCreatureByTag( oPC, EPI_CR_JOWAN );
    if(( bDefendedJowan && !bJowanDead && !bJowanKilled) || bAllNPCs)
        WR_SetObjectActive( oJowan, TRUE );


    // Kalah
    int         bDwarfCommoner  = WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_DWARF_COMMONER );
    object      oKalah          = UT_GetNearestCreatureByTag( oPC, EPI_CR_KALAH );
    if( bDwarfCommoner )
        WR_SetObjectActive( oKalah, TRUE );

    // Kardol
    object      oKardol = UT_GetNearestCreatureByTag( oPC, EPI_CR_KARDOL );

    WR_SetObjectActive( oKardol, TRUE );

    // Keeper
    object      oKeeper     = UT_GetNearestCreatureByTag( oPC, EPI_CR_KEEPER );
    int         bElfDalish  = WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_ELF_DALISH );
    if( bElfDalish )
        WR_SetObjectActive( oKeeper, TRUE );

    // LadyOfForest
    int         bLadyOfForest = WR_GetPlotFlag( PLT_NTB000PT_MAIN, NTB_MAIN_WEREWOLVES_PROMISED_ALLIANCE );
    object      oLadyOfForest = UT_GetNearestCreatureByTag( oPC, "ntb340cr_lady" );
    if(( bLadyOfForest ) || bAllNPCs)
        WR_SetObjectActive( oLadyOfForest, TRUE );

    // Lanaya
    int         bElfAlliance    = WR_GetPlotFlag( PLT_NTB000PT_MAIN, NTB_MAIN_ELVES_PROMISED_ALLIANCE );
    int         bLanayaAngry    = WR_GetPlotFlag( PLT_NTB100PT_LANAYA, NTB_LANAYA_ANGRY_AT_PC );
    int         bLanayaAngrier  = WR_GetPlotFlag( PLT_NTB100PT_LANAYA, NTB_LANAYA_ANGRIER_AT_PC );
    object      oLanaya = UT_GetNearestCreatureByTag( oPC, EPI_CR_LANAYA );
    if(( bElfAlliance && !bLanayaAngry && !bLanayaAngrier ) || bAllNPCs)
        WR_SetObjectActive( oLanaya, TRUE );

    // Lily
    object      oLily = UT_GetNearestCreatureByTag( oPC, EPI_CR_LILY );
    if(( bDefendedJowan && !bJowanDead) || bAllNPCs)
        WR_SetObjectActive( oLily, TRUE );

    // Mardy
    int         bSleptMardy = WR_GetPlotFlag( PLT_BDN100PT_NOBLE_HUNTERS, BDN_NOBLE_HUNTERS_CHOSE_SEX_WITH_MARDY );
    int         bSleptBoth  = WR_GetPlotFlag( PLT_BDN100PT_NOBLE_HUNTERS, BDN_NOBLE_HUNTERS_CHOSE_SEX_WITH_BOTH );
    object      oMardy = UT_GetNearestCreatureByTag( oPC, EPI_CR_MARDY );
    if(( bSleptMardy || bSleptBoth ) || bAllNPCs)
        WR_SetObjectActive( oMardy, TRUE );

    // SerCauthrien
    /*
    int         bCauthrienKilled    = WR_GetPlotFlag( PLT_DENPT_MAIN, LANDSMEET_CAUTHRIEN_KILLED );
    object      oSerCauthrien       = UT_GetNearestCreatureByTag( oPC, EPI_CR_SERCAUTH );
    if(( bCauthrienKilled ) || bAllNPCs)
        WR_SetObjectActive( oSerCauthrien, TRUE );
    */
    // Qwinn: This check was reversed, she only showed up if she *was* killed just before Landsmeet
    // Also adding check to make sure she wasn't killed during Captured!
    int         bCauthrienKilledLandsmeet    = WR_GetPlotFlag( PLT_DENPT_MAIN, LANDSMEET_CAUTHRIEN_KILLED );
    int         bCauthrienKilledCaptured     = WR_GetPlotFlag( PLT_DENPT_CAPTURED, DEN_CAPTURED_CAUTHRIEN_DEFEATED );
    object      oSerCauthrien       = UT_GetNearestCreatureByTag( oPC, EPI_CR_SERCAUTH );
    if(( !bCauthrienKilledLandsmeet && !bCauthrienKilledCaptured ) || bAllNPCs)
        WR_SetObjectActive( oSerCauthrien, TRUE );


    // Sighard
    int         bSighard = WR_GetPlotFlag( PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_OSWYN_SAVED );
    object      oSighard = UT_GetNearestCreatureByTag( oPC, EPI_CR_SIGHARD );
    if(( bSighard ) || bAllNPCs)
        WR_SetObjectActive( oSighard, TRUE );

    // Soris
    int         bSoris = WR_GetPlotFlag( PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_FREED_SORRIS );
    object      oSoris = UT_GetNearestCreatureByTag( oPC, EPI_CR_SORIS );
    if(( bSoris ) || bAllNPCs)
        WR_SetObjectActive( oSoris, TRUE );

    // Vartag
    int         bVartag = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_BHELEN );
    object      oVartag = UT_GetNearestCreatureByTag( oPC, EPI_CR_VARTAG );
    if(( bVartag ) || bAllNPCs)
        WR_SetObjectActive( oVartag, TRUE );

    // Zathrian
    // Qwinn added killed by pc check. Also reversed condition - originally he only showed if he sacrificed himself
    int bZathrianSacrificed = WR_GetPlotFlag( PLT_NTB000PT_MAIN, NTB_MAIN_ZATHRIAN_SACRIFICES_HIMSELF );
    int bZathrianKilled = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ZATHRIAN_KILLED_BY_PC);
    object      oZathrian = UT_GetNearestCreatureByTag( oPC, EPI_CR_ZATHRIAN );
    if(( (!bZathrianSacrificed) && (!bZathrianKilled)) || bAllNPCs)
        WR_SetObjectActive( oZathrian, TRUE );

    // Zelinda
    int         bZelinda = WR_GetPlotFlag( PLT_ORZ400PT_ZERLINDA, ORZ_ZERLINDA___PLOT_03_COMPLETED_GONE_TO_SURFACE );
    object      oZelinda = UT_GetNearestCreatureByTag( oPC, EPI_CR_ZERLINDA );
    if(( bZelinda ) || bAllNPCs)
        WR_SetObjectActive( oZelinda, TRUE );

}

void EPI_RemoveParty()
{
    object      oPC     = GetHero();
    int         i;                              // Counter
    object []   oMember = GetPartyPoolList();

    object oAlistair = GetObjectByTag(GEN_FL_ALISTAIR);
    object oDog = GetObjectByTag(GEN_FL_DOG);
    object oLeliana = GetObjectByTag(GEN_FL_LELIANA);
    object oLoghain = GetObjectByTag(GEN_FL_LOGHAIN);
    object oMorrigan = GetObjectByTag(GEN_FL_MORRIGAN);
    object oOghren = GetObjectByTag(GEN_FL_OGHREN);
    object oShale = GetObjectByTag(GEN_FL_SHALE);
    object oSten = GetObjectByTag(GEN_FL_STEN);
    object oWynne = GetObjectByTag(GEN_FL_WYNNE);
    object oZevran = GetObjectByTag(GEN_FL_ZEVRAN);

    // Set the PC as the leader
    SetPartyLeader(oPC);

    // Deflag all the party members.
    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY, FALSE);
    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY, FALSE);
    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_IN_PARTY, FALSE);
    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_LOGHAIN_IN_PARTY, FALSE);
    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_IN_PARTY, FALSE);
    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_OGHREN_IN_PARTY, FALSE);
    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_SHALE_IN_PARTY, FALSE);
    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_STEN_IN_PARTY, FALSE);
    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_PARTY, FALSE);
    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_PARTY, FALSE);


    if(IsObjectValid(oAlistair))
    {
        Log_Trace(LOG_CHANNEL_TEMP, "boom", "Alistair object valid, state: " + IntToString(GetFollowerState(oAlistair)));

        if(GetFollowerState(oAlistair) != FOLLOWER_STATE_INVALID)
            WR_SetFollowerState(oAlistair, FOLLOWER_STATE_UNAVAILABLE);
    }
    else
        Log_Trace(LOG_CHANNEL_TEMP, "boom", "Alistair object INVALID");

    if(IsObjectValid(oDog))
        WR_SetFollowerState(oDog, FOLLOWER_STATE_UNAVAILABLE);
    if(IsObjectValid(oLeliana))
        WR_SetFollowerState(oLeliana, FOLLOWER_STATE_UNAVAILABLE);
    if(IsObjectValid(oLoghain))
        WR_SetFollowerState(oLoghain, FOLLOWER_STATE_UNAVAILABLE);
    if(IsObjectValid(oMorrigan))
        WR_SetFollowerState(oMorrigan, FOLLOWER_STATE_UNAVAILABLE);
    if(IsObjectValid(oOghren))
        WR_SetFollowerState(oOghren, FOLLOWER_STATE_UNAVAILABLE);
    if(IsObjectValid(oShale))
        WR_SetFollowerState(oShale, FOLLOWER_STATE_UNAVAILABLE);
    if(IsObjectValid(oSten))
        WR_SetFollowerState(oSten, FOLLOWER_STATE_UNAVAILABLE);
    if(IsObjectValid(oWynne))
        WR_SetFollowerState(oWynne, FOLLOWER_STATE_UNAVAILABLE);
    if(IsObjectValid(oZevran))
        WR_SetFollowerState(oZevran, FOLLOWER_STATE_UNAVAILABLE);


    // Remove all party members
    for (i = 0; i < 6; i++)
    {
        //if (!IsObjectValid(oMember[i]))
        //    break;
        // Fire member if not the leader

        Effects_RemoveEffectByType(oMember[i], EFFECT_TYPE_UPKEEP);

        if ((IsFollower(oMember[i])) && (oMember[i] != GetPartyLeader()))
        {

            //SetFollowerState(oMember[i], FOLLOWER_STATE_INVALID);
            // Set X member in party to not in party
            //DestroyObject(oMember[i]);
        }

    }
}

void EPI_EquipAlistair()
{
    object oItem;
    object oAlistair = GetObjectByTag(EPI_CR_ALISTAIR);

    object oChest  = CreateItemOnObject(EPI_CLOTH_ALISTAIR_CHEST, oAlistair, 1, "", TRUE);
    object oGloves = CreateItemOnObject(EPI_CLOTH_ALISTAIR_GLOVES, oAlistair, 1, "", TRUE);
    object oBoots  = CreateItemOnObject(EPI_CLOTH_ALISTAIR_BOOTS, oAlistair, 1, "", TRUE);

    //StoreFollowerInventory

    oItem = GetItemInEquipSlot(INVENTORY_SLOT_HEAD, oAlistair);
    UnequipItem(oAlistair, oItem);

    oItem = GetItemInEquipSlot(INVENTORY_SLOT_CHEST, oAlistair);
    UnequipItem(oAlistair, oItem);

    oItem = GetItemInEquipSlot(INVENTORY_SLOT_GLOVES, oAlistair);
    UnequipItem(oAlistair, oItem);

    oItem = GetItemInEquipSlot(INVENTORY_SLOT_BOOTS, oAlistair);
    UnequipItem(oAlistair, oItem);

    oItem = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oAlistair);
    UnequipItem(oAlistair, oItem);

    oItem = GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND, oAlistair);
    UnequipItem(oAlistair, oItem);

    EquipItem(oAlistair, oChest, INVENTORY_SLOT_CHEST);
    EquipItem(oAlistair, oGloves, INVENTORY_SLOT_GLOVES);
    EquipItem(oAlistair, oBoots, INVENTORY_SLOT_BOOTS);


}

void EPI_EquipLeliana()
{
    object oItem;
    object oLeliana = GetObjectByTag(EPI_CR_LELIANA);

    object oChest  = CreateItemOnObject(EPI_LELIANA_LEATHER_CHEST, oLeliana, 1, "", TRUE);
    object oGloves = CreateItemOnObject(EPI_LELIANA_LEATHER_GLOVES, oLeliana, 1, "", TRUE);
    object oBoots  = CreateItemOnObject(EPI_LELIANA_LEATHER_BOOTS, oLeliana, 1, "", TRUE);

    //StoreFollowerInventory

    oItem = GetItemInEquipSlot(INVENTORY_SLOT_HEAD, oLeliana);
    UnequipItem(oLeliana, oItem);

    oItem = GetItemInEquipSlot(INVENTORY_SLOT_CHEST, oLeliana);
    UnequipItem(oLeliana, oItem);

    oItem = GetItemInEquipSlot(INVENTORY_SLOT_GLOVES, oLeliana);
    UnequipItem(oLeliana, oItem);

    oItem = GetItemInEquipSlot(INVENTORY_SLOT_BOOTS, oLeliana);
    UnequipItem(oLeliana, oItem);

    oItem = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oLeliana);
    UnequipItem(oLeliana, oItem);

    oItem = GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND, oLeliana);
    UnequipItem(oLeliana, oItem);

    EquipItem(oLeliana, oChest, INVENTORY_SLOT_CHEST);
    EquipItem(oLeliana, oGloves, INVENTORY_SLOT_GLOVES);
    EquipItem(oLeliana, oBoots, INVENTORY_SLOT_BOOTS);


}

void EPI_ZevranCrowd()
{

    int bRomance    =   WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_ROMANCE_ACTIVE);
    int bPCFemale   =   WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_FEMALE);

    if( bRomance )
    {

        if( bPCFemale )
        {
            // Deactivate default dudes.
            UT_TeamAppears(EPI_TEAM_ZEVRAN_DEFAULT, FALSE);

            // Team of women show up.
            UT_TeamAppears(EPI_TEAM_ZEVRAN_ROMANCE, TRUE);
        }

        else
        {
            // Deactivate default dudes.
            UT_TeamAppears(EPI_TEAM_ZEVRAN_DEFAULT, FALSE);


            // Team of men show up.
            UT_TeamAppears(EPI_TEAM_ZEVRAN_BROMANCE, TRUE);
        }

    }

    else
    {
        // Deactivate default dudes.
        UT_TeamAppears(EPI_TEAM_ZEVRAN_DEFAULT, FALSE);

        // Shady peeps.
        UT_TeamAppears(EPI_TEAM_ZEVRAN_SHADY, TRUE);

    }


}

void EPI_OghrenCrowd()
{

   int bFelsi   =   WR_GetPlotFlag(PLT_GENPT_OGHREN_MAIN, OGHREN_MAIN_GOT_HIS_MOJO_BACK);

   if( bFelsi )
   {
        // Set Felsi active.
        // Qwinn:  Disabled. Oghren's dialogue says he may go look her up
        // UT_TeamAppears(EPI_TEAM_FELSI, TRUE);
   }


}

void EPI_LelianaCrowd()
{

    int bChanged    =   WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_CHANGED);

    if( bChanged )
    {

        // Change her outfit.
        EPI_EquipLeliana();

        // Some men show up.
        UT_TeamAppears(EPI_TEAM_LELIANA_CHANGED, TRUE);

        // Deactivate default dudes.
        UT_TeamAppears(EPI_TEAM_LELIANA_DEFAULT, FALSE);
    }

    else
    {

        // Team of chantry people.
        UT_TeamAppears(EPI_TEAM_LELIANA_CHANTRY, TRUE);

        // Deactivate default dudes.
        UT_TeamAppears(EPI_TEAM_LELIANA_DEFAULT, FALSE);

    }


}

void EPI_WynneCrowd()
{

    int bWynne  =   WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_WYNNE_RECRUITED );

    if( bWynne )
    {
        // Deactivate default dudes.
        UT_TeamAppears(EPI_TEAM_WYNNE_DEFAULT, FALSE);

        // Scholars and mages.
        UT_TeamAppears(EPI_TEAM_WYNNE_SCHOLARS, TRUE);
    }

}

void EPI_AlistairCrowd()
{

    int bChanged    =   WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_CHANGED);

    if( bChanged )
    {

        // Nobles/Admirers show up.
        UT_TeamAppears(EPI_TEAM_ALISTAIR_CHANGED, TRUE);


    }

    else
    {

        // Lots of women.
        UT_TeamAppears(EPI_TEAM_ALISTAIR_WOMEN, TRUE);

    }


}