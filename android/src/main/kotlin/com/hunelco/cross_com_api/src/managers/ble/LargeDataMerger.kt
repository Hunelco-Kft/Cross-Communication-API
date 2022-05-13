package com.hunelco.cross_com_api.src.managers.ble

import no.nordicsemi.android.ble.data.DataMerger
import no.nordicsemi.android.ble.data.DataStream

class LargeDataMerger(
    private val maxDataSize: Int = Int.MAX_VALUE,
    private val connection: GattServerManager.ServerConnection? = null
) : DataMerger {
    private var buffer = byteArrayOf()
    private var stringBuffer = String()

    override fun merge(output: DataStream, lastPacket: ByteArray?, index: Int): Boolean {
        if ((lastPacket?.size ?: 0) == 0) return false

        buffer += lastPacket!!
        stringBuffer += String(lastPacket)
        if (stringBuffer.endsWith(EOF)) {
            buffer = buffer.copyOfRange(0, buffer.size - EOFInSize)
            checkSize()

            output.write(buffer.clone())
            buffer = byteArrayOf()
            stringBuffer = String()

            return true
        }

        checkSize()

        return false
    }

    private fun checkSize() {
        if (buffer.size > maxDataSize) {
            buffer = byteArrayOf()
            connection?.disconnect()?.enqueue()
        }
    }

    companion object {
        val EOF = "<<<EOF>>>"
        val EOFInSize = EOF.toByteArray().size
    }
}