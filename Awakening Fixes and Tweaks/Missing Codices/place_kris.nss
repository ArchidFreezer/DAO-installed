#include "wrappers_h"

object CreateObjectIn3DSpace( int nObjectType, resource rTemplate,
                              location lLoc, string sOverrideScript = "",
                              int bSpawnActive = TRUE, int bNoPermDeath = FALSE );

object CreateObjectIn3DSpace( int nObjectType, resource rTemplate,
                              location lLoc, string sOverrideScript = "",
                              int bSpawnActive = TRUE, int bNoPermDeath = FALSE )
{
    // Create the object using CreateObject.
    object oNewObject = CreateObject( nObjectType, rTemplate, lLoc, sOverrideScript, bSpawnActive, bNoPermDeath );
    if( !IsObjectValid( oNewObject ) ) return OBJECT_INVALID;

    // Move the object to absolute location in 3D space even if it is
    // unsafe, then return the new object.
    SetPosition( oNewObject, GetPositionFromLocation( lLoc ), FALSE );
    return oNewObject;
}

void main()
{
    object oArea = GetObjectByTag("stb100ar_blackmarsh");
    vector vNote = Vector(218.18, 189.814, 0.05);
    
    int nHasNote = WR_GetPlotFlag("A01E14F924E0455F8D7C5069780838B3", 0);
    
    if (nHasNote == FALSE)
    {
        CreateObjectIn3DSpace(OBJECT_TYPE_PLACEABLE, R"kristoff_note.utp", Location(oArea, vNote, 102.95));
    }
}