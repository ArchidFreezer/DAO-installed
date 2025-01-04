#include "wrappers_h"
#include "plt_immersive_feastday"

void main()
{
  if ( WR_GetPlotFlag( PLT_IMMERSIVE_FEASTDAY, LUMP_OF_CHARCOAL) == TRUE ) return;
  
  object oArea = GetObjectByTag("cam100ar_camp_plains");    
  vector vLocation = Vector(138.489f,121.367f,-0.294134f);
  object oContainer = CreateObject(
    OBJECT_TYPE_PLACEABLE, 
    R"genip_invis_campfire.utp", 
    Location(oArea, vLocation, 0.0f)
  );

  if (IsObjectValid(oContainer))
  {   

    object oItem = CreateItemOnObject(R"val_im_gift_coal.uti", oContainer, 1, "", TRUE);

    WR_SetPlotFlag( PLT_IMMERSIVE_FEASTDAY, LUMP_OF_CHARCOAL, TRUE );
    return;
  }
}