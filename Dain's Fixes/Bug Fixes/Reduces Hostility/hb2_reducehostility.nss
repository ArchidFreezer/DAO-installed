void main() {
    float fHost = GetCreatureProperty(OBJECT_SELF, PROPERTY_SIMPLE_THREAT_DECREASE_RATE);
    if (fHost > 0.0) {
        object[] arEnemies = GetNearestObjectByHostility(OBJECT_SELF, TRUE, OBJECT_TYPE_CREATURE, 30, TRUE, TRUE, FALSE);
        int i, nSize = GetArraySize(arEnemies);
        for (i = 0; i < nSize; i++) {
            UpdateThreatTable(arEnemies[i], OBJECT_SELF, -1.0*fHost);
        }
    }
}