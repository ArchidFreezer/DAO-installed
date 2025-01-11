void main() {
    object[] arObjects = GetObjectsInArea(GetArea(GetHero()));
    int i, nSize = GetArraySize(arObjects);
    for (i = 0; i < nSize; i++) {
        object oObj = arObjects[i];
        if (GetObjectType(oObj) == OBJECT_TYPE_CREATURE) {
            if (GetPackageAI(oObj) == 10050 && HasAbility(oObj, 11114)) {
                RemoveAbility(oObj, 11114);
                AddAbility(oObj, 899000133);
            } else if (GetPackageAI(oObj) == 10029 && HasAbility(oObj, 3060)) {
                RemoveAbility(oObj, 3060);
                AddAbility(oObj, 378231138);
            }
        }
    }
}