//==============================================================================
/*

    Paragon of Her Kind
     -> Defined Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: November 26, 2007
//==============================================================================

#include "plt_gen00pt_class_race_gend"
#include "plt_gen00pt_backgrounds"
#include "plt_gen00pt_party"
#include "plt_bdnpt_main"

#include "plt_orzpt_main"
#include "plt_orzpt_anvil"
#include "plt_orzpt_generic"
#include "plt_orzpt_defined"
#include "plt_orzpt_talked_to"
#include "plt_orzpt_wfbhelen"
#include "plt_orzpt_wfbhelen_t1"
#include "plt_orzpt_wfbhelen_t2"
#include "plt_orzpt_wfbhelen_t3"
#include "plt_orzpt_wfbhelen_da"
#include "plt_orzpt_wfharrow"
#include "plt_orzpt_wfharrow_t1"
#include "plt_orzpt_wfharrow_t2"
#include "plt_orzpt_wfharrow_t3"
#include "plt_orzpt_wfharrow_da"

#include "orz_constants_h"
#include "orz_functions_h"

#include "utility_h"
#include "plot_h"

int StartingConditional()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evEvent = GetCurrentEvent();            // Contains input parameters
    int     nType   = GetEventType(evEvent);        // GET or SET call
    string  sPlot   = GetEventString(evEvent, 0);   // Plot GUID
    int     nFlag   = GetEventInteger(evEvent, 1);  // The bit flag # affected
    object  oOwner  = GetEventCreator(evEvent);     // Script plot table owner

    // Grab Player, Set Default return to FALSE
    object  oPC     = GetHero();
    object  oParty  = GetParty( oPC );
    int     bResult = FALSE;

    // Plot Debug / Global Operations
    plot_GlobalPlotHandler(evEvent);

    //--------------------------------------------------------------------------
    // Actions -> normal flags only (SET)
    // IMPORTANT:   The flag value on a SET event is set only AFTER this script
    //              finishes running!
    //--------------------------------------------------------------------------

    if( nType == EVENT_TYPE_SET_PLOT )
    {

        int nOldValue   = GetEventInteger(evEvent, 3);  // Old flag value
        int nNewValue   = GetEventInteger(evEvent, 2);  // New flag value

        // Check for which flag was set
        switch(nFlag)
        {
        }

    }

    //--------------------------------------------------------------------------
    // Conditions -> defined flags only (GET DEFINED)
    //--------------------------------------------------------------------------

    else
    {

        // Check for which flag was checked
        switch(nFlag)
        {


            case ORZ_DEFINED_DWARF_COMMONER_FEMALE:
            {

                //--------------------------------------------------------------
                // COND:    The PC is a female dwarf commoner
                //--------------------------------------------------------------

                int         bFemale;
                int         bDwarfComm;

                //--------------------------------------------------------------

                bFemale     = WR_GetPlotFlag (PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_FEMALE );
                bDwarfComm  = WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_DWARF_COMMONER );

                //--------------------------------------------------------------

                if ( bFemale && bDwarfComm )
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_DWARF_COMMONER_MALE:
            {

                //--------------------------------------------------------------
                // COND:    The PC is a male dwarf commoner
                //--------------------------------------------------------------

                int         bMale;
                int         bDwarfComm;

                //--------------------------------------------------------------

                bMale      = WR_GetPlotFlag( PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_MALE );
                bDwarfComm = WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_DWARF_COMMONER );

                //--------------------------------------------------------------

                if ( bMale && bDwarfComm )
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_DWARF_FEMALE:
            {

                //--------------------------------------------------------------
                // COND:    The PC is a female dwarf
                //--------------------------------------------------------------

                int         bFemale;
                int         bDwarf;

                //--------------------------------------------------------------

                bFemale = WR_GetPlotFlag( PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_FEMALE );
                bDwarf  = WR_GetPlotFlag( PLT_GEN00PT_CLASS_RACE_GEND, GEN_RACE_DWARF );

                //--------------------------------------------------------------

                if ( bFemale && bDwarf )
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_DWARF_MALE:
            {

                //--------------------------------------------------------------
                // COND:    The PC is a male dwarf
                //--------------------------------------------------------------

                int         bMale;
                int         bDwarf;

                //--------------------------------------------------------------

                bMale  = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND,GEN_GENDER_MALE);
                bDwarf = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND,GEN_RACE_DWARF);

                //--------------------------------------------------------------

                if ( bMale && bDwarf )
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_DWARF_NOBLE_FEMALE:
            {

                //--------------------------------------------------------------
                // COND:    The PC is a female dwarf noble
                //--------------------------------------------------------------

                int         bFemale;
                int         bDwarfNoble;

                //--------------------------------------------------------------

                bFemale     = WR_GetPlotFlag( PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_FEMALE );
                bDwarfNoble = WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_DWARF_NOBLE );

                //--------------------------------------------------------------

                if ( bFemale && bDwarfNoble )
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_DWARF_NOBLE_KILLED_TRIAN:
            {

                //--------------------------------------------------------------
                // COND:    The PC is a noble dwarf who killed trian
                //--------------------------------------------------------------

                int         bKilledTrian;

                //--------------------------------------------------------------

                bKilledTrian = WR_GetPlotFlag( PLT_BDNPT_MAIN, BDN_MAIN_PC_PLOTTED_TO_KILL_TRIAN );

                //--------------------------------------------------------------

                if ( bKilledTrian )
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_DWARF_NOBLE_MALE:
            {

                //--------------------------------------------------------------
                // COND:    The PC is a male dwarf noble
                //--------------------------------------------------------------

                int         bMale;
                int         bDwarfNoble;

                //--------------------------------------------------------------

                bMale       = WR_GetPlotFlag( PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_MALE );
                bDwarfNoble = WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_DWARF_NOBLE );

                //--------------------------------------------------------------

                if ( bMale && bDwarfNoble )
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_DWARF_NOBLE_NOT_KILLED_TRIAN:
            {

                //--------------------------------------------------------------
                // COND:    The PC is a noble dwarf who did not killed trian
                //--------------------------------------------------------------

                // Grab required plot flags
                int bKilledTrian = WR_GetPlotFlag(PLT_BDNPT_MAIN,BDN_MAIN_PC_PLOTTED_TO_KILL_TRIAN);
                int bDwarfNoble = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS,GEN_BACK_DWARF_NOBLE);

                if ( bDwarfNoble && !bKilledTrian )
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_EITHER_TASK_1_ACCEPTED:
            {

                //--------------------------------------------------------------
                // COND:    Player has accepted the First Task from either
                //          Harrowmont or Bhelen
                //--------------------------------------------------------------

                // Grab required flags
                int bFirstTaskBhelen = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T1, ORZ_WFBT1___PLOT_01_ACCEPTED );
                int bFirstTaskHarrow = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T1, ORZ_WFHT1___PLOT_01_ACCEPTED );

                if ( bFirstTaskBhelen || bFirstTaskHarrow )
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_EITHER_TASK_2_ACCEPTED:
            {

                //--------------------------------------------------------------
                // COND:    Player has accepted the Second Task from either
                //          Harrowmont or Bhelen
                //--------------------------------------------------------------

                // Grab required flags
                int bSecondTaskBhelen = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T2, ORZ_WFBT2___PLOT_01_ACCEPTED );
                int bSecondTaskHarrow = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T2, ORZ_WFHT2___PLOT_01_ACCEPTED );

                if ( bSecondTaskBhelen || bSecondTaskHarrow )
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_EITHER_TASK_3_ACCEPTED:
            {

                //--------------------------------------------------------------
                // COND:    Player has accepted the Third Task from either
                //          Harrowmont or Bhelen
                //--------------------------------------------------------------

                // Grab required flags
                int bThirdTaskBhelen = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T3, ORZ_WFBT3___PLOT_01_ACCEPTED );
                int bThirdTaskHarrow = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T3, ORZ_WFHT3___PLOT_01_ACCEPTED );

                if ( bThirdTaskBhelen || bThirdTaskHarrow )
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_EITHER_TASK_DA_ACCEPTED:
            {

                //--------------------------------------------------------------
                // COND:    Player has accepted the Double Agent from either
                //          Harrowmont or Bhelen
                //--------------------------------------------------------------

                // Grab required flags
                int bDABhelen = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_DA, ORZ_WFBDA___PLOT_01_ACCEPTED );
                int bDAHarrow = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_DA, ORZ_WFHDA___PLOT_01_ACCEPTED );

                if ( bDABhelen || bDAHarrow )
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_INSIDE_AREA_ANVIL_OF_THE_VOID:
            {

                //--------------------------------------------------------------
                // COND:    The PC is currently inside the area
                //--------------------------------------------------------------

                // Grab Area Tag
                string sAreaTag = GetTag(GetArea(oPC));

                if (sAreaTag == ORZ_AR_ANVIL_OF_THE_VOID)
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_INSIDE_AREA_CARIDINS_CROSS:
            {

                //--------------------------------------------------------------
                // COND:    The PC is currently inside the area
                //--------------------------------------------------------------

                // Grab Area Tag
                string sAreaTag = GetTag(GetArea(oPC));

                if (sAreaTag == ORZ_AR_CARIDINS_CROSS)
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_INSIDE_AREA_DEAD_TRENCHES:
            {

                //--------------------------------------------------------------
                // COND:    The PC is currently inside the area
                //--------------------------------------------------------------

                // Grab Area Tag
                string sAreaTag = GetTag(GetArea(oPC));

                if (sAreaTag == ORZ_AR_DEAD_TRENCHES)
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_INSIDE_AREA_ORTAN_TAIG:
            {

                //--------------------------------------------------------------
                // COND:    The PC is currently inside the area
                //--------------------------------------------------------------

                // Grab Area Tag
                string sAreaTag = GetTag(GetArea(oPC));

                if (sAreaTag == ORZ_AR_ORTAN_TAIG)
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_MAGE_OR_DWARF:
            {

                //--------------------------------------------------------------
                // COND:    The PC is either a Mage or a Dwarf
                //--------------------------------------------------------------

                // Grab required plot flags
                int bDwarf  = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND,GEN_RACE_DWARF);
                int bMage   = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS,GEN_BACK_CIRCLE);

                if ( bDwarf || bMage )
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_NOT_DWARF_OR_PARTY:
            {

                //--------------------------------------------------------------
                // COND:    The PC is not a Dwarf or has a Party
                //--------------------------------------------------------------

                // Grab required plot flags
                int bDwarf  = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND,GEN_RACE_DWARF);
                int bParty  = WR_GetPlotFlag(PLT_GEN00PT_PARTY,GEN_PLAYER_HAS_PARTY);

                if ( !bDwarf || bParty )
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_OPEN_DEEP_ROADS:
            {

                //--------------------------------------------------------------
                // COND:    The PC is either a Mage or a Dwarf
                //--------------------------------------------------------------

                // Grab required plot flags
                int bOpen1 = WR_GetPlotFlag(PLT_ORZPT_GENERIC,ORZ_GEN_OPEN_CARIDINS_CROSS);
                int bOpen2 = WR_GetPlotFlag(PLT_ORZPT_GENERIC,ORZ_GEN_OPEN_DACE_ENCOUNTER);
                int bOpen3 = WR_GetPlotFlag(PLT_ORZPT_GENERIC,ORZ_GEN_OPEN_ORTAN_TAIG);
                int bOpen4 = WR_GetPlotFlag(PLT_ORZPT_GENERIC,ORZ_GEN_OPEN_DEAD_TRENCHES);
                int bOpen5 = WR_GetPlotFlag(PLT_ORZPT_GENERIC,ORZ_GEN_OPEN_ANVIL_OF_THE_VOID);
                int bTTCommander = WR_GetPlotFlag(PLT_ORZPT_TALKED_TO,ORZ_TT_COMMANDER);

                if ((bOpen1 || bOpen2 || bOpen3 || bOpen4 || bOpen5 ) && bTTCommander)
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_WORKING_FOR_BHELEN_NOT_MENTIONED_TO_BRANKA:
            {

                //--------------------------------------------------------------
                // COND:    Player is working for Bhelen and has not yet
                //          mentioned to Branka that he is there by him
                //          or Harrowmont.
                //--------------------------------------------------------------

                int         bWorkingForBhelen;
                int         bMentionedBhelenToBranka;
                int         bMentionedHarrowToBranka;

                //--------------------------------------------------------------

                bWorkingForBhelen        = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN, ORZ_WFB_PC_WORKING_FOR_BHELEN );
                bMentionedBhelenToBranka = WR_GetPlotFlag( PLT_ORZPT_ANVIL, ORZ_ANVIL_PC_MENTIONED_BHELEN );
                bMentionedHarrowToBranka = WR_GetPlotFlag( PLT_ORZPT_ANVIL, ORZ_ANVIL_PC_MENTIONED_HARROWMONT );

                //--------------------------------------------------------------

                if( bWorkingForBhelen && !(bMentionedBhelenToBranka||bMentionedHarrowToBranka) )
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_WORKING_FOR_HARROW_NOT_MENTIONED_TO_BRANKA:
            {

                //--------------------------------------------------------------
                // COND:    Player is working for Harrowmont and has not yet
                //          mentioned to Branka that he is there by him
                //          or Harrowmont.
                //--------------------------------------------------------------

                int         bWorkingForHarrow;
                int         bMentionedBhelenToBranka;
                int         bMentionedHarrowToBranka;

                //--------------------------------------------------------------

                bWorkingForHarrow        = WR_GetPlotFlag( PLT_ORZPT_WFHARROW, ORZ_WFH_PC_WORKING_FOR_HARROWMONT );
                bMentionedBhelenToBranka = WR_GetPlotFlag( PLT_ORZPT_ANVIL, ORZ_ANVIL_PC_MENTIONED_BHELEN );
                bMentionedHarrowToBranka = WR_GetPlotFlag( PLT_ORZPT_ANVIL, ORZ_ANVIL_PC_MENTIONED_HARROWMONT );

                //--------------------------------------------------------------

                if( bWorkingForHarrow && !(bMentionedBhelenToBranka||bMentionedHarrowToBranka) )
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_CAN_FIGHT_PROVING:
            {

                //--------------------------------------------------------------
                // COND:    Player is either doing Harrowmont's first task or
                //          is already returning Bhelen's first task.
                //--------------------------------------------------------------

                int bFirstTaskBhelen;
                int bFirstTaskHarrow;

                //--------------------------------------------------------------

                bFirstTaskBhelen = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T1, ORZ_WFBT1___PLOT_02_RETURN );
                bFirstTaskHarrow = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T1, ORZ_WFHT1___PLOT_01_ACCEPTED );

                //--------------------------------------------------------------

                if ( bFirstTaskBhelen || bFirstTaskHarrow )
                    bResult = TRUE;

                break;

            }


            case ORZ_DEFINED_PC_CANNOT_ENTER_DEEP_ROADS:
            {

                //--------------------------------------------------------------
                // COND:    Player has spoken to the gate gaurd and been denied
                //          permission to enter the deep roads.
                //--------------------------------------------------------------

                int bTTCommander = WR_GetPlotFlag( PLT_ORZPT_TALKED_TO,ORZ_TT_COMMANDER );
                int bBrankaQuest = WR_GetPlotFlag( PLT_ORZPT_GENERIC, ORZ_GEN_OPEN_CARIDINS_CROSS );
                int bDaceQuest   = WR_GetPlotFlag( PLT_ORZPT_GENERIC, ORZ_GEN_OPEN_DACE_ENCOUNTER );

                if ( bTTCommander && !(bBrankaQuest || bDaceQuest) )
                    bResult = TRUE;

                break;

            }

            case ORZ_DEFINED_BRANKA_DEAD:
            {
                int nKilled = WR_GetPlotFlag(PLT_ORZPT_ANVIL,ORZ_ANVIL___PLOT_07_BRANKA_KILLED,TRUE);
                int nSuicide = WR_GetPlotFlag(PLT_ORZPT_ANVIL,ORZ_ANVIL___PLOT_08_COMPLETED_BRANKA_SUICIDES,TRUE);

                //--------------------------------------------------------------
                // CNM COND:Branka has killed herself
                //          or been killed
                //--------------------------------------------------------------
                if((nKilled == TRUE) || (nSuicide == TRUE))
                {
                    bResult = TRUE;
                }
                break;
            }


            case ORZ_DEFINED_FANATICS_BHELEN_ACTIVE:
            {

                //--------------------------------------------------------------
                // COND: Player is working for Harrowmont, has accepted the
                //       second task,  has not appointed Bhelen king in
                //       the finale.
                //--------------------------------------------------------------


                int bSecondTaskHarrow = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T2, ORZ_WFHT2___PLOT_01_ACCEPTED, TRUE );
                int bKingBhelenChosen = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_BHELEN, TRUE );
                int bKingHarrowChosen = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_HARROWMONT, TRUE );
                // Qwinn:  Added check that your work for Harrowmont isn't covert.
                int bDAHarrow = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_DA, ORZ_WFHDA___PLOT_01_ACCEPTED );

                if ( (bSecondTaskHarrow && (!bDAHarrow) && !bKingBhelenChosen) || bKingHarrowChosen )
                {

                    bResult = TRUE;

                }


                break;

            }


            case ORZ_DEFINED_FANATICS_HARROW_ACTIVE:
            {

                //--------------------------------------------------------------
                // COND: Player is working for Bhelen, has accepted the second
                //       task and has not appointed Harrowmont king in the
                //       finale.
                //--------------------------------------------------------------


                int bSecondTaskBhelen = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T2, ORZ_WFBT2___PLOT_01_ACCEPTED, TRUE );
                int bKingBhelenChosen = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_BHELEN, TRUE );
                int bKingHarrowChosen = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_HARROWMONT, TRUE );
                // Qwinn:  Added check that your work for Bhelen isn't covert.
                int bDABhelen = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_DA, ORZ_WFBDA___PLOT_01_ACCEPTED );

                if ( (bSecondTaskBhelen && (!bDABhelen) && !bKingHarrowChosen) || bKingBhelenChosen )
                {

                    bResult = TRUE;

                }


                break;

            }


            case ORZ_DEFINED_FANATICS_BHELEN_ACTIVE_SECOND_ENCOUNTER:
            {

                //--------------------------------------------------------------
                // COND: Player is working for Harrowmont, has accepted the
                //       second task,  has not appointed Bhelen king in
                //       the finale.
                //--------------------------------------------------------------


                int bThirdTaskHarrow  = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T3, ORZ_WFHT3___PLOT_01_ACCEPTED, TRUE );
                int bKingBhelenChosen = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_BHELEN, TRUE );
                int bKingHarrowChosen = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_HARROWMONT, TRUE );
                // Qwinn:  Added check that your work for Harrowmont isn't covert.
                int bDAHarrow = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_DA, ORZ_WFHDA___PLOT_01_ACCEPTED );

                if ( (bThirdTaskHarrow  && (!bDAHarrow) && !bKingBhelenChosen) || bKingHarrowChosen )
                {

                    bResult = TRUE;

                }


                break;

            }


            case ORZ_DEFINED_FANATICS_HARROW_ACTIVE_SECOND_ENCOUNTER:
            {

                //--------------------------------------------------------------
                // COND: Player is working for Bhelen, has accepted the second
                //       task and has not appointed Harrowmont king in the
                //       finale.
                //--------------------------------------------------------------


                int bThirdTaskBhelen  = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T3, ORZ_WFBT3___PLOT_01_ACCEPTED, TRUE );
                int bKingBhelenChosen = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_BHELEN, TRUE );
                int bKingHarrowChosen = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_HARROWMONT, TRUE );
                // Qwinn:  Added check that your work for Bhelen isn't covert.
                int bDABhelen = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_DA, ORZ_WFBDA___PLOT_01_ACCEPTED );

                if ( (bThirdTaskBhelen && (!bDABhelen) && !bKingHarrowChosen) || bKingBhelenChosen )
                {

                    bResult = TRUE;

                }


                break;

            }

            case ORZ_DEFINED_NOT_TT_VARTAG_DWARF_NOBLE_AND_PLOT_NOT_ACCEPTED:
            {
                int bTTVartag       = WR_GetPlotFlag(PLT_ORZPT_TALKED_TO, ORZ_TT_VARTAG);
                int bDwarfNoble     = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_DWARF_NOBLE);
                int bVartagAccepted = WR_GetPlotFlag(PLT_ORZPT_WFBHELEN, ORZ_WFB___PLOT_01_ACCEPTED);

                if (!bTTVartag && bDwarfNoble && !bVartagAccepted)
                    bResult = TRUE;

                break;
            }
            case ORZ_DEFINED_NOT_TT_VARTAG_OR_DULIN_AND_PLOT_NOT_ACCEPTED:
            {
                int bTTVartag       = WR_GetPlotFlag(PLT_ORZPT_TALKED_TO, ORZ_TT_VARTAG);
                int bTTDulin        = WR_GetPlotFlag(PLT_ORZPT_TALKED_TO, ORZ_TT_DULIN);
                int bVartagAccepted = WR_GetPlotFlag(PLT_ORZPT_WFBHELEN, ORZ_WFB___PLOT_01_ACCEPTED);

                // Only need to check vartag's plot since you get them both at the same time
                // and this cancels out the option when the player picks the dwarf
                // noble specific one.
                if (!bTTVartag && !bTTDulin && !bVartagAccepted)
                    bResult = TRUE;

                break;
            }

        }
    }

    // Plot Debug / Global Operations
    plot_OutputDefinedFlag( evEvent, bResult );

    return bResult;

}