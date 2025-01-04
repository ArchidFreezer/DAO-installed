//==============================================================================
/*

    Urn of Sacred Ashes
        -> Gauntlet area script

*/
//------------------------------------------------------------------------------
// Created By: Grant Mackay
// Created On: 09.18.08
//==============================================================================

#include "wrappers_h"
#include "utility_h"
#include "plot_h"
#include "cutscenes_h"

#include "plt_gen00pt_backgrounds"
#include "urn_functions_h"
#include "plt_cod_cha_wynne"
#include "plt_cod_cha_leliana"
#include "plt_urn230pt_gauntlet"
#include "plt_urn200pt_cult"

void main()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evEvent         = GetCurrentEvent();            // Event
    int     nEventType      = GetEventType(evEvent);        // Event Type
    object  oEventCreator   = GetEventCreator(evEvent);     // Event Creator

    // Standard Stuff
    object  oPC             = GetHero();
    int     bEventHandled   = FALSE;

    //--------------------------------------------------------------------------
    // Area Events
    //--------------------------------------------------------------------------

    switch ( nEventType )
    {


        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_AREALOAD_PRELOADEXIT:
            // Sent by: The engine
            // When: for things you want to happen while the load screen is
            // still up, things like moving creatures around.
            //------------------------------------------------------------------

            // The following checks put in a ghost to challenge the player at the end
            if ( WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_CIRCLE) )
                URN_VisionSetUp( URN_CR_JOWAN );

            else if ( WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_DWARF_COMMONER) )
                URN_VisionSetUp( URN_CR_LESKE );

            else if ( WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_ELF_CITY) )
                URN_VisionSetUp( URN_CR_SHIANNI );

            else if ( WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_ELF_DALISH) )
                URN_VisionSetUp( URN_CR_TAMLEN );

            else if ( WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_DWARF_NOBLE) )
                URN_VisionSetUp( URN_CR_TRIAN );

            else //( WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_HUMAN_NOBLE) )
                URN_VisionSetUp( URN_CR_BRYCE );

            // Set up some fire barricade action.
            object  oWall;
            int     nNth, nWalls;

            nWalls = 8; // for now

            for ( nNth = 0; nNth < nWalls; nNth++ )
            {

                oWall = GetObjectByTag( URN_IP_FIRE_WALL, nNth );
                ApplyEffectVisualEffect( oWall, oWall, 27, EFFECT_DURATION_TYPE_PERMANENT, 0.0 );

            }


            // Set up the doppelganger fight and riddlers if not already done.
            if ( !GetLocalInt(OBJECT_SELF, AREA_DO_ONCE_A) )
            {
                URN_SetupDoppelgangers();
                SetLocalInt(OBJECT_SELF, AREA_DO_ONCE_A, TRUE);
                //effect eTransparent = Effect( EFFECT_TYPE_ALPHA );
                //eTransparent = SetEffectEngineFloat( eTransparent, EFFECT_FLOAT_POTENCY, 0.8 );

                object oBrona = GetObjectByTag( URN_CR_BRONA );
                ApplyEffectVisualEffect( oBrona, oBrona, 5029, EFFECT_DURATION_TYPE_PERMANENT, 0.0 );

                object oCaithare = GetObjectByTag( URN_CR_CATHAIRE );
                ApplyEffectVisualEffect( oCaithare, oCaithare, 5029, EFFECT_DURATION_TYPE_PERMANENT, 0.0 );

                object oEalisay = GetObjectByTag( URN_CR_EALISAY );
                ApplyEffectVisualEffect( oEalisay, oEalisay, 5029, EFFECT_DURATION_TYPE_PERMANENT, 0.0 );

                object oHavard = GetObjectByTag( URN_CR_HAVARD );
                ApplyEffectVisualEffect( oHavard, oHavard, 5029, EFFECT_DURATION_TYPE_PERMANENT, 0.0 );

                object oHessarian = GetObjectByTag( URN_CR_HESSARIAN );
                ApplyEffectVisualEffect( oHessarian, oHessarian, 5029, EFFECT_DURATION_TYPE_PERMANENT, 0.0 );

                object oMaferath = GetObjectByTag( URN_CR_MAFERATH );
                ApplyEffectVisualEffect( oMaferath, oMaferath, 5029, EFFECT_DURATION_TYPE_PERMANENT, 0.0 );

                object oShartan = GetObjectByTag( URN_CR_SHARTAN );
                ApplyEffectVisualEffect( oShartan, oShartan, 5029, EFFECT_DURATION_TYPE_PERMANENT, 0.0 );

                object oVasilia = GetObjectByTag( URN_CR_VASILIA );
                ApplyEffectVisualEffect( oVasilia, oVasilia, 5029, EFFECT_DURATION_TYPE_PERMANENT, 0.0 );

            }

            break;

        }


        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_AREALOAD_POSTLOADEXIT:
            // Sent by: The engine
            // When: fires at the same time that the load screen is going away,
            // and can be used for things that you want to make sure the player
            // sees.
            //------------------------------------------------------------------

            DoAutoSave();

            if (!GetLocalInt(GetArea(oPC), AREA_DO_ONCE_B))
                URN_SetupDoppelgangers();

            break;

        }


        case EVENT_TYPE_AREALOADSAVE_PRELOADEXIT:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_AREALOADSAVE_PRELOADEXIT
            // Sent by: The engine
            // When: The area is loaded from a save game.
            //------------------------------------------------------------------

            if (!GetLocalInt(GetArea(oPC), AREA_DO_ONCE_B))
                URN_SetupDoppelgangers();

            break;

        }

        case EVENT_TYPE_TEAM_DESTROYED:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_TEAM_DESTROYED:
            // Sent by: The engine
            // When: A creature's entire team dies
            //------------------------------------------------------------------


            int nTeamID = GetEventInteger( evEvent, 0 );

            switch (nTeamID)
            {

                case URN_TEAM_DOPPELGANGER:
                {

                    object oDoor = UT_GetNearestObjectByTag( oPC, URN_IP_DPLG_DOOR_2 );
                    SetLocalInt(GetArea(oPC), AREA_DO_ONCE_B, TRUE);
                    UT_OpenDoor( oDoor, oDoor );

                    // Qwinn added to restore post doppleganger dialogue

                    // If party is too small, then there is no need to handle anything
                    object [] arParty = GetPartyList();
                    if(GetArraySize(arParty) > 1) // not only the player
                       UT_Talk (arParty[1], oPC, R"urn230_party_reaction.dlg");
                    break;
                }

                case URN_TEAM_WYNNE:
                {
                    WR_SetPlotFlag( PLT_COD_CHA_WYNNE, COD_CHA_WYNNE_DIES_AT_THE_URN, TRUE );
                    break;
                }

                case URN_TEAM_LELIANA:
                {
                    WR_SetPlotFlag(PLT_COD_CHA_LELIANA, COD_CHA_LELIANA_FIGHTS, TRUE);
                    break;
                }

                case URN_TEAM_GUARDIAN:
                {
                    int bUrnTainted = WR_GetPlotFlag( PLT_URN200PT_CULT, URN_TAINTED);
                    int bCutscene   = WR_GetPlotFlag( PLT_URN230PT_GAUNTLET, PC_AT_URN_POST_CUTSCENE);

                    if ( !bUrnTainted && !bCutscene )
                        CS_LoadCutscene( R"urn230cs_approach_urn.cut", PLT_URN230PT_GAUNTLET, PC_AT_URN_POST_CUTSCENE  );


                    break;
                }

            }

            break;

        }

        // Qwinn added:
        case EVENT_TYPE_EXIT:
        {
            if (WR_GetPlotFlag(PLT_URN230PT_BRIDGE, URN_BRIDGE_COMPLETED) == FALSE)
            {
                int bHadWraith = FALSE;
                object [] arParty = GetPartyList(oPC);
                object oPartyMember;

                int nSize = GetArraySize(arParty);
                int i,j;

                for (i = 0; i < nSize; ++i)
                {
                   oPartyMember = arParty[i];
                   // Remove any wraiths from the party.
                   if (GetTag(oPartyMember) == URN_CR_PUZZLE_WRAITH)
                   {
                       bHadWraith = TRUE;
                       UT_FireFollower(oPartyMember, FALSE, FALSE);
                       WR_SetObjectActive(oPartyMember, FALSE);
                   }
                }
                if (bHadWraith)
                {
                    object oTrigger = GetObjectByTag("urn230tr_detach_party",1);
                    SetLocalInt(oTrigger, TRIGGER_DO_ONCE_A, FALSE);
                }

            }
            break;
        }


    }

    //--------------------------------------------------------------------------
    // Pass any unhandled events to area_core
    //--------------------------------------------------------------------------

    if ( !bEventHandled )
        HandleEvent( evEvent, RESOURCE_SCRIPT_AREA_CORE );

}