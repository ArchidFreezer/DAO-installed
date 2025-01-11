#include "wrappers_h"

void main()
{
    object oOghren = GetObjectByTag("gxa000fl_oghren");
    int nOrigAppEst = 0;
    int nRecruited = IsFollower(oOghren);

    int nOrlesian = WR_GetPlotFlag("A29AAAF18A7A42F38A4A6CED9B689AE5", 0); //not resetting if Orlesian
    int nOrigWarmFlag  = WR_GetPlotFlag("02F473003C8144D083B769186B7D6813", 24); //checking Origins' Oghren approval plot
    int nOrigFriendFlag = WR_GetPlotFlag("02F473003C8144D083B769186B7D6813", 22);

    if (nOrigWarmFlag == TRUE && nOrigFriendFlag == FALSE) //Oghren was warm with PC, but not friendly
    {
        nOrigAppEst = 30;  // lower range for "warm"
    }

    if (nOrigFriendFlag == TRUE) // Oghren was friendly with PC
    {
        nOrigAppEst = 60; // upper range for "warm" bc don't want to make things TOO easy
    }

    if (nRecruited)
    {
        if (WR_GetPlotFlag("89F38F31D3824B5F9313F901D6E0CB59", 1) == FALSE && nOrlesian == FALSE)
        {
            AdjustFollowerApproval(oOghren, nOrigAppEst, TRUE);
            WR_SetPlotFlag("89F38F31D3824B5F9313F901D6E0CB59", 1, TRUE); 
        }
    }
}




