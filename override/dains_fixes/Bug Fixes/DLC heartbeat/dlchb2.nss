#include "config_h"

void main() {
    string sName = GetName(GetModule());
    if (sName == "DAO_PRC_STR" || sName == "DAO_PRC_GIB") {
        InitHeartbeat(GetHero(), CONFIG_CONSTANT_HEARTBEAT_RATE);
    }
}