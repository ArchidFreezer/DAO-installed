#include "utility_h"
#include "plt_no_helmet_plot"

void main()
{
            UT_AddItemToInventory(R"no_helmet_potion.uti", 1);
            DisplayStatusMessage( "No Helmet Rulebook Given");
            WR_SetPlotFlag( PLT_NO_HELMET_PLOT, NO_HELMET_ADDED_FLAG, TRUE );
}