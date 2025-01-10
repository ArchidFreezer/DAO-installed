#include "wrappers_h"

void main()
{
    int bOrlesian = WR_GetPlotFlag("A29AAAF18A7A42F38A4A6CED9B689AE5", 0);
    object oAssassin = GetObjectByTag("rxa130cr_crow_assasin");
    object oNote = GetItemPossessedBy(oAssassin, "rxa130im_note");
    object oNoteB = GetItemPossessedBy(oAssassin, "rxa130im_note_b");

    if (bOrlesian)
    {
        SetItemDroppable(oNote, 0);
        SetItemDroppable(oNoteB, 1);
    }
}

