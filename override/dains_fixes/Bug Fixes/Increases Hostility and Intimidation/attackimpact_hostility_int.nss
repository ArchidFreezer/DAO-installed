void main()
{
    event  ev = GetCurrentEvent();
    int    nAttackResult = GetEventInteger(ev, 0);
    object oAttacker = GetEventObject(ev, 0);
    object oTarget = GetEventObject(ev, 1);

    if (nAttackResult != COMBAT_RESULT_BLOCKED && nAttackResult != COMBAT_RESULT_MISS && GetHasEffects(oAttacker, 663906003))
        UpdateThreatTable(oTarget, oAttacker, 5.0f);
}