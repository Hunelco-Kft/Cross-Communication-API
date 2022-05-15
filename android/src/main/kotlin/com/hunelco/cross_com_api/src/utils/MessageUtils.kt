package com.hunelco.cross_com_api.src.utils

object MessageUtils {
    const val EOF = "<<<EOF>>>"

    fun addEOF(data: String) = data.plus(EOF)

    fun removeEOF(data: String) = data.replace(EOF, "")
}