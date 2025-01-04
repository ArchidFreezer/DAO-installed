#include "core_h"
#include "sys_treasure_h"

void main() {
    event ev = GetCurrentEvent();
    object oKiller = GetEventObject(ev, 0);
    int nMoney = GetCreatureMoney(OBJECT_SELF);

    if (IsFollower(oKiller) && GetLocalInt(OBJECT_SELF, TS_TREASURE_GENERATED) && nMoney > 0) {
        effect[] aRewardBoni = GetEffects(oKiller, EFFECT_TYPE_REWARD_BONUS);
        int nEffects = GetArraySize(aRewardBoni);
        float fMult = 0.0;
        int i;
        for (i=0; i < nEffects; i++) {
            effect eRewardBonus = aRewardBoni[i];
            if (GetEffectInteger(eRewardBonus,EFFECT_REWARD_BONUS_FIELD_TYPE) == EFFECT_REWARD_BONUS_TYPE_CASH)
                fMult += 0.05;
        }
        if (fMult > 0.0)
            AddCreatureMoney(FloatToInt(nMoney*fMult), OBJECT_SELF, FALSE);
    }
}