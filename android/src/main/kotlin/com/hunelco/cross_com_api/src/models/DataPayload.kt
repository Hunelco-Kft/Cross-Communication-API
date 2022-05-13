package com.hunelco.cross_com_api.src.models

import com.google.gson.annotations.SerializedName

data class DataPayload(
    @SerializedName("endpoint") val endpoint: String,
    @SerializedName("data") val data: String
)