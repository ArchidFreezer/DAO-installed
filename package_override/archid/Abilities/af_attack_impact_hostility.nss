const int EFFECT_TYPE_HOSTILITY_INTIMIDATION = 6610001;

void main()
{
    event  ev = GetCurrentEvent();
    int    nAttackResult = GetEventInteger(ev, 0);
    object oAttacker = GetEventObject(ev, 0);
    object oTarget = GetEventObject(ev, 1);


    if (nAttackResult != COMBAT_RESULT_BLOCKED && nAttackResult != COMBAT_RESULT_MISS && GetHasEffects(oAttacker, EFFECT_TYPE_HOSTILITY_INTIMIDATION))
        UpdateThreatTable(oTarget, oAttacker, 5.0f);
}