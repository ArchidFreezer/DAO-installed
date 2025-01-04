//==============================================================================
/*

    Shaper's Life plot script.
        -> cod_hst_orz_shaper.nss

*/
//------------------------------------------------------------------------------
// Created By: Grant Mackay
// Created On: October 29, 2008
//==============================================================================

#include "utility_h"
#include "plot_h"
#include "orz_codex_h"
#include "orz_constants_h"
// Qwinn added
#include "plt_gen00pt_class_race_gend"

int StartingConditional()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evParms = GetCurrentEvent();              // Contains input parameters
    int     nType   = GetEventType( evParms );        // GET or SET call
    int     nFlag   = GetEventInteger( evParms, 1 );  // The bit flag # affected
    string  sPlot   = GetEventString( evParms, 0 );   // Plot GUID

    // Set Default return to FALSE
    int     bResult = FALSE;

    // Plot Debug / Global Operations
    plot_GlobalPlotHandler(evParms);

    //--------------------------------------------------------------------------
    // Actions -> normal flags only (SET)
    //--------------------------------------------------------------------------

    if( nType == EVENT_TYPE_SET_PLOT )
    {

        int nOldValue   = GetEventInteger( evParms, 3 );  // Old flag value
        int nNewValue   = GetEventInteger( evParms, 2 );  // New flag value

        // Check for which flag was set
        switch(nFlag)
        {

            case COD_HST_ORZ_SHAPER_0:
            {

                //--------------------------------------------------------------
                // Set the placeables carrying the other codex active.
                //--------------------------------------------------------------

                WR_SetObjectActive( GetObjectByTag(ORZ_IP_CODEX_SHAPER_1), TRUE );
                WR_SetObjectActive( GetObjectByTag(ORZ_IP_CODEX_SHAPER_2), TRUE );
                WR_SetObjectActive( GetObjectByTag(ORZ_IP_CODEX_SHAPER_3), TRUE );

                break;

            }

            case COD_HST_ORZ_SHAPER_1:
            {

                //--------------------------------------------------------------
                // If the first codex entries have been collected activate
                // the final entry and deactivate the origin.
                //--------------------------------------------------------------

                if ( CheckCodexComplete(sPlot, 4, 1) )
                {
                    WR_SetObjectActive( GetObjectByTag(ORZ_IP_CODEX_SHAPER_4), TRUE  );
                    WR_SetObjectActive( GetObjectByTag(ORZ_IP_CODEX_SHAPER_0), FALSE );
                }

                break;

            }

            case COD_HST_ORZ_SHAPER_2:
            {

                //--------------------------------------------------------------
                // If the first codex entries have been collected activate
                // the final entry and deactivate the origin.
                //--------------------------------------------------------------

                if ( CheckCodexComplete(sPlot, 4, 2) )
                {
                    WR_SetObjectActive( GetObjectByTag(ORZ_IP_CODEX_SHAPER_4), TRUE  );
                    WR_SetObjectActive( GetObjectByTag(ORZ_IP_CODEX_SHAPER_0), FALSE );
                }

                break;

            }

            case COD_HST_ORZ_SHAPER_3:
            {

                //--------------------------------------------------------------
                // If the first codex entries have been collected activate
                // the final entry and deactivate the origin.
                //--------------------------------------------------------------

                if ( CheckCodexComplete(sPlot, 4, 3) )
                {
                    WR_SetObjectActive( GetObjectByTag(ORZ_IP_CODEX_SHAPER_4), TRUE  );
                    WR_SetObjectActive( GetObjectByTag(ORZ_IP_CODEX_SHAPER_0), FALSE );
                }

                break;

            }
            
            // Added by Qwinn, gives Shaperate's Blessing Reward
            case COD_HST_ORZ_SHAPER_4:
            {  int iGaveReward = GetLocalInt(OBJECT_SELF , "shp_gave_reward");
               if (iGaveReward == 1)
                 break;
                 
               if (WR_GetPlotFlag( PLT_GEN00PT_CLASS_RACE_GEND, GEN_CLASS_MAGE))
               {
                  UT_AddItemToInventory(R"gen_im_wep_mag_sta_shp.uti",1);
               }
               if (WR_GetPlotFlag( PLT_GEN00PT_CLASS_RACE_GEND, GEN_CLASS_ROGUE))
               {
                  UT_AddItemToInventory(R"gen_im_wep_mel_mac_shp.uti",1);
               }
               if (WR_GetPlotFlag( PLT_GEN00PT_CLASS_RACE_GEND, GEN_CLASS_WARRIOR))
               {
                  UT_AddItemToInventory(R"gen_im_wep_mel_gsw_shp.uti",1);
               }
               
               SetLocalInt(OBJECT_SELF , "shp_gave_reward", 1);
               break;
            }            

        }

    }

    return bResult;

}