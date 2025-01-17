// This script is by the cocoon 'dialogue' to activate Set Arbither, ready to be freed.
//

//--------------------------------------------------------------------------------------------------
// MAIN
//--------------------------------------------------------------------------------------------------
#include "utility_h"

void main()
{
    object oCocoon = GetObjectByTag("bpsk_cocoon_knives");
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY,EffectScreenShake(1),oCocoon); 
    ApplyEffectVisualEffect(oCocoon, oCocoon, 1014, EFFECT_DURATION_TYPE_TEMPORARY,10.0); 
    ApplyEffectVisualEffect(oCocoon, oCocoon, 1137, EFFECT_DURATION_TYPE_TEMPORARY,10.0); 
    // 1014=shield impact; 7=dust impact;1020=dirt impact;1111=defence impact;1137=physical impact
}