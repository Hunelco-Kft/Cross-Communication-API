package com.hunelco.cross_com_api.src.models

import com.google.android.gms.nearby.connection.ConnectionInfo

class NearbyDevice(id: String, connection: ConnectionInfo) :
    ConnectedDevice<ConnectionInfo>(id, connection)